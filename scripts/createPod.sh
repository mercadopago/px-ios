#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Need tag version! Ex: 2.2.9."
    echo "TIP : Specify branch with second argument (by default the branch is master)"
    exit 0
fi

VERSION=$1
PROJECT="MercadoPagoSDK"
PODSPEC_FILE="$PROJECT.podspec"
## Default branch is master
GIT_BRANCH="development"

if [ "$#" -eq 2 ]
  then
  	GIT_BRANCH=$2

fi

cd ..

echo "=========================================="
echo "    Creating POD Project : $PROJECT  "
echo "=========================================="

echo "======================================================"
echo " 0) Delete Pods Cache"
echo "======================================================"
pod cache clean --all

echo "======================================================"
echo " 1) Update podspec file with spec version $VERSION"
echo "======================================================"

awk '/s.version.*/{if (M==""){sub("s.version.*","s.version          = \"'$VERSION'\"");M=1}}{print}' $PODSPEC_FILE > $PODSPEC_FILE.temp
STATUS=$?
if [ $STATUS -ne 0 ]
	then
		rm $PODSPEC_FILE.temp
		echo "Cannot update spec version in podspect file."
		exit 0
fi

cp $PODSPEC_FILE.temp $PODSPEC_FILE
rm $PODSPEC_FILE.temp


echo "=========================================="
echo "2) Validate .podspec --allow-warnings"
echo "=========================================="

pod lib lint --allow-warnings --verbose
STATUS=$?
if [ $STATUS -ne 0 ]
	then
		echo "Error ocurred. Validate podspec."
		exit 0
fi


echo "=========================================="
echo "3) Create tag for version $VERSION from $GIT_BRANCH branch"
echo "=========================================="

git checkout $GIT_BRANCH
git tag $VERSION
git push origin $VERSION
PUSH_STATUS=$?

if [ $PUSH_STATUS -ne 0 ]
	then
		echo "Error ocurred pushing tag."
		exit 0
fi


echo "=========================================="
echo "4) Push podspec into trunk/Specs"
echo "=========================================="
pod trunk push $PODSPEC_FILE --allow-warnings --verbose
POD_TRUNK_STATUS=$?

if [ $POD_TRUNK_STATUS -ne 0 ]
	then
		echo "Error ocurred pushing pod into trunk."
		exit 0
fi

echo "=========================================="
echo "		Pod created from tag $VERSION. 		"
echo " 			Versions available in 			"
echo "https://github.com/CocoaPods/Specs/tree/master/Specs/$PROJECT"
echo "=========================================="
