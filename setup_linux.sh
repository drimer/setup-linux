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

# Dependencies:
# - puppet >= 2.7.18 (1)


# The following links provide information on how to meet this script's
# dependencies:
#
# http://puppetlabs.com/

POST_SCRIPT_FILENAME="./post_script.sh"

usage() { echo "$0 <manifest.pp> [<manifest2.pp>, ...]"; }

process_in_files() {
    [[ -n $SUDO_USER ]] && username=$SUDO_USER || username=$USER

    for in_file in $(find . -name "*.in"); do
	processed_file=$(echo $in_file | sed -e 's,\.in,,g')
	cp $in_file $processed_file
	sed -e "s,@HOME_DIR@,$HOME,g" -i "$processed_file"
	sed -e "s,@USERNAME@,$username,g" -i "$processed_file"
    done
}

delete_processed_files() {
    for in_file in $(find . -name "*.in"); do
	processed_file=$(sed -e 's,\.in,,g' <(echo $in_file))
	rm $processed_file
    done    
}

ensure_puppet_version() {
    installed_version=$(puppet --version)

    python -c \
"from distutils.version import StrictVersion; \
assert StrictVersion('$installed_version') >= StrictVersion('2.7.18')"

    [[ $? != 0 ]] && {
        echo "Installed puppet version is $installed_version. I need it to be" \
             "older than 2.7.18 so that I can use the command 'puppet" \
             "module'.";
        exit -1;
    }
}

ensure_puppet_installed() {
    puppet >/dev/null 2>&1 || {
        echo "The command 'puppet' not found in your system. Please make sure" \
             "it is installed.";
	exit -1;
    }

    ensure_puppet_version

    [[ $(puppet module list | grep puppetlabs-stdlib) ]] || {
	puppet module install puppetlabs/stdlib
    }
}

print_manual_setup() {
    cat manual_steps.txt
    echo ""
    cat extra_notes.txt
}

patch_before_devel.pp() {
    [[ -f $HOME/.tmux.conf ]] && cp -f $HOME/.tmux.conf $HOME/.tmux.conf.bak
}

patch_after_devel.pp() {
    cp -f $HOME/.tmux.conf.bak $HOME/.tmux.conf
    rm -f $HOME/.tmux.conf.bak

    git_user_file="$HOME/.gitconfig.extra"
    [[ -s $git_user_file ]] && [[ -z "$(grep '\[user\]' $HOME/.gitconfig)" ]] && {
	echo "Patching ~/.gitconfig"
	echo "" >>$HOME/.gitconfig
	cat $git_user_file >>$HOME/.gitconfig
    }
}

patch_before_utils.pp() {
    [[ -f $HOME/bin/backup ]] && cp -f $HOME/bin/backup $HOME/bin/backup.bak
}

patch_after_utils.pp() {
    cp -f $HOME/bin/backup.bak $HOME/bin/backup
    rm -f $HOME/bin/backup.bak
}

main() {
    [[ $# < 1 ]] && { usage; exit 1; }
    [[ $EUID != 0 ]] && { echo "WARNING: No root privileges. Some things will not be done."; }

    ensure_puppet_installed

    process_in_files
    echo "During setup, some windows might pop up, which will require manual intervention so that the installation of some software can be completed."
    MODULEPATH=$(puppet config print modulepath)

    for puppet_file in $*; do
	echo "Applying file $puppet_file"
	declare -F | grep -q "patch_before_$puppet_file" && {
	    echo "Applying patch before $puppet_file";
	    patch_before_$puppet_file;
	}
        puppet apply --modulepath="$MODULEPATH:modules" $puppet_file
	declare -F | grep -q "patch_after_$puppet_file" && {
	    echo "Applying patch after $puppet_file";
	    patch_after_$puppet_file;
	}
    done

    delete_processed_files

    [[ -f $POST_SCRIPT_FILENAME ]] && {
	echo "Running post-script";
	exec $POST_SCRIPT_FILENAME;
    }

    print_manual_setup
}

main $*
