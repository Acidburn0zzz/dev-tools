#!/bin/bash
#
# Add release assets (any files) to an existing tagged release in a github repo.
#
# Usage:
#     add-release-assets TAG asset-files
# where
#     TAG             the github release tag (find your git repo tags with command: hub release)
#     asset-files     the assets to add
#
# Example:
#     cd /mygitrepo
#     add-release-assets v1.0 /mygitrepoassets/*
# would add all files under /myrepoassets to github for the corresponding repo at /mygitrepo.
#
# Note1: requires packages 'hub' (and 'git') to be installed.
# Note2: working folder must be the github repo folder, not the assets folder.
# Note3: adding an already existing asset (file with the same name) simply overwrites the old one.
#
# The assets can be downloaded from:
#     https://github.com/USER/REPONAME/releases/download/TAG

DIE() {
    echo "ERROR: ""$1" >&2
    echo "Usage: $0 TAG asset(s)" >&2
    exit 1
}

Main() {
    local TAG="$1"
    test -n "$TAG" || DIE "TAG is missing."
    test -n "$2" || DIE "assets are missing."

    shift 1               # rest of the parameters are the assets

    local xx
    for xx in hub git ; do
        test -x /usr/bin/$xx || DIE "required package '$xx' is not installed."
    done
    local asset
    local assets=()
    local existing_tags

    # Note: we do this in the git folder, not in the asset folder

    existing_tags="$(hub release)"
    test -n "$existing_tags" || DIE "no existing release tags were found!"

    for xx in $existing_tags ; do
        test "$TAG" = "$xx" && break
    done
    test "$TAG" = "$xx" || DIE "TAG '$TAG' is not in existing tags [$existing_tags]"

    for asset in "$@" ; do
        test -r "$asset" || DIE "asset '$asset' does not exist."
        assets+=("-a" "$asset")
    done

    hub release edit "${assets[@]}" $TAG
}

Main "$@"
