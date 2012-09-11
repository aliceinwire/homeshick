#!/bin/bash

# Get the repo name from an URL
function parse_url {
	local regexp_extended_flag='r'
	local system=`uname -a`
	if [[ $system =~ "Darwin" && ! $system =~ "AppleTV" ]]; then
		regexp_extended_flag='E'
	fi
	printf -- "$1" | sed -$regexp_extended_flag 's#^.*/([^/.]+)(\.git)?$#\1#'
}

function clone {
	local repo_path="$repos/`parse_url $1`"
	test -e $repo_path && die "     $bldblu exists $txtdef $repo_path"
	local git_repo=$1
	if [[ $git_repo =~ ^([A-Za-z_-]+\/[A-Za-z_-]+)$ ]]; then
		git_repo="git://github.com/$1.git"
	fi
	pending 'clone' $git_repo
	if [ -z "$B_PRETEND" ]; then
		git clone --quiet $git_repo $repo_path
		if [ $? != 0 ]; then
			err "Unable to clone $git_repo"
		fi
	fi
	success
	pending 'submodules' $git_repo
	if [ -z "$B_PRETEND" ]; then
		(cd $repo_path; git submodule --quiet update --init)
	fi
	success
}

function generate {
	pending 'generate' $1
	if [ -z "$B_PRETEND" ]; then
		mkdir -p $1
		(cd $1; git init --quiet)
		mkdir -p home
	fi
	success
}

function pull {
	local repo="$repos/$1"
	castle_exists 'pull' $1
	pending 'pull' $1
	if [ -z "$B_PRETEND" ]; then
		(cd $repo;
			git pull --quiet;
			git submodule --quiet update --init)
	fi
	success
}

function list {
	if [ `(find $repos -type d; find $repos -type l)  | wc -l` -lt 2 ]; then
		err "No castles exist for homeshick in: $repos"
	fi
	for repo in `echo "$repos/*"`; do
		remote_url=$(cd $repo; git config remote.origin.url)
		reponame=`basename $repo`
		status $bldblu $reponame $remote_url
	done
}
