#!/bin/bash
function usage() {
    printf "Shortcut git utility for Git For Windows\n"
    printf "\tUsage: g [arg]\n"
    echo "g h   help"
    echo "g nb  new branch"
    echo "g su  set upstream"
    echo "g cb  current branch"
    echo "g ab  all branches"
    echo "g cm  checkout master"
    echo "g sb  checkout [branchName]"
    echo "g gl  get pretty log"
    echo "g aa  add all open files"
    echo "g p   push to remote"
    echo "g pl  pull from remote"
    echo "g u   undo all uncommited changes"
    echo "g co  undo [file]"
    echo "g s   check status of non committed files"
    echo "g db  delete branch"
    echo "g ui  use git gui"
}

function newbranch() {
    if [ "$1" = " " ]; then
        echo "Must specify new branch name!";
        exit 1;
    fi
    echo "Creating new branch: $1"
    git checkout -b $1
    exit 0
}

function setupstream() {
    BRANCH= git symbolic-ref --short HEAD

    git push --set-upstream origin $BRANCH
}

if [ "$1" = "h" ]; then usage ; fi
if [ "$1" = ""  ]; then usage ; fi
if [ "$1" = "nb" ]; then newbranch "$2" ; fi
if [ "$1" = "su" ]; then setupstream ; fi


if [ "$1" = "cb" ]; then git symbolic-ref --short HEAD; fi
if [ "$1" = "cl" ]; then git clone $2; fi
if [ "$1" = "ab" ]; then git branch; fi
if [ "$1" = "cm" ]; then git checkout master; fi
if [ "$1" = "sb" ]; then git checkout $2; fi
if [ "$1" = "gl" ]; then git log --pretty=oneline --abbrev-commit; fi
if [ "$1" = "aa" ]; then git add .; fi
if [ "$1" = "p"  ]; then git push; fi
if [ "$1" = "pl" ]; then git pull; fi
if [ "$1" = "co" ]; then git checkout -- $2; fi
if [ "$1" = "u"  ]; then git checkout -- .; fi
if [ "$1" = "s"  ]; then git status; fi
if [ "$1" = "c"  ]; then git commit -m $2; fi
if [ "$1" = "db" ]; then git branch -d $2; fi
if [ "$1" = "ui" ]; then git gui; fi