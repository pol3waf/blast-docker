blast-docker
============

Blast-docker is a tool for setting up the NCBI's BLAST+ program in a Docker container.
In addition it will install a copy of Krona¹ for browsing the BLAST results.


### How to use it

You can either run the program with a set of provided samples, or do a normal run.

In order to use the sample files just leave out most of the available options:
```
./docker_run.bash -p
```

To use blast-docker with your sequences and a db of your choice, use this:
```
./docker_run.bash -s [PATH_TO_SEQUENCE_FOLDER] -d [PATH_TO_BLASTDB] -q [FASTA_FILE_FOR_QUERY] -t [NAME_OF_DATABASE] -p
```

