#!/bin/bash

wget https://github.com/downloads/vajrasky/wallpapoz/wallpapoz-0.6.2.tar.bz2
tar -xvf wallpapoz-*.tar.bz2
python wallpapoz-*/setup.py install
rm -r wallpapoz-*
