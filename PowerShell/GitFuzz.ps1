function echo-command([string] $command, [bool] $echo = $true) {
    if ($echo) { 
      write-host $command 
    }
    iex $command
}

function tail() {
    Get-Content $args[0] -wait
}

function gacp([string] $message) {
    echo-command("git add .; git commit -m '$message'; git push")
}

function gco([string] $flags) {
    echo-command("git checkout $flags")
    iex gbl
}

function gb([string] $flags) {
    write-host "Listing branches..."
    echo-command("git branch $flags")
}

function gbl([string] $flags) {
    write-host "Listing branches by date..."
    echo-command("git branch --list --sort=-committerdate $flags")
}

function gbd([string] $arguments) {
    echo-command("git branch -D $arguments")
}

function git-status([string] $flags, [string] $arguments) {
    echo-command("git status $flags $arguments")
}

function gs([string] $arguments) {
    git-status("", $arguments)
}

function gss([string] $arguments) {
    git-status("-v", $arguments)
}

function gmt([string] $arguments) {
    echo-command("git mergetool")
}

function grc([string] $arguments) {
    echo-command("git rebase --continue")
}

function gra([string] $arguments) {
    echo-command("git rebase --abort")
}

function gro([string] $newparent, $oldparent) {
    echo-command("git rebase --onto $newparent $oldparent")
}

function gcpc([string] $arguments) {
    echo-command("git cherry-pick --continue")
}

function gcpa([string] $arguments) {
    echo-command("git cherry-pick --abort")
}

# "FuzzyBranch"
# Return the first matching branch with FuzzyFind
# or if no query is given, search interactively
# scoop install fzf
function fzb {
    param (
        [string]$searchString = ""
    )

    $branches = git branch --sort=-committerdate | ForEach-Object { $_ -replace '^\* ', '' }
   
    $branch = "";
    if ($searchString) {
        $branch = $branches | fzf --filter $searchString --select-1 --exit-0
    } else {
        $branch = $branches | fzf
    }

    if ($branch) {
        $branch = $branch -split "`n" | Select-Object -First 1
    }

    return $branch.Trim()
}

# "FuzzyDelete"
# Delete first matching branch
function fzd {
    param (
        [string]$searchString = ""
    )

    $branch = fzb -searchString $searchString
    if ($branch) {
        git branch -D $branch
    }
}

# "FuzzySwitch"
# Switch to first matching branch
function fzs {
    param (
        [string]$searchString = ""
    )

    $branch = fzb -searchString $searchString
    if ($branch) {
        git switch $branch
    }
}

# "FuzzyLog"
# Show the log of the first matching branch 
function fzl {
    param (
        [string]$searchString = ""
    )

    $branch = fzb -searchString $searchString
    if ($branch) {
        git ll $branch
    }
}
