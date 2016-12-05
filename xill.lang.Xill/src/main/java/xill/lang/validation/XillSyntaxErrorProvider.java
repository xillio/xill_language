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
package xill.lang.validation;

import org.antlr.runtime.MismatchedTokenException;
import org.antlr.runtime.RecognitionException;
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage;
import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider;

import java.util.List;


public class XillSyntaxErrorProvider extends SyntaxErrorMessageProvider {
    /*
    override getSyntaxErrorMessage(IParserErrorContext context) {
        var error = super.getSyntaxErrorMessage(context)
        var exception = context.recognitionException;

        switch(exception) {
            MismatchedTokenException: {
                //Exprected `RULE_ID` got `something`
                if(exception.expecting == context.tokenNames.indexOf("RULE_ID")) {
                    //Reserved keywords
                    if(XillValidator.RESERVED_KEYWORDS.contains(exception.token.text)) {
                        error = new SyntaxErrorMessage("Incorrect use of reserved keyword `" + exception.token.text + "`. Expected valid identifier.", error.issueCode, error.issueData)
                    }
                } else if(exception.expecting == context.tokenNames.indexOf("RULE_ID")) {

                }
            }
        }

        return error;
    }

    override getSyntaxErrorMessage(IValueConverterErrorContext context) {
        super.getSyntaxErrorMessage(context)
    }
     */
    private final List<TokenMismatchErrorParser> parsers;

    public XillSyntaxErrorProvider(List<TokenMismatchErrorParser> parsers) {
        this.parsers = parsers;
    }

    @Override
    public SyntaxErrorMessage getSyntaxErrorMessage(IParserErrorContext context) {
        RecognitionException exception = context.getRecognitionException();
        SyntaxErrorMessage error = super.getSyntaxErrorMessage(context);

        if (exception instanceof MismatchedTokenException) {
            MismatchedTokenException mismatchedTokenException = (MismatchedTokenException) exception;

            TokenMismatchErrorParser parser = getParser(mismatchedTokenException, context);

            if (parser != null) {
                error = parser.parse(error, exception, context);
            }

        }


        return error;
    }

    private TokenMismatchErrorParser getParser(final MismatchedTokenException mismatchedTokenException, final IParserErrorContext context) {
        return parsers.stream().filter(parser -> parser.matches(mismatchedTokenException, context)).findFirst().orElse(null);
    }
}
