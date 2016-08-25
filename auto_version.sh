#!/bin/sh
# Auto Increment Version Script
# set CFBundleVersion to 1.0.1 first!!!
# the perl regex splits out the last part of a build number (ie: 1.1.1) and increments it by one
# if you have a build number that is more than 3 components, add a '\.\d+' into the first part of the regex.
buildPlist=${INFOPLIST_FILE}
newVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$buildPlist" | /usr/bin/perl -pe 's/(\d+\.\d+\.)(\d+)/$1.($2+1)/eg'`
#echo $newVersion;
/usr/libexec/PListBuddy -c "Set :CFBundleVersion $newVersion" "$buildPlist"