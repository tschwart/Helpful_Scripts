#!/bin/sh

#-- Script for Touching all files in scratch to avoid automatic deletion
#-- DATE: 5 July 2017, AUTHOR: Rory Telemeco
#-- Script desidned to run on the Auburn University High Performance and Parallel Computing Hopper Cluster
#-- Hopper Cluster Sample Job Submission Script

#################### Hopper Header ##########################################

#-- This script provides the basic scheduler directives you
#-- can use to submit a job to the Hopper scheduler.
#-- Other than the last two lines it can be used as-is to
#-- send a single node job to the cluster. Normally, you
#-- will want to modify the #PBS directives below to reflect
#-- your workflow...

####-- For convenience, give your job a name

#PBS -N HopperTouch_20170706

#-- Provide an estimated wall time in which to run your job
#-- The format is DD:HH:MM:SS.  

#PBS -l walltime=01:00:00:00 

#-- Indicate if\when you want to receive email about your job
#-- The directive below sends email if the job is (a) aborted, 
#-- when it (b) begins, and when it (e) ends

#PBS -m abe telemeco@auburn.edu

#-- We recommend passing your environment variables down to the
#-- compute nodes with -V, but this is optional

#PBS -V

#-- Specify the number of nodes and cores you want to use
#-- Hopper's standard compute nodes have a total of 20 cores each
#-- so, to use all the processors on a single machine, set your
#-- ppn (processors per node) to 20.

#PBS -l nodes=1:ppn=1

#-- Join o and e output files

#PBS -j oe

#-- Now issue the commands that you want to run on the compute nodes.


##############################################################################

#find your scratch directories (or any other directories you want to touch) and touch all files within them
find /scratch/rst0011 -execdir touch -c '{}' +
find /scratch/Daphnia_pulex_GenomicResources -execdir touch -c '{}' +

#confirm that files are no longer marked for deletion
/tools/scripts/expiredfiles_recheck.sh

