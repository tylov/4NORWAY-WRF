#!/bin/bash
#
#  Give the job a name
#SBATCH --job-name=NES_real
#
#  Specify the project the job belongs to
#SBATCH --account=nn1002k --qos=preproc 
#SBATCH --ntasks-per-node=8
#SBATCH --time=8:00:00

#SBATCH --nodes=1 
#SBATCH --mem=15G
######

set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

set -xve
ulimit -s unlimited

module --quiet purge
source load_modules_iompi.bash
module list

HDIR="$HOME/REEF_SSP585_v36"
WDIR="/cluster/work/users/mpo100/WRF_SSP585/run"
#WDIR="/cluster/work/users/mpo100/COAWST_SSP585_iompi/WRF/run"
MDIR="/cluster/work/users/mpo100/WPS_SSP585"

# mkdir $WDIR
cd $HDIR
sed /"nproc"/s/.*/"! nproc"/  namelist.real.input> namelist.input.tmp1
mv namelist.input.tmp1 $WDIR/namelist.input

ln -sf $MDIR/met_em* $WDIR 

cd $WDIR
echo 'The run directory is '$WDIR'.'

#rm -rf rsl.*
mpirun ./real.exe > ./my_real.log
