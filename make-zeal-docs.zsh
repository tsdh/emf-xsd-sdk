#!/bin/zsh

DOCSET="EMF_XSD_SDK.docset"

if [[ -d ${DOCSET} ]]; then
    echo "Deleting the old ${DOCSET} directory"
    rm -rf ${DOCSET}
fi

# Create the docset folder
mkdir -p ${DOCSET}/Contents/Resources/Documents/

# Generate the docs
javadoc -d ${DOCSET}/Contents/Resources/Documents/ \
	emf-jars/org/eclipse/**/*.java

# Create the Info.plist
cat <<EOF > ${DOCSET}/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>emf-xsd-sdk</string>
  <key>CFBundleName</key>
  <string>EMF XSD SDK</string>
  <key>DocSetPlatformFamily</key>
  <string>emf-xsd-sdk</string>
  <key>isDashDocset</key>
  <true/>
  <key>dashIndexFilePath</key>
  <string>overview-summary.html</string>
</dict>
</plist>
EOF

# Create the meta.json
cat <<EOF > ${DOCSET}/meta.json
{
    "aliases": [],
    "feed_url": "",
    "icon": "lisp",
    "name": "emf-xsd-sdk",
    "oldVersions": [],
    "revision": "1",
    "source": "tsdh",
    "title": "EMF XSD SDK",
    "urls": [],
    "version": ""
}
EOF

DB="${DOCSET}/Contents/Resources/docSet.dsidx"

# Create the SQLite DB
echo "Creating new database ${DB}"
sqlite3 ${DB} \
	'CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
         CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);'

function htmlEscape() {
    echo ${1} | sed -e 's/&lt;/</' | sed -e 's/&gt;/>/'
}

# $1 = name
# $2 = type
# $3 = link
function insertIntoDB() {
    local name
    name=$(htmlEscape ${1})
    sqlite3 ../docSet.dsidx \
	    "INSERT OR IGNORE INTO searchIndex(name, type, path)
             VALUES ('${name}', '${2}', '${3}');"
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
	    local type=${2}
	    if [[ ${type} == "Field" && ${thing} =~ "^[A-Z0-9_]+$" ]]; then
		# All-uppercase fields are usually constants
		type="Constant"
	    fi
	    echo "   |--> ${type} ${thing}"
	    if [[ ${thing} == ${1} && ${type} != "Constructor" ]]; then
		# Inserting a Class/Enum/Interface
		insertIntoDB "${thing}" ${type} "${3}#${anchor}"
	    else
		# Inserting a Field or Method or Constructor
		insertIntoDB "${thing} (${1})" ${type} "${3}#${anchor}"
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
	echo "====> $a[1] $a[2]"
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

cd ${DOCSET}/Contents/Resources/Documents/
for file in org/eclipse/**/*.html; do
    parseJavaDocFile ${file}
done
cd -

# Add icons
cp emf-jars/modeling32.png ${DOCSET}/icon@2x.png
convert -scale 16x16 ${DOCSET}/icon@2x.png ${DOCSET}/icon.png

echo Fini.
