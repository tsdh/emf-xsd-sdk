#!/bin/zsh

echo "Unzipping jars in emf-jars/..."
cd emf-jars/
for x in *.jar; do
    unzip -o $x;
done
cd ..
rm -rf emf-jars/META-INF/

echo "Creating an Uberjar"
lein uberjar

echo "Creating a pom.xml"
lein pom

file=`ls target/emf-xsd-sdk-*-standalone.jar`

if [[ ! -f ${file} ]]; then
    echo "Error: ${file} doesn't exist!"
    exit 1
fi

echo "Moving ${file} to ${file/-standalone/}."
mv ${file} ${file/-standalone/}
file=${file/-standalone/}

cmd="scp pom.xml ${file} clojars@clojars.org:"

echo "Are you really sure you want to upload ${file} to clojars.org?"
echo "  Command: ${cmd}"
echo "Hit Ctrl-C to abort, or RETURN to upload."
read

eval ${cmd}

echo "Fini."
