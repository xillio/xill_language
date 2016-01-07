package xill.lang

import xill.lang.validation.XillSyntaxErrorProvider
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider
import xill.lang.validation.ReservedKeywordErrorParser
import com.google.inject.Provides
import xill.lang.validation.UseIncludeKeywordErrorParser

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class XillRuntimeModule extends AbstractXillRuntimeModule {

    @Provides
    def ISyntaxErrorMessageProvider errorMessageProvider() {
        new XillSyntaxErrorProvider(#[
            new UseIncludeKeywordErrorParser(),
            new ReservedKeywordErrorParser()
        ])
    }
}
