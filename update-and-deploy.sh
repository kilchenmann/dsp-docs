#!/bin/bash

set -e

home=$(pwd)
sep='---------------------------------'

die() {
    echo >&2 "$@"
    exit 1
}

usage() {
    echo "usage: <command> dsp=[main version] api=[api version] app=[app version] tools=[tools version] deploy=[false]"
    echo ${sep}
}

v=""
api=""
app=""
tools=""

deploy=false

for ARGUMENT in "$@"; do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)

    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"
    if [[ $KEY == "dsp" ]]; then
        echo "Prepare new release ${VALUE}"
        v=$VALUE
        echo $sep
        echo $sep
    elif [[ $KEY == "deploy" ]]; then
        deploy=$VALUE
    else
        echo "Update submodule dsp-${KEY} ${VALUE}"
        cd dsp/dsp-${KEY}
        echo $(pwd)
        git checkout ${VALUE}
        cd ${home}
        git add dsp/dsp-${KEY}
        echo $sep
    fi
done



# set alias: default is latest, rc is prerelease
alias="latest"
if [[ $v == *"-rc"* ]]; then
    echo "This version is a release candidate"
    alias="prerelease"
fi

if [ $deploy = false ]; then
    die "do not deploy"

else
    # generates images from dot files
    make graphvizfigures

    echo "Deploy version ${v} to github pages now"
    mike deploy --push --branch gh-pages --update-aliases ${v} ${alias}

    # keep the latest stable version as default
    mike set-default --push --branch gh-pages latest
    echo $sep
    
    echo "Update main branch"
    git commit -m "Deploy DSP version ${v}"
fi





