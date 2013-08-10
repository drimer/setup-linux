#!/bin/bash

# I wrote this script because I find it tedious to have to backup my config
# files, set up my directories such as a bin/ for the binaries I use or the
# Python path I use with my own libraries. Though one way of avoiding this
# is using a different partition for the /home mount point, sometimes it is
# desirable to make a clean installation, or you just want to install another
# Linux distribution to play with it, and you don't want it to have the same
# /home as your day-to-day Linux.
# Because some people may want to use this script with the minimum software
# installations, by default it will only install very basic and common
# command-line tools (i.e. vim, nmap)

# How to extend this script:
# 1) Add to the bin/ folder the binaries you usally use. They will be copied
#    to a new sub-folder in the home directory and it will be added to your
#    $PATH
# 2) Add scripts with the name convention "*-install.sh" to the same folder as
#    this script file. These will be automatically run during the installation.
# For further details of the options: please see `./setup_linux.sh`

installer=""
update_system=false
users=$(who am i | cut -f1 -d" ")


distro_discovery(){
    LINUX_DISTRO=$(grep "^ID=" /etc/os-release | cut -d"=" -f2)
    if [[ "$LINUX_DISTRO" == ubuntu ]]; then
	installer="apt-get"
    elif [[ "$LINUX_DISTRO" == fedora ]]; then
	installer="yum"
    fi
}


check_root_permissions(){
    if [ $EUID -ne 0 ]; then
	echo "You have no privileges to install software."
	exit 1
    fi
}


install_command_line_software() {
    for package in linux-headers-`uname -r` screen htop vim \
        ssh nmap python-pip unrar unzip; do
	$installer install -y $package
    done
}


install_config_files() {
    for user in $users; do
	home_dir="/home/$user"
	cp .vimrc $home_dir/.vimrc
    done
}


setup_bash_configuration() {
    for user in $users; do
	home_dir="/home/$user"
	mkdir -p $home_dir/bin/
	[[ $(ls bin/* >/dev/null 2>&1) ]] && { \
	    cp -rf bin/* $home_dir/bin/; chmod 755 $home_dir/bin/*; }

	mkdir -p $home_dir/python_lib/
	[[ $(ls python_lib/*.py >/dev/null 2>&1) ]] && { \
	    cp -rf python_lib/*.py $home_dir/binpython_lib/;
	    chmod 755 $home_dir/python_lib/*;
	}

	cat >>$home_dir/.bashrc <<-EOF

# Configuration added by setup_install.sh
export PATH=\$PATH:$home_dir/bin/
export PYTHONPATH=$home_dir/python_lib/:$PYTHONPATH
EOF
    done
}


run_user_scripts() {
    [[ $(ls *-install.sh  >/dev/null 2>&1) ]] || return
    for f in $(ls *-install.sh); do
	./$f >$f.stdout 2>$f.stderr
	[[ $? -eq 0 ]] && rm $f.*
    done
}


update_system() {
    if [ $installer == apt-get ]; then
	apt-get update
	apt-get -y upgrade
    elif [ $installer == yum ]; then
	yum -y upgrade
    fi
}


print_usage() {
echo "Usage: script.sh [options]

Options can be:
    -h, --help:    Print this help
    --devel:       Set up developer options (i.e. generate dore dump files)
    --update:      Update the system software
    --users:        Comma-separated list of users whose config files will be changed
"
}


parse_arguments() {
    while [[ $* != "" ]]; do
	case $1 in
	    --help | -h) print_usage; exit 0;;
	    --devel) ./setup_development_options.sh;;
	    --update) $update_system=true;;
	    --users) users="$(echo $2 | sed "s/,/ /g")"; shift;;
	    *) echo "Invalid option: $1"; exit 1;;
	esac
	shift
    done
}


main() {
    parse_arguments $*
    check_root_permissions
    distro_discovery
    install_command_line_software
    install_config_files
    setup_bash_configuration
    run_user_scripts
    [[ $update_system == true ]] && update_system
}

main $*
