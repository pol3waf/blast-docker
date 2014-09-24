#! /bin/bash

##
# Script for running the Blast-Docker Container
##
usage ()
{
cat << EOF
usage: $0 options
-c BLAST command to be used
-q Input FastA file to be used as the query in the BLAST command.
-d Location of the BLAST database to be mounted into the docker file 
-s Location of the Sequences to be mounted into the docker file
-t Target database
-m manually specify a command to your liking. This is not compatible to
   any other options 
EOF
}

# docker image to be used
DOCKER_IMAGE="pol3waf/bld"

# startup script to be used within the docker container
DOCKER_START_SCRIPT="/vol/scripts/startup.bash"

# debug output
DEBUG=/vol/output/debug.log

# sample database
TARGET_DB="16SMicrobial"
# sample query
QUERY="small.fasta"

# placeholders for arguments used while starting the docker container
MOUNT_DB=""
MOUNT_SEQUENCE=""
MOUNT_OUTPUT=""
BLAST_COMMAND=""

# set some flags
BLASTDB_PATH_SPECIFIED=false
SEQUENCE_PATH_SPECIFIED=false
QUERY_SPECIFIED=false
TARGET_DB_SPECIFIED=false
BLAST_COMMAND_SPECIFIED=false
MANUAL_COMMAND_SPECIFIED=false
PLOT=false
SEQUENCE_TOTAL_PATH_SPECIFIED=false


# logfile for debugging
echo "" > debug.log

# read arguments
while getopts ':d:s:q:t:c:m:y:p' OPTION
do
  case "$OPTION" in
    d)   BLASTDB_PATH=$OPTARG 
         BLASTDB_PATH_SPECIFIED=true
         echo "BLASTDB_PATH set to $BLASTDB_PATH" >> debug.log
         ;;
    s)   SEQUENCE_PATH=$OPTARG
         SEQUENCE_PATH_SPECIFIED=true
         echo "SEQUENCE_PATH set to $SEQUENCE_PATH" >> debug.log
         ;;
    q)   QUERY=$OPTARG
         QUERY_SPECIFIED=true
         echo "QUERY set to $QUERY" >> debug.log
         ;;
    t)   TARGET_DB=$OPTARG
         TARGET_DB_SPECIFIED=true
         echo "TARGET_DB set to $TARGET_DB" >> debug.log
         ;;
    c)   BLAST_COMMAND=$OPTARG
         BLAST_COMMAND_SPECIFIED=true
         echo "BLAST_COMMAND set to $BLAST_COMMAND" >> debug.log
         ;;
    m)   MANUAL_COMMAND=$OPTARG
         MANUAL_COMMAND_SPECIFIED=true
         echo "MANUAL_COMMAND set to $MANUAL_COMMAND" >> debug.log
         ;;
    p)   PLOT=true
         echo "PLOT set to true" >> debug.log
         ;;
    y)   SEQUENCE_TOTAL_PATH=$OPTARG
         SEQUENCE_TOTAL_PATH_SPECIFIED=true
         ;;
    *)   usage
         exit 1
         ;;
  esac
done



#
if $SEQUENCE_TOTAL_PATH_SPECIFIED
then
    SEQUENCE_PATH=$( dirname $SEQUENCE_TOTAL_PATH )
    SEQUENCE_PATH_SPECIFIED=true
    QUERY=$( basename  $SEQUENCE_TOTAL_PATH )
    QUERY_SPECIFIED=true
fi


# specify mount statements
if $BLASTDB_PATH_SPECIFIED
then
    MOUNT_DB=" -v $BLASTDB_PATH:/vol/db"
    echo "MOUNT_DB set to $MOUNT_DB" >> debug.log
fi

if $SEQUENCE_PATH_SPECIFIED
then
   MOUNT_SEQUENCE="-v $SEQUENCE_PATH:/vol/input"
   MOUNT_OUTPUT="-v $SEQUENCE_PATH:/vol/output"
   echo "MOUNT_SEQUENCE set to $MOUNT_SEQUENCE" >> debug.log
fi


# create a new BLAST command
if $BLAST_COMMAND_SPECIFIED
then
    BLAST_COMMAND="$BLAST_COMMAND -query /vol/input/$QUERY -db $TARGET_DB"
else
    # some default command whatever other settings
    BLAST_COMMAND="blastn -query /vol/input/$QUERY -db $TARGET_DB"
fi

# rewrite BLAST command if there is a manual command for more
# advanced stuff
if $MANUAL_COMMAND_SPECIFIED
then
    if $BLAST_COMMAND_SPECIFIED
    then
#        BLAST_COMMAND=$BLAST_COMMAND$MANUAL_COMMAND # don't use this .. its buggy
         echo "FUNCTION DISABLED - DON'T USE ... YET"
         echo "You are doing it wrong ... the manual option is not compatible"
         echo "with any other options. Please use either this or the other ones."
         echo $help
         exit 1
    else
        # This overwrites all other options!
        BLAST_COMMAND=$MANUAL_COMMAND
    fi
fi


# commands for letting krona plot your blast output and joining it together with the blast command
if $PLOT
then
    OUTPUT_BLAST="/vol/output/result.blast"
    OUTPUT_KRONA="/vol/output/result.krona.html"

#    PLOT_COMMAND="perl -I /vol/krona/KronaTools-2.4/lib /vol/krona/KronaTools-2.4/scripts/ImportBLAST.pl"
#    PLOT_COMMAND="/vol/krona/KronaTools-2.4/scripts/ImportBLAST.pl"
    PLOT_COMMAND="ktImportBLAST"

#    BLAST_COMMAND="$PLOT_COMMAND <( $BLAST_COMMAND -outfmt 6 )"
    BLAST_COMMAND="$BLAST_COMMAND -outfmt 6 1>$OUTPUT_BLAST 2>/dev/null; cat $OUTPUT_BLAST; $PLOT_COMMAND -o $OUTPUT_KRONA $OUTPUT_BLAST >/dev/null 2>&1"
fi



echo "BLAST_COMMAND set to $BLAST_COMMAND" >> debug.log


echo "running image" >> debug.log



# here comes the actual Docker stuff ...
#update the docker image
docker pull $DOCKER_IMAGE >> debug.log 2>&1

DOCKER_COMMAND="\
-e \"SGE_TASK_LAST=$SGE_TASK_LAST\" \
-e \"SGE_TASK_ID=$SGE_TASK_ID\" \
-e \"NSLOTS=$NSLOTS\" \
$MOUNT_DB \
$MOUNT_SEQUENCE \
$MOUNT_OUTPUT \
$DOCKER_IMAGE \
$DOCKER_START_SCRIPT \"$BLAST_COMMAND\""

echo "DOCKER_COMMAD set to $DOCKER_COMMAND" >> debug.log

sh -c "docker run $DOCKER_COMMAND"
#    -e "SGE_TASK_LAST=$SGE_TASK_LAST" \
#    -e "SGE_TASK_ID=$SGE_TASK_ID" \
#    -e "NSLOTS=$NSLOTS" \
#    $MOUNT_DB \
#    $MOUNT_SEQUENCE \
#    $MOUNT_OUTPUT \
#    $DOCKER_IMAGE \
#    $DOCKER_START_SCRIPT "$BLAST_COMMAND" \

