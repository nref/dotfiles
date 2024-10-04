#!/bin/bash

# echo and execute a command
echo_command() {
    local command="$1"
    local echo="${2:-true}"
    if [ "$echo" = true ]; then
        echo "$command"
    fi
    eval "$command"
}

# add, commit, and push changes
gacp() {
    local message="$1"
    echo_command "git add .; git commit -m '$message'; git push"
}

# checkout a branch
gco() {
    local flags="$1"
    echo_command "git checkout $flags"
    gbl
}

# list branches
gb() {
    local flags="$1"
    echo "Listing branches..."
    echo_command "git branch $flags"
}

# list branches by date
gbl() {
    local flags="$1"
    echo "Listing branches by date..."
    echo_command "git branch --list --sort=-committerdate $flags"
}

# delete a branch
gbd() {
    local arguments="$1"
    echo_command "git branch -D $arguments"
}

# show git status
git_status() {
    local flags="$1"
    local arguments="$2"
    echo_command "git status $flags $arguments"
}

# Shortcut for git status
gs() {
    local arguments="$1"
    git_status "" "$arguments"
}

# Shortcut for git status with verbose
gss() {
    local arguments="$1"
    git_status "-v" "$arguments"
}

# run git mergetool
gmt() {
    echo_command "git mergetool"
}

# continue rebase
grc() {
    echo_command "git rebase --continue"
}

# abort rebase
gra() {
    echo_command "git rebase --abort"
}

# rebase onto a new parent
gro() {
    local newparent="$1"
    local oldparent="$2"
    echo_command "git rebase --onto $newparent $oldparent"
}

# continue cherry-pick
gcpc() {
    echo_command "git cherry-pick --continue"
}

# abort cherry-pick
gcpa() {
    echo_command "git cherry-pick --abort"
}

# find a branch using fzf
fzb() {
    local searchString="${1:-}"
    local branches
    branches=$(git branch --sort=-committerdate | sed 's/^\* //')

    local branch
    if [ -n "$searchString" ]; then
        branch=$(echo "$branches" | fzf --filter "$searchString" --select-1 --exit-0)
    else
        branch=$(echo "$branches" | fzf)
    fi

    if [ -n "$branch" ]; then
        branch=$(echo "$branch" | head -n 1)
    fi

    echo "$branch"
}

# delete a branch using fzf
fzd() {
    local searchString="${1:-}"
    local branch
    branch=$(fzb "$searchString")
    if [ -n "$branch" ]; then
        git branch -D "$branch"
    fi
}

# switch to a branch using fzf
fzs() {
    local searchString="${1:-}"
    local branch
    branch=$(fzb "$searchString")
    if [ -n "$branch" ]; then
        git switch "$branch"
    fi
}

# show the log of a branch using fzf
fzl() {
    local searchString="${1:-}"
    local branch
    branch=$(fzb "$searchString")
    if [ -n "$branch" ]; then
        git log "$branch"
    fi
}
