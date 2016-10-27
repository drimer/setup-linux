_list_commit_refs() {
    git log | awk '/^commit/ {print $2}';
}

git-diff-prev() {
    all_refs=$(_list_commit_refs)
    ref=$(git log | awk '/^commit/ {print $2}' | head -2 | tail -1)
    git diff $ref
}

git-diff-branch() {
    base_branch=$1
    ref=0
    for commit in $(_list_commit_refs); do
	git branch -a --contains $commit | grep -q $base_branch && {
	    ref=$commit;
	    break;
	}
    done

    [[ "$ref" != 0 ]] && {
	git diff $ref;
    } || {
	echo "Can't do it";
    }
}

_gsfc() {
    gsf "git checkout $1 || :"
}
alias gsfc="_gsfc"

alias gsf="git sfe"

_git_list_files_changed() {
    for c in $(awk {'print $1'}); do
        git show $c | grep -q "$1" && echo $c;
    done
}
alias git-list-files-changed="_git_list_files_changed"

alias gitrev="git rev-parse HEAD"
