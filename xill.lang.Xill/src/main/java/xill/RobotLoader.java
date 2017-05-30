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
package xill;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

/**
 * A loader which can be used to load robots or resources.
 * When a resource or robot is requested, the loader will first check its parent loader (if not null) before trying to locate the resource itself.
 * <p>
 * The robot loader uses fully qualified names to load robots.
 * A fully qualified name is constructed from all the parent packages of a robot and its name,
 * separated by a period (".") and without the file extension.
 * For example, a robot located at {@code module/import/main.xill} will have the fully qualified name {@code module.import.main}.
 * <p>
 * To load resources the robot loader uses paths.
 * Since these paths are relative they should not start with a leading slash ("/").
 * <p>
 * All methods of the robot loader will return {@code null} if the resource or robot could not be located.
 * If a resource could in fact be located but a stream could not be created an {@code IOException} will be thrown.
 *
 * @author Luca Scalzotto
 */
public interface RobotLoader extends AutoCloseable {
    /**
     * Get the parent RobotLoader.
     *
     * @return the parent loader or null if not present
     */
    RobotLoader getParentLoader();

    /**
     * Locate a robot for a fully qualified name.
     *
     * @param fullyQualifiedName the fully qualified name
     * @return the robot or null if none was found
     * @throws IllegalArgumentException if the input is not a valid fully qualified name
     */
    URL getRobot(String fullyQualifiedName);

    /**
     * Locate a robot for a fully qualified name and open a stream to it.
     *
     * @param fullyQualifiedName the fully qualified name
     * @return the robot stream or null if none was found
     * @throws IllegalArgumentException if the input is not a valid path
     * @throws IOException              if the stream could not be opened
     */
    InputStream getRobotAsStream(String fullyQualifiedName) throws IOException;

    /**
     * Locate a resource for a path.
     *
     * @param path the path
     * @return the resource or null if none was found
     * @throws IllegalArgumentException if the input is not a valid fully qualified name
     */
    URL getResource(String path);

    /**
     * Locate a resource for a path and open a stream to it.
     *
     * @param path the path
     * @return the resource stream or null if none was found
     * @throws IllegalArgumentException if the input is not a valid path
     * @throws IOException              if the stream could not be opened
     */
    InputStream getResourceAsStream(String path) throws IOException;

    /**
     * Close the robot loader.
     *
     * @throws IOException if an I/O exception occurred
     */
    void close() throws IOException;
}