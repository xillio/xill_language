package xill.lang.validation;

import org.antlr.runtime.MismatchedTokenException;
import org.antlr.runtime.MissingTokenException;
import org.antlr.runtime.RecognitionException;
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage;
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider;


public class UseIncludeKeywordErrorParser implements TokenMismatchErrorParser {
    @Override
    public boolean matches(MismatchedTokenException mismatchedTokenException, ISyntaxErrorMessageProvider.IParserErrorContext context) {

        return mismatchedTokenException instanceof MissingTokenException &&
                ((MissingTokenException) mismatchedTokenException).inserted.toString().contains("EOF") &&
                mismatchedTokenException.token.getText().equals("use") &&
                mismatchedTokenException.expecting == -1;
    }

    @Override
    public SyntaxErrorMessage parse(SyntaxErrorMessage originalError, RecognitionException exception, ISyntaxErrorMessageProvider.IParserErrorContext context) {
        return new SyntaxErrorMessage("Please declare all use statements before any other code", originalError.getIssueCode(), originalError.getIssueData());
    }
}
