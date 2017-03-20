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

import org.eclipse.xtext.resource.SynchronizedXtextResourceSet
import org.apache.log4j.Logger
import org.apache.log4j.LogManager
import com.google.inject.Inject
import xill.RobotLoader
import org.eclipse.emf.ecore.resource.Resource
import java.util.Map
import java.util.HashMap
import java.net.URL
import org.eclipse.emf.common.util.URI
import com.google.inject.Singleton

/**
 * This ResourceSet provides a resource loader that keeps track of internal resource paths.
 * 
 * @author Thomas Biesaart
 */
@Singleton
class XillResourceSet extends SynchronizedXtextResourceSet {
	private final Map<URI, String> resourcePathMapping = new HashMap<URI, String>();
	private static final Logger LOGGER = LogManager.getLogger(XillResourceSet);

	@Inject
	RobotLoader robotLoader

	def Resource getRobotResource(String fullyQualifiedName) {

		var resource = robotLoader.getRobot(fullyQualifiedName).resource;

		if (resource === null) {
			return null;
		}

		resourcePathMapping.put(resource.URI, fullyQualifiedName.replace('.', '/') + ".xill");
		return resource;
	}

	def Resource getResource(String resourcePath) {

		var resource = robotLoader.getResource(resourcePath).resource;

		if (resource === null) {
			return null;
		}

		resourcePathMapping.put(resource.URI, resourcePath);
		return resource;
	}

	def String getInternalResourcePath(URI uri) {
		return resourcePathMapping.get(uri);
	}

	private def Resource getResource(URL url) {
		if (url === null) {
			return null;
		}

		var resource = super.getResource(URI.createURI(url.toString()), true);

		if (resource === null) {
			return null;
		}

		return resource;
	}

	override public getResource(URI uri, boolean autoload) {
		if (uri.path.endsWith(".xill") && !resourcePathMapping.containsKey(uri)) {
			var error = new IllegalAccessError(
				"Do not call this method. Use getResource(String) or getRobotResource(String) instead!"
			);
			LOGGER.error("XillResourceSet.getResource was called for '" + uri + "'.", error);
			throw error;
		}
		return super.getResource(uri, autoload);
	}

}
