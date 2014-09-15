##
# Blast Docker Dockerfile
#
# Version 0.1
##

# use the ubuntu:precise base image provided by dotCloud
FROM ubuntu:precise

MAINTAINER Name jsaydo@techfak.uni-bielefeld.de

# install blast and wget
# required!
RUN apt-get update
RUN apt-get install -y ncbi-blast+
RUN apt-get install -y wget

# copy the required scripts that run the pipeline from your machine to the
# Docker image and make them executable
# required!
#ADD ./init_pipeline.sh /
#RUN chmod 755 /init_pipeline.sh

# create directories where the host file system can be mounted
# required!
RUN mkdir -p /vol/db
RUN mkdir -p /vol/input
RUN mkdir -p /vol/output

# export path to blast database
# required!
RUN export BLASTDB='/vol/db'

# more exported paths
RUN export SINPUT='/vol/input'
RUN export OUTPUT='/vol/output'


# set up rights
# required
RUN chmod 755 -R /vol



# set entrypoint executable to initialize the pipeline
# required!
#ENTRYPOINT ["/init_pipeline.sh"]

