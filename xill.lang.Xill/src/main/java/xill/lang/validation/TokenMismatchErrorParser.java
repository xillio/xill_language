package xill.lang.validation;


import org.antlr.runtime.MismatchedTokenException;
import org.antlr.runtime.RecognitionException;
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage;
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider;

public interface TokenMismatchErrorParser {

    boolean matches(MismatchedTokenException mismatchedTokenException, ISyntaxErrorMessageProvider.IParserErrorContext context);

    SyntaxErrorMessage parse(SyntaxErrorMessage originalError, RecognitionException exception, ISyntaxErrorMessageProvider.IParserErrorContext context);
}
