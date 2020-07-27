#!/bin/bash

# config
source=${SOURCE:-.}

cd ${GITHUB_WORKSPACE}/${source}

#get highest tag number
VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

if [ -z "$1" ]
  then
    echo "Version build increment not supplied"
else
    BUILD=$1
    echo "Version build increment supplied: ${BUILD}"
    
fi


if [ -z $VERSION ];then
    NEW_TAG="0.0.1"
    echo "No tag present."
    echo "Creating tag: $NEW_TAG"
    git tag $NEW_TAG
    git push --tags
    echo "Tag created and pushed: $NEW_TAG"
    exit 0;
fi

#replace . with space so can split into an array
VERSION_BITS=(${VERSION//./ })

#get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]}
VNUM2=${VERSION_BITS[1]}
VNUM3=${VERSION_BITS[2]}
 
if [ -z "$BUILD" ]
  then
  VNUM3=$((VNUM3+1))
    NEW_TAG="${VNUM1}.${VNUM2}.${VNUM3}"
    echo "New tag set incrementing patch: ${NEW_TAG}"
else
    NEW_TAG="${VNUM1}.${VNUM2}.${VNUM3}.${BUILD}"
    echo "New tag set with build number: ${NEW_TAG}"
fi

#create new tag

#get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
CURRENT_COMMIT_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

#only tag if no tag already (would be better if the git describe command above could have a silent option)
if [ -z "$CURRENT_COMMIT_TAG" ]; then
    echo "Updating $VERSION to $NEW_TAG"
    # push new tag ref to github
    dt=$(date '+%Y-%m-%dT%H:%M:%SZ')
    git_refs_url=$(jq .repository.git_refs_url $GITHUB_EVENT_PATH | tr -d '"' | sed 's/{\/sha}//g')
    echo "$dt: **pushing tag $NEW_TAG to repo $GITHUB_REPOSITORY"

    curl -s -X POST $git_refs_url \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d @- << EOF
    {
      "ref": "refs/tags/$NEW_TAG",
      "sha": "$GIT_COMMIT"
    }
EOF
echo "::set-output name=tag::$NEW_TAG"
else
    echo "This commit is already tagged as: $CURRENT_COMMIT_TAG"
    echo "::set-output name=tag::$CURRENT_COMMIT_TAG"
fi
