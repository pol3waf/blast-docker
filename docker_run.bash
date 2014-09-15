#! /bin/bash 

##
# Script for running the Blast-Docker Container
##

if [ $# -ne 3 ]
  then
    echo ""
    echo 'Usage: docker_run.qbash BLASTDB_PATH INPUT_PATH "BLAST_COMMAND"'
    echo ""
    echo "Currently you should use absolute paths - especially when"
    echo "specifying the query and the database in the BLAST command:"
    echo "    - the BLAST database will be located at /vol/db/"
    echo "    - the query sequences will be located at /vol/input/"
    echo 'e.g. ./docker_run.bash /home/juser/blast/database_dir/ /home/juser/blast/input_dir/ "blastn -query /vol/input/myinput.fasta -db /vol/db/someGenome"'
    echo ""
    exit 0;
fi

BLASTDB_PATH=$1
INPUT_PATH=$2
BLAST_COMMAND=$3

image_name="pol3waf/bld"
output_dir="/tmp/output"

#mkdir $output_dir


if test -f ./Dockerfile
  then
    echo "yeah .. the image is there and up to date, so DONT re-build it"
#    echo "building docker image"
#    docker build -t $image_name .         # this is for testing
  else
    echo "downloading image"
    docker pull $image_name               # this is for later use ...
fi


echo "running image"
docker run \
    -e "SGE_TASK_LAST=$SGE_TASK_LAST" \
    -e "SGE_TASK_ID=$SGE_TASK_ID" \
    -e "NSLOTS=$NSLOTS" \
    -v $BLASTDB_PATH:/vol/db \
    -v $INPUT_PATH:/vol/input/ \
    $image_name \
    $BLAST_COMMAND \
#    > $output_dir/results.txt

