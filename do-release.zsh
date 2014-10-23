#!/bin/zsh

echo "Unzipping jars in emf-jars/..."
cd emf-jars/
for x in *.jar; do
    unzip -o $x;
done
cd ..
rm -rf emf-jars/META-INF/

echo "Creating an JAR"
lein jar

file=target/emf-xsd-sdk-2.10.1.jar

if [[ ! -f ${file} ]]; then
    echo "Error: ${file} doesn't exist!"
    exit 1
fi

echo "Are you really sure you want to upload ${file} to clojars.org?"
echo "Hit Ctrl-C to abort, or RETURN to upload."
read

echo "Deploying to Clojars"
lein deploy clojars

echo "Fini."
