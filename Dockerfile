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

# create directories where the host file system can be mounted
# required!
RUN mkdir -p /vol/db
RUN mkdir -p /vol/input
RUN mkdir -p /vol/output
RUN mkdir -p /vol/krona
RUN mkdir -p /vol/scripts

# add a sample database and a sample input to the container
ADD ./input /vol/input
ADD ./db /vol/db
ADD ./scripts/ /vol/scripts
ADD ./krona /vol/krona

# export path to blast database
# required!
ENV BLASTDB /vol/db

# more exported paths
ENV INPUT_FOLDER /vol/input
ENV OUTPUT_FOLDER /vol/output


# set up rights
# required
RUN chmod 755 -R /vol

# install KRONA
RUN perl /vol/krona/KronaTools-2.4/install.pl

# remove apt-get cache
RUN apt-get autoremove
RUN apt-get autoclean



# set entrypoint executable to initialize the pipeline
#ENTRYPOINT ["/init_pipeline.sh"]

