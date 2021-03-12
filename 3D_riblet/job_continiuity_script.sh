#!/bin/sh

#$ -N angle67.5Flow_thinBiofilm_run2 # job name
#$ -V           # use all shell environment variables
#$ -cwd         # run job in working directory
# #$ -j y         # merge stdout and stderr to one file

# Choose a queue:
# Check options with "qconf -sql"
# Check details with "qconf -sq <q-name>"
#$ -q cm.7.day

# Choose a parallel environment:
# Check options with "qconf -spl"
# Check details with "qconf -sp <pe-name>"
#$ -pe mpi 24       # asks for n processors for an mpi job
#$ -l h_vmem=4G     # asks for n Gb of memory
# Send mail at submission and completion of script
#$ -m be
#$ -M p.sinclair@ed.ac.uk

# Set job runtime
#$ -l h_rt=168:00:00               # I leave this set at 7 days (set at 24 hours for 1 day queue)


# load any required modules
#module load mpi
module load openmpi/3.0.2
source ~/Programs/OpenFOAM/OpenFOAM-v1906/etc/bashrc

#this is where this is different to the initial job submission script.  here we no longer need to delete the previous time directories
#and there is no need to decomposePar again.  Instead we instruct the system to start off where it last stopped.
#in case the job was stopped mid file writing, we'll delete the latest time directories (and hope that doesn't cause any issues itself)

sed -i '/startFrom/c\startFrom       latestTime;' system/controlDict     #this is so openfoam starts from the latest time directory rather than from t=0. NOW ONLY CHANGES THE INTENDED KEYWORD.
#foamListTimes -processor -latestTime -rm                #openfoam command. deletes the latest time directories from the processor files

# can be useful to know the name of the computer where the job is running
echo "Job running on $( hostname ) "

# any output which normally goes to screen will go to the job log file

# it can be useful to wrap commands in the 'time' command to time the job

TIMEFORMAT=$'\n######################\nRun time was %0lR\n##########################\n'

time {

# put the usual mpirun command here
# the shell variable $NSLOTS is the number of cores you asked for above
mpirun -np $NSLOTS interFoam -parallel > log

}
