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
package xill.lang

import xill.lang.validation.XillSyntaxErrorProvider
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider
import xill.lang.validation.ReservedKeywordErrorParser
import xill.lang.validation.UseIncludeKeywordErrorParser
import xill.RobotLoader
import com.google.inject.Binder
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.service.SingletonBinding

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class XillRuntimeModule extends AbstractXillRuntimeModule {

	private RobotLoader loader;
	private ISyntaxErrorMessageProvider errorMessageProvider;

	new(RobotLoader robotLoader) {
		loader = robotLoader;
		this.errorMessageProvider = new XillSyntaxErrorProvider(#[
			new UseIncludeKeywordErrorParser(),
			new ReservedKeywordErrorParser()
		]);
	}

	new() {
		throw new IllegalArgumentException("Please provide a RobotLoader.");
	}

	override configure(Binder binder) {
		super.configure(binder);
		binder.bind(RobotLoader).toInstance(loader);
		binder.bind(ISyntaxErrorMessageProvider).toInstance(errorMessageProvider);
	}


	@SingletonBinding
	override Class<? extends ResourceSet> bindResourceSet() {
		return XillResourceSet;
	}

	@SingletonBinding
	override Class<? extends XtextResourceSet> bindXtextResourceSet() {
		return XillResourceSet;
	}

	@SingletonBinding
	def Class<? extends XillResourceSet> bindXillResourceSet() {
		return XillResourceSet;
	}
}
