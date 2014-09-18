#! /bin/bash

##
# Startup script for the blast-docker container.
# Arguments given when starting the docker container will be executed
# here via sh -c.
##

INPUT_COMMAND=$1

echo "Unpacking KRONA taxonomy - this may take a few seconds ..."
cd /vol/krona/KronaTools-2.4/taxonomy
tar -xzf taxonomy.tar.gz
echo "DONE"
echo ""

echo "Starting job ..."
cd /vol/output
sh -c "$INPUT_COMMAND"
