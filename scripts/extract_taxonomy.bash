#! /bin/bash

##
# Script for extracting the Krona taxonomy
##

echo "Extracting taxonomy - this may take a minute ..."
cd /vol/krona/KronaTools-2.4/taxonomy/
tar -xzf taxonomy.tar.gz

if test -f taxonomy.tab
then
    echo "DONE"
else
    echo "Failed at extracting the taxonomy database."
    exit 1
fi
