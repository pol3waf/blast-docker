#! /bin/bash

##
# Startup script for the blast-docker container.
# Arguments given when starting the docker container will be executed
# here via sh -c.
##

INPUT_COMMAND=$1

bash /vol/scripts/extract_taxonomy.bash

export PERL5LIB=${PERL5LIB}:/vol/krona/KronaTools-2.4/lib
export PATH=${PATH}:/vol/krona/KronaTools-2.4/bin
cd /vol/krona/KronaTools-2.4/
./install.pl > /dev/null
cd /vol/output
sh -c "$INPUT_COMMAND"

bash /vol/scripts/remove_taxonomy.bash
