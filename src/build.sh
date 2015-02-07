#!/bin/bash
# variables declaration
ultimateCMSDir="../../de.plugins-zum-selberbauen.ultimate/"
buildDir="../Ultimate-CMS-Minify-JS/src/"
configFile="config.txt"
yuiFile="yuicompressor-2.4.8.jar"

# create config file if not existing
touch "$configFile"

lastCheckedCommit="$(cat $configFile)"

# determining modified JS files
cd "$ultimateCMSDir"
git checkout master
git pull
if [ "$lastCheckedCommit" = "" ]; then
	# minimize all JS files
	ls src/js/*.js src/acp/js/*.js | \
	grep "\.js$" | \
	xargs -d "\n" -n 1 -r \
	java -jar "$buildDir$yuiFile" \
	 --preserve-semi -o ".js$:.min.js"
else
	# minimize changed JS files
	git diff --name-status "$lastCheckedCommit" HEAD | \
	grep -v "^D" | \
	sed "s/^.\s*//" | \
	grep "\.js$" | \
	xargs -d "\n" -n 1 -r \
	java -jar "$buildDir$yuiFile" \
	 --preserve-semi -o ".js$:.min.js"
fi

# commit changes
git add --all
git commit -m "Updating minified JavaScript files"
git push origin master

# save current commit to config.txt
git rev-parse HEAD > "$buildDir$configFile"
