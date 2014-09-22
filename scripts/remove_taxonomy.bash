#! /bin/bash

##
# Script for removing the extracted Krona taxonomy
##

echo "Deleting extracted Krona taxonomy ..."
cd /vol/krona/KronaTools-2.4/taxonomy/

if test -f taxonomy.tab
then
    rm $( ls -I taxonomy.tar.gz )
    echo "DONE"
else
    echo "The database seems to be missing so that it won't be deleted!"
fi
