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
package xill.lang.validation

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.validation.Check
import xill.lang.xill.Assignment
import xill.lang.xill.FunctionDeclaration
import xill.lang.xill.InstructionSet
import xill.lang.xill.ListExtraction
import xill.lang.xill.Literal
import xill.lang.xill.Robot
import xill.lang.xill.Variable
import xill.lang.xill.VariableDeclaration
import xill.lang.xill.XillPackage
import xill.lang.xill.impl.ExpressionImpl
import xill.lang.xill.IncludeStatement
import xill.lang.xill.Target
import xill.lang.xill.ErrorInstruction
import xill.lang.xill.BreakInstruction
import xill.lang.xill.ContinueInstruction
import xill.lang.xill.ReturnInstruction
import xill.lang.xill.WhileInstruction
import xill.lang.xill.ForEachInstruction
import xill.lang.xill.FunctionParameterExpression
import xill.lang.xill.ReduceExpression
import xill.RobotLoader
import com.google.inject.Inject

/**
 * This class contains custom validation rules.
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class XillValidator extends AbstractXillValidator {
    public static final String[] RESERVED_KEYWORDS = #[
        "use","as","include",
        "if","else",
        "while","foreach", "in",
        "var","function",
        "return","continue","break",
        "callbot", "runBulk", "argument",
        "map", "filter", "peek",
        "collect", "consume", "reduce", "foreach",
        "private",
        "do","success","fail","finally"
    ];
    
    @Inject
    private RobotLoader loader;


    @Check
    def checkExtractionNotOnLiterals(ListExtraction extraction) {
        if(extraction.value.expression instanceof Literal) {
            error("Cannot extract element from a literal.",extraction, if(extraction.child === null) XillPackage.Literals.LIST_EXTRACTION__INDEX else XillPackage.Literals.LIST_EXTRACTION__CHILD);
        }
    }

    @Check
    def functionDeclarationOnlyOnRootLevel(FunctionDeclaration function) {
        if(!(function.eContainer.eContainer instanceof Robot)) {
            error("Cannot declare functions in closure.", function, XillPackage.Literals.FUNCTION_DECLARATION__NAME);
        }
    }

    @Check
    def reservedKeywords(VariableDeclaration declaration) {
        if(RESERVED_KEYWORDS.contains(declaration.name.name)) {
            error("Reserved keyword `" + declaration.name.name + "`.", declaration.name, XillPackage.Literals.TARGET__NAME)
        }
    }

    @Check
    def reservedKeywords(FunctionDeclaration declaration) {
        if(RESERVED_KEYWORDS.contains(declaration.name)) {
            error("Reserved keyword `" + declaration.name + "`.", declaration, XillPackage.Literals.TARGET__NAME)
        }
    }

    @Check
    def assignmentOnlyOnVariables(Assignment assignment) {
        if(!isAssignable(assignment.left))
            error("Can only assign to variables.", XillPackage.Literals.ASSIGNMENT__LEFT);
    }

    @Check
    def noDuplicateVariableNames(VariableDeclaration declaration) {
        var parentSet = declaration.instructionSet;

        for(VariableDeclaration other : parentSet.instructions.filter(VariableDeclaration)) {
            if(other != declaration && other.name.name == declaration.name.name) {
                var node = NodeModelUtils.getNode(other);
                error("A variable with this name already exists in this scope at line: " + node.startLine, declaration.name,  XillPackage.Literals.TARGET__NAME);
            }
        }
    }
    
    @Check
    def noDuplicateIncludes(IncludeStatement includeStatement) {
    	if(includeStatement.qualified) {
	        var robot = includeStatement.eContainer as Robot;
	
	        for(IncludeStatement other : robot.includes) {
	            if(other != includeStatement && other.qualified && other.name == includeStatement.name) {
	                var node = NodeModelUtils.getNode(other);
	                error("An included library with this name already exists at line: " + node.startLine, includeStatement,  XillPackage.Literals.INCLUDE_STATEMENT__NAME);
	            }
	        }
    	}
    }

    @Check
    def noDuplicateFunctionNames(FunctionDeclaration declaration) {
        var parentSet = declaration.instructionSet;

        for(FunctionDeclaration other : parentSet.instructions.filter(FunctionDeclaration)) {
            if(other != declaration && other.name == declaration.name && other.parameters.size == declaration.parameters.size) {
                var node = NodeModelUtils.getNode(other);

                error("A function with this signature already exists at line: " + node.startLine, XillPackage.Literals.FUNCTION_DECLARATION__NAME);
            }
        }
    }
    
    /**
     * I have been here since 5 dec 2016
     */
    @Check
    def noBugsForYou(FunctionDeclaration declaration) {
    	if(declaration.name.equals("bug")) {
    		warning(
    			"It's not a bug... It's a feature.",
    			declaration,
    			XillPackage.Literals.FUNCTION_DECLARATION__NAME
    		);
    	}
    }

    @Check
    def noVariableNameSameAsParameter(FunctionDeclaration declaration){

        var parameters = declaration.parameters;
        declaration.instructionBlock.recursiveCheck(parameters);
    }

    def void recursiveCheck(EObject obj ,EList<Target> list){
        if(obj === null){
            return;
        }

        switch(obj){
            VariableDeclaration:
                for(Target t : list) {
                    if(t.name == obj.name.name) {
                        var node = NodeModelUtils.getNode(t);
                        error("The variable '" + obj.name.name + "' already exists as a parameter in the function at line: " + node.startLine, obj.name,XillPackage.Literals.TARGET__NAME)
                    }
                }
            default: obj.eContents.forEach[obj2|obj2.recursiveCheck(list)]
        }
    }


    @Check
    def includeRobotExists(IncludeStatement includeStatement) {
    	var fqn = includeStatement.library.join(".");
    	var resourceUrl = loader.getRobot(fqn);

        if(resourceUrl === null) {
            error("Could not resolve robot '" + fqn + "'.", includeStatement, XillPackage.Literals.INCLUDE_STATEMENT__LIBRARY)
        } else {
            includeStatement.eResource.resourceSet.getResource(URI.createURI(resourceUrl.toString()), true);
        }

    }

    @Check
    def functionParameterExpressionArgumentCount(FunctionParameterExpression expression) {
        var expectedCount = 1;
        if(expression instanceof ReduceExpression) {
            expectedCount = 2;
        }

        var declaration = expression.function;
        if(declaration.parameters.length != expectedCount) {
            error("Function " + declaration.name + " must accept exactly " + expectedCount + " argument(s) for it to be used as a parameter.", XillPackage.Literals.FUNCTION_PARAMETER_EXPRESSION__FUNCTION)
        }
    }

    @Check
    def noInstructionFlowInErrorBlock(ErrorInstruction errorStatement) {
    	errorStatement.errorBlock.checkFlowControl(false);
    	errorStatement.successBlock.checkFlowControl(false);
    	errorStatement.finallyBlock.checkFlowControl(false);
    }

    def void checkFlowControl(EObject object, boolean canBreak) {
    	if(object === null) {
    		return;
    	}

    	switch(object) {
        	BreakInstruction:
        	if(!canBreak) {
        		error("You can only use the break statement in the 'do' block.", object, XillPackage.Literals.BREAK_INSTRUCTION__TEXT)
    		}
    		ContinueInstruction:
        	if(!canBreak) {
        		error("You can only use the continue statement in the 'do' block.", object, XillPackage.Literals.CONTINUE_INSTRUCTION__TEXT)
    		}
    		ReturnInstruction:
        		error("You can only use the return statement in the 'do' block.", object, XillPackage.Literals.RETURN_INSTRUCTION__TEXT)
			WhileInstruction:
				object.eContents.forEach[obj|obj.checkFlowControl(true)]
			ForEachInstruction:
				object.eContents.forEach[obj|obj.checkFlowControl(true)]
			default:
				object.eContents.forEach[obj|obj.checkFlowControl(canBreak)]
		}


    }


    def InstructionSet getInstructionSet(EObject target) {
        var current = target
        while(!(current === null || current instanceof InstructionSet)) {
            current = current.eContainer
        }
        return current as InstructionSet
    }

    def boolean isAssignable(EObject target) {
        switch(target) {
            Variable: true
            ListExtraction: isAssignable(target.value)
            ExpressionImpl: if(target.class.simpleName.equals("ExpressionImpl")) isAssignable(target.expression) else false
            default: false
        }
    }
}
