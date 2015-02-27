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

# $1 = name
# $2 = type
# $3 = link
function insertIntoDB() {
    sqlite3 ../docSet.dsidx \
	    "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('${1}', '${2}', '${3}');"
}

function compressDetails() {
    local line=""
    while IFS= read -r l; do
	echo $l
	if [[ $l == -- ]]; then
	    print -r - $line
	    line=""
	else
	    line+=${l}
	fi
    done
    if [[ -n ${line} ]]; then
	print -r - $line
    fi
}

# $1 = class
# $2 = type
# $3 = file
function parseDetails() {
    local anchor
    local thing
    while IFS= read -r l; do
	anchor=$(echo ${l} | grep -oP '<a name="\K.*?(?=">.*)')
	thing=$(echo ${l} | grep -oP '<h4>\K.*(?=</h4>)')
	if [[ -n ${anchor} && -n ${thing} ]]; then
	    echo "  --> ${2} ${thing}"
	    if [[ ${thing} == ${1} && ${2} != "Constructor" ]]; then
		# Inserting a Class/Enum/Interface
		insertIntoDB "${thing}" ${2} "${3}#${anchor}"
	    else
		# Inserting a Field or Method or Constructor
		insertIntoDB "${thing} (${1})" ${2} "${3}#${anchor}"
	    fi
	fi
    done
}

# $1 = class
# $2 = file
# $3 = type
# $4 = rx
function parseFileDetails() {
    sed -n "/=\+ ${4} DETAIL =\+/,/========/p" ${2} \
	| grep -P -B5 '<h4>.*</h4>' \
	| compressDetails \
    	| parseDetails ${1} ${3} ${2}
}

# $1 = file
function parseJavaDocFile() {
    local class
    class=$(grep -oP '<h2 title="[^"]+" class="title">\K(Interface|Class|Enum).*(?=</h2>)' ${1})
    if [[ -n ${class} ]]; then
	local -a a
	a=(${(s/ /)class})
	echo "--> $a[1] $a[2]"
	insertIntoDB $a[2] $a[1] ${1}
	# Fields
	parseFileDetails $a[2] ${1} "Field" "FIELD"
	# Constructors
	parseFileDetails $a[2] ${1} "Constructor" "CONSTRUCTOR"
	# Methods
	parseFileDetails $a[2] ${1} "Method" "METHOD"
    else
	echo "Ignoring file ${file}"
    fi
}

cd emf-xsd-sdk.docset/Contents/Resources/Documents/
for file in org/eclipse/**/*.html; do
    parseJavaDocFile ${file}
done
cd -

echo Fini.
