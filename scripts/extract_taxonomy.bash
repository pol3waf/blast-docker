#! /bin/bash

##
# Script for extracting the Krona taxonomy
##

cd /vol/krona/KronaTools-2.4/taxonomy/
tar -xzf taxonomy.tar.gz

if test -f taxonomy.tab
then
    exit 0
else
    exit 1
fi
