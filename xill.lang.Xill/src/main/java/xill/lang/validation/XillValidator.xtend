/*
 * generated by Xtext
 */
package xill.lang.validation

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.validation.Check
import xill.lang.xill.Assignment
import xill.lang.xill.FunctionCall
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
import com.google.inject.Inject
import javax.inject.Named
import java.io.File

//import org.eclipse.xtext.validation.Check

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
        "callbot","argument",
        "map", "filter",
        "private"
    ];

    @Inject
    @Named("projectFolder")
    private File projectFolder

    @Check
    def checkExtractionNotOnLiterals(ListExtraction extraction) {
        if(extraction.value.expression instanceof Literal) {
            error("Cannot extract element from a literal.",extraction, if(extraction.child == null) XillPackage.Literals.LIST_EXTRACTION__INDEX else XillPackage.Literals.LIST_EXTRACTION__CHILD);
        }
    }

    @Check
    def functionDeclarationOnlyOnRootLevel(FunctionDeclaration function) {
        if(!(function.eContainer.eContainer instanceof Robot)) {
            error("Cannot declare functions in closure.", function, XillPackage.Literals.FUNCTION_DECLARATION__NAME);
        }
    }

    @Check
    def parameterCountMatchArguments(FunctionCall call) {
        if(call.argumentBlock.parameters.size != call.name.parameters.size) {
            error("Mismatched parameter count.", call.argumentBlock, XillPackage.Literals.ARGUMENT_BLOCK__PARAMETERS)
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
    def noDuplicateFunctionNames(FunctionDeclaration declaration) {
        var parentSet = declaration.instructionSet;

        for(FunctionDeclaration other : parentSet.instructions.filter(FunctionDeclaration)) {
            if(other != declaration && other.name == declaration.name) {
                var node = NodeModelUtils.getNode(other);

                error("A function with this name already exists at line: " + node.startLine, XillPackage.Literals.FUNCTION_DECLARATION__NAME);
            }
        }
    }

    @Check
    def includeRobotExists(IncludeStatement includeStatement) {
        var path = includeStatement.name.join(File.separator) + ".xill"
        var robotFile = new File(projectFolder, path);
        if(!robotFile.exists()) {
            error("Could not find robot '" + robotFile.getCanonicalPath() + "'.", includeStatement, XillPackage.Literals.INCLUDE_STATEMENT__NAME)
        }

    }

    def InstructionSet getInstructionSet(EObject target) {
        var current = target
        while(!(current == null || current instanceof InstructionSet)) {
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