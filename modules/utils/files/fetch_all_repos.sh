#!/bin/bash


set -x
for repo in ~/src/*; do
    cd $repo;
    git fetch;
done
