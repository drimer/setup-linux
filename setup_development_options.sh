#!/bin/bash


case $LINUX_DISTRO in
    "ubuntu") installer="apt-get";;
    "fedora") installer="yum";;
    *) echo "Sorry, your Linux distribution could not be determined.";
       exit 1;;
esac


install_vim() {
    $installer install -y vim || return 1;

    for user in $USERS; do
	cat >>/home/$user/.vimrc <<-EOF

" update window title
set title

" display cursor location
set ruler

" syntax highligting
" syntax on

highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%79v.\+/
EOF
    done
}


main() {
    for tool in "vim"; do
	install_$tool
    done
}

main
