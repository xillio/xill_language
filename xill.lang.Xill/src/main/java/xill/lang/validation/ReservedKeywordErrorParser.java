package xill.lang.validation;


import org.antlr.runtime.MismatchedTokenException;
import org.antlr.runtime.RecognitionException;
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage;
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider;
import org.eclipse.xtext.util.Arrays;

public class ReservedKeywordErrorParser implements TokenMismatchErrorParser {
    @Override
    public boolean matches(MismatchedTokenException mismatchedTokenException, ISyntaxErrorMessageProvider.IParserErrorContext context) {
        return Arrays.contains(XillValidator.RESERVED_KEYWORDS, mismatchedTokenException.token.getText());
    }

    @Override
    public SyntaxErrorMessage parse(SyntaxErrorMessage originalError, RecognitionException exception, ISyntaxErrorMessageProvider.IParserErrorContext context) {
        return new SyntaxErrorMessage("Incorrect use of reserved keyword " + exception.token.getText() + ".", originalError.getIssueCode(), originalError.getIssueData());
    }
}
