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
