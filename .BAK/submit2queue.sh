#!/bin/bash
#
#  Give the job a name
#SBATCH --job-name=IM_files
#
#  Specify the project the job belongs to
#SBATCH --account=nn9560k
#SBATCH --time=1:20:00
#SBATCH --partition=bigmem
##SBATCH --ntasks=1
##SBATCH --mem-per-cpu=170G

###SBATCH --nodes=1 --ntasks-per-node=1
#  Set OMP_NUM_THREADS
###SBATCH --cpus-per-task=1

## Set email notifictions
###SBATCH --mail-user=marie.pontoppidan@uni.no
#SBATCH --mail-user=tylo@norceresearch.no
#SBATCH --mail-type=ALL

set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

set -xve

module purge 
module load NCL/6.5.0-intel-2018a
# module load NCL/6.6.2-intel-2019b # betzy - not working with bigmem

WDIR=/cluster/work/users/$USER/IM_NorESM
cd $WDIR
ncl Hybrid_To_Pres_new.ncl CASE=\"$1\" outROOT=\"$2\" > log-Hybrid_To_Pres_new-$1.txt
