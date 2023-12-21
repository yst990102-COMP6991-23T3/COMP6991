#!/bin/bash

COURSE_CODE="6991"
ENDPOINT="https://cgi.cse.unsw.edu.au/~cs$COURSE_CODE/current/api"
AUTOTEST_PATH="/home/yst990102/COMP6991/autotest/autotest.py"

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

echoe() {
    echo -e "$@"
}

if [ -n "$ASSIGNDIR" ];
then
    # Running in dryrun
    tar xvf submission.tar >/dev/null
    tar xvf crate.tar >/dev/null
fi

cargo metadata --format-version=1 --no-deps >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
    echoe "${RED}ERROR$ENDCOLOR: You must be in a cargo project to use autotest"
    exit 1
fi

activity_name=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages | .[] | .name' | head -1)
echoe "Found cargo project: $GREEN$activity_name$ENDCOLOR"

workspace_root=$(cargo metadata --format-version=1 --no-deps | jq -r '.workspace_root')
workspace_basename=$(basename $workspace_root)

cd $(mktemp -d)
pwd
tar --exclude='.git' --exclude='.gitignore' --exclude='target' -cvf "crate.tar" -C "$workspace_root" . >/dev/null

curl -s "$ENDPOINT/activity/$activity_name/autotest.tar" 2>/dev/null | tar xv >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
    echoe "${RED}ERROR:$ENDCOLOR No autotests found for $RED$activity_name$ENDCOLOR"
    exit 1
fi

sed -i 's/6991 cargo/cargo/g' tests.txt

echoe "Located autotests for $GREEN$activity_name$ENDCOLOR"
python3 "${AUTOTEST_PATH}" crate.tar -a .