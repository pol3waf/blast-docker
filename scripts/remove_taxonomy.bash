#! /bin/bash

##
# Script for removing the extracted Krona taxonomy
##

cd /vol/krona/KronaTools-2.4/taxonomy/

if test -f taxonomy.tab
then
    rm $( ls -I taxonomy.tar.gz )
    exit 0
else
    exit 1
fi
