#!/bin/bash

# I wrote this script because I find it tedious to have to backup my config
# files, set up my directories such as a bin/ for the binaries I use or the
# Python path I use with my own libraries. Though one way of avoiding this
# is using a different partition for the /home mount point, sometimes it is
# desirable to make a clean installation, or you just want to install another
# Linux distribution to play with it, and you don't want it to have the same
# /home as your day-to-day Linux.

# Different puppet manifests can be used (e.g. devel.pp) in order set up the
# system with a different profile.

# How to extend this script:
#   It uses Puppet manifests, and different modules can be specified. A top
#   manifest file will include a different set of modules. You can:
#   - Add your own modules and include them in an existing manifest file.
#   - Add your own manifest file that includes the set of modules you are
#     interested in.

usage() { echo "$0 <manifest.pp>"; }

process_in_files() {
    for in_file in $(find . -name "*.in"); do
	processed_file=$(echo $in_file | sed -e 's,\.in,,g')
	cp $in_file $processed_file
	sed -e "s,@HOME_DIR@,$HOME,g" -i "$processed_file"
    done
}

delete_processed_files() {
    for in_file in $(find . -name "*.in"); do
	processed_file=$(sed -e 's,\.in,,g' <(echo $in_file))
	rm $processed_file
    done    
}

ensure_puppet_installed() {
    puppet >/dev/null 2>&1 || apt-get install -y puppet
}

main() {
    [[ $# != 1 ]] && { usage; exit 1; }
    [[ $EUID != 0 ]] && { echo "No root privileges"; exit 1; }

    ensure_puppet_installed

    process_in_files
    puppet apply --modulepath=modules $1
    delete_processed_files
}

main $*
