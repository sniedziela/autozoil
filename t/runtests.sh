#!/bin/bash

cd ..
ADIR=`pwd`
cd t
PERL5LIB="$PERL5LIB:$ADIR" prove -r --harness=TAP::Harness::JUnit