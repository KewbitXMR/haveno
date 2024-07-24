#!/bin/sh

# Ensure java is installed
./install_java.sh

# Run the Gradle Wrapper from the parent directory
../gradlew :daemon:shadowJar