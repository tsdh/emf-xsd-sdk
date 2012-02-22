#!/bin/zsh

echo "Creating an Uberjar"
lein uberjar

echo "Creating a pom.xml"
lein pom

file=`ls emf-xsd-sdk-*-standalone.jar`
cmd="scp pom.xml ${file} clojars@clojars.org:"

echo "Are you really sure you want to upload ${file} to clojars.org?"
echo "  Command: ${cmd}"
echo "Hit Ctrl-C to abort, or RETURN to upload."
read

${cmd}

echo "Fini."
