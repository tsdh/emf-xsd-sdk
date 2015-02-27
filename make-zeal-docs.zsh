#!/bin/zsh

# Generate the docs into the javadocs/ folder
#javadoc -d javadocs/ emf-jars/org/eclipse/**/*.java

DOCSET="emf-xsd-sdk"

# Create the docset folder
#mkdir -p ${DOCSET}.docset/Contents/Resources/Documents/

# Copy over the javadocs
# cp -R javadocs/* \
#    ${DOCSET}.docset/Contents/Resources/Documents/

# Dowload the Info.plist file and edit it
# wget http://kapeli.com/dash_resources/Info.plist \
#      -O ${DOCSET}.docset/Contents/Info.plist
# sed -i -e 's/nginx/emf-xsd-sdk/' \
#     ${DOCSET}.docset/Contents/Info.plist
# sed -i -e 's/Nginx/EMF XSD SDK/' \
#     ${DOCSET}.docset/Contents/Info.plist

DB="${DOCSET}.docset/Contents/Resources/docSet.dsidx"

# Delete the DB in case it exists
if [[ -f ${DB} ]]; then
    echo "Deleting the old database ${DB}."
    rm ${DB}
fi

# Create the SQLite DB
echo "Creating new database ${DB}"
sqlite3 ${DB} \
	'CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
         CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);'

function insertIntoDB() {
    name=${1}
    type=${2}
    file=${3}
    sqlite3 ../docSet.dsidx \
	    "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('${name}', '${type}', '${file}');"
}

function parseJavaDocFile() {
    # echo "Parsing file ${file}"
    file=${1}
    class=`grep -oP '<title>\K([A-Z].*)(?=</title>)' ${file}`
    if [[ -n ${class} ]]; then
	echo "Found class: ${class}"
	insertIntoDB ${class} "Class" ${file}
    else
	echo "Ignoring ${class} from file ${file}"
    fi
}

cd emf-xsd-sdk.docset/Contents/Resources/Documents/
for file in org/eclipse/**/*.html; do
    parseJavaDocFile ${file}
done
cd -

echo Fini.
