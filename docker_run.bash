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

# sample database
TARGET_DB="16SMicrobial"
# sample query
QUERY="small.fasta"

# placeholders for arguments used while starting the docker container
MOUNT_DB=""
MOUNT_SEQUENCE=""
BLAST_COMMAND=""

# set some flags
BLASTDB_PATH_SPECIFIED=false
SEQUENCE_PATH_SPECIFIED=false
QUERY_SPECIFIED=false
TARGET_DB_SPECIFIED=false
BLAST_COMMAND_SPECIFIED=false
MANUAL_COMMAND_SPECIFIED=false

# logfile for debugging
echo "" > debug.log

# read arguments
while getopts ':d:s:q:t:c:m:' OPTION
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
    *)   usage
         exit 1
         ;;
  esac
done

 

# specify mount statements
if $BLASTDB_PATH_SPECIFIED
then
    MOUNT_DB=" -v $BLASTDB_PATH:/vol/db"
    echo "MOUNT_DB set to $MOUNT_DB" >> debug.log
fi

if $SEQUENCE_PATH_SPECIFIED
then
   MOUNT_SEQUENCE="-v $SEQUENCE_PATH:/vol/input"
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
         echo "You are doing it wrong ... the manual option is not compatible"
         echo "with any other options. Please use either this or the other ones."
         echo $help
         exit 1
    else
        # This overwrites all other options!
        BLAST_COMMAND=$MANUAL_COMMAND
    fi
fi


echo "BLAST_COMMAND set to $BLAST_COMMAND" >> debug.log


echo "running image" >> debug.log
docker run \
    -e "SGE_TASK_LAST=$SGE_TASK_LAST" \
    -e "SGE_TASK_ID=$SGE_TASK_ID" \
    -e "NSLOTS=$NSLOTS" \
    $MOUNT_DB \
    $MOUNT_SEQUENCE \
    $DOCKER_IMAGE \
    $BLAST_COMMAND \

