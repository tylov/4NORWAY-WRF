#!/bin/bash
## Project account key and queue
#SBATCH --account=nn9280k 
## Wall time limit:
#SBATCH --time=0:30:0
## Job name
#SBATCH --job-name=real_noresm2-mm
## Number of nodes needed
#SBATCH --nodes=4
## Number of tasks to start on each node (max is 2 sockets x 16 cores =32)
#--SBATCH --ntasks-per-node=64

## Number of sockets on each node (max is 2)
#--SBATCH --sockets-per-node=2
## Number of cores per socket (max is 16)
#--SBATCH --cores-per-socket=16
## Over ride default settings for islands and queues
#--SBATCH --switches=4
## Do not restart simulation if queue fails
#SBATCH --no-requeue

if [ -z "$1" ] ; then
    echo Usage: $0 YEAR
    exit
fi
year=$1

## Recommended safety settings:
set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

## Software modules
module load netCDF-Fortran/4.5.3-iompi-2020b
module load netCDF/4.7.4-iompi-2020b
module load HDF5/1.10.7-iompi-2020b

## go to run directory 
#cd /cluster/work/users/$USER/4NORWAY-WRF/wps

cp namelist.input.template namelist.input
sed -i "s|@start_year|$year|g" namelist.input
sed -i "s|@end_year|$year|g" namelist.input

rm -f met_em.d0*.nc
ln -s ../wps/metgrid-out-$year/met_em.d0*.nc .

ulimit -s unlimited

## Run the application
mpirun real.exe >& real.log
