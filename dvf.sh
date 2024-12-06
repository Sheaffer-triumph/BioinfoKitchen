#!/usr/bin/bash

source ~/.bashrc
mamba activate dvf
RP=$(pwd)

export THEANO_FLAGS='base_compiledir=${RP},cxx=/usr/bin/g++'

