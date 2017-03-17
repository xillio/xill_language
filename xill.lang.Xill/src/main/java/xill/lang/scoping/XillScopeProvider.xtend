/**
 * Copyright (C) 2015 Xillio (support@xillio.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/*
 * generated by Xtext
 */
package xill.lang.scoping

import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import xill.lang.xill.ForEachInstruction
import xill.lang.xill.FunctionCall
import xill.lang.xill.FunctionDeclaration
import xill.lang.xill.IncludeStatement
import xill.lang.xill.InstructionSet
import xill.lang.xill.Robot
import xill.lang.xill.UseStatement
import xill.lang.xill.Variable
import xill.lang.xill.VariableDeclaration
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import xill.lang.xill.ErrorInstruction
import xill.lang.xill.XillPackage
import xill.lang.xill.FunctionParameterExpression
import xill.lang.xill.ReduceExpression
import xill.RobotLoader
import com.google.inject.Inject

/**
 * This class contains custom scoping description.
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 *
 */
class XillScopeProvider extends AbstractDeclarativeScopeProvider {    
    @Inject
    private RobotLoader loader;

    override getScope(EObject context, EReference reference) {
    	
    	if(reference == XillPackage.Literals.FUNCTION_CALL__INCLUDE_STATEMENT ||
    		reference == XillPackage.Literals.FUNCTION_PARAMETER_EXPRESSION__INCLUDE_STATEMENT) {
    		return Scopes.scopeFor(context.robot.includes);
    	}
            	
        switch(context) {
            FunctionCall: {
            	return getScope(
            		context.qualified,
            		context.argumentBlock.parameters.size,
            		context,
            		context.includeStatement
            	)
            }
            FunctionParameterExpression: {
            	
            	var parameterCount = 1;
            	if(context instanceof ReduceExpression) {
            		parameterCount = 2;
            	}
            	
            	return getScope(
            		context.qualified,
            		parameterCount,
            		context,
            		context.includeStatement
            	)
            }
            UseStatement: return getScope(context)
            Variable: {
                var parentSet = context.parent;
                var node = NodeModelUtils.getNode(context)

                return getScope(parentSet, node.startLine);
            }
            default: 
            	return super.getScope(context, reference)
        }
    }

    def IScope getScope(boolean isQualified, int parameterCount, EObject context, IncludeStatement includeStatement) {
    	if(!isQualified) {
    		// This is a local or transitive function call
    		return Scopes.scopeFor(context.robot.functionDeclarations(new ArrayList<Robot>(), parameterCount, true));
    	} else {
    		// This is a function in a different library
    		var resource = includeStatement.resolveResource;
    		
    		if(resource === null) {
    			return Scopes.scopeFor(#[]);
    		}
    		
    		return Scopes.scopeFor(
    			resource.contents
    				.filter(Robot)
    				.map[robot|robot.functionDeclarations(new ArrayList<Robot>(), parameterCount, false)]
    				.flatten()
    		);
    	}
    }

    def Iterable<EObject> functionDeclarations(Robot robot, List<Robot> visited, int parameterCount, boolean isLocal) {
    	if(visited.contains(robot)) {
    		return #[];
    	}
        
        visited.add(robot);
    	
    	var result = new ArrayList<EObject>();
    	
        // Search local declarations
        result.addAll(
        	robot.instructionSet.instructions
    			.filter(FunctionDeclaration)
    			.filter(fn|isLocal || !fn.isPrivate())
    			.filter[fn|fn.parameters.size == parameterCount]
		);
    			
    			
        // And search included libraries
        result.addAll(
        	robot.includes
        	// Only search in unqualified includes
        	.filter[include|!include.qualified]
        	// Resolve the robots
        	.map[resolveResource]
        	.filterNull()
        	.map[resource|resource.contents].flatten
        	.filter(Robot)
        	// Get all matching function declarations
        	.map[library|library.functionDeclarations(visited, parameterCount, false)]
        	.flatten()
       );
        
       return result.filterNull();
    }

    def Resource resolveResource(IncludeStatement include) {
    	var fqn = include.library.join(".");
    	var url = loader.getRobot(fqn);
		
		if(url===null){
			return null;
		}
		
		return include.eResource.resourceSet.getResource(URI.createURI(url.toString()), false);
    }

    //We only scope to the local use statements
    def IScope getScope(UseStatement statement) {
        var useStatements = new ArrayList<UseStatement>();
        useStatements.addAll(
                //Collect all use statements in this robot
                statement.robot.uses
        );
        return Scopes.scopeFor(useStatements);
    }

    //Get the scope of a Variable (Targets) that resides in this instructionSet
    def IScope getScope(InstructionSet set, int line) {
        if(set === null)
            return IScope.NULLSCOPE;

        //Find all variable declarations
        var targets = set.instructions.filter(VariableDeclaration).filter[dec | NodeModelUtils.getNode(dec).startLine < line].map[name].toList;

        var parent = set.eContainer.eContainer;

        //Special cases
        if(parent !== null) {
            switch(parent) {
                ForEachInstruction: {
                    targets.add(parent.valueVar);

                    if(parent.keyVar !== null) {
                        targets.add(parent.keyVar);
                    }
                }
                FunctionDeclaration: {
                    targets.addAll(parent.parameters);
                }
                ErrorInstruction: {
                    if(parent.cause !== null) {
                        targets.addAll(parent.cause);
                    }
                }
            }
        }

        var parentSet = set.parent;
        var node = NodeModelUtils.getNode(set);
        return Scopes.scopeFor(targets, getScope(parentSet, node.startLine));
    }

    //Get the parent InstructionSet
    def InstructionSet getParent(EObject object) {
        if(object === null)
            return null;

        var parent = object.eContainer;

        switch(parent){
            InstructionSet: parent
            default: parent.parent
        }
    }

    def getRobot(EObject object) {
        var parent = object;
        while(!(parent instanceof Robot) && parent !== null) {
            parent = parent.eContainer
        }

        return parent as Robot;
    }

}
