#!/bin/sh

function info() {
    echo "Docker shell utils by LYC"
}

if [[ "$#" != 0 ]]; then
    cmd="$1"
    shift 1
    $cmd $@
fi
