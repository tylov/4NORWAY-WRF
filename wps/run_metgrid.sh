#!/bin/bash

# Project account key and queue
#SBATCH --account=nn9280k --qos=preproc 
## Wall time limit:
#SBATCH --time=10:00:0
## Job name
#SBATCH --job-name=metgrid_noresm2-mm
## Number of nodes needed
#SBATCH --nodes=1
#SBATCH --core-spec=16
## Number of tasks to start on each node (max is 2 sockets x 16 cores =32)
#SBATCH --ntasks-per-node=8

## Number of sockets on each node (max is 2)
#--SBATCH --sockets-per-node=2
## Number of cores per socket (max is 16)
#--SBATCH --cores-per-socket=16
## Over ride default settings for islands and queues
#--SBATCH --switches=4
#SBATCH --mem=10G  # justere up

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
cd /cluster/work/users/$USER/4NORWAY-WRF/wps
rm -f metgrid_log.zip.xz
#if [ -f metgrid.log ] ; then 
#  zip -0 -m metgrid_log.zip metgrid.log* ; xz -2 metgrid_log.zip
#fi

## Make sure output is copied back after job finishess
#savefile geo_em* 

outdir=metgrid-out-$year
mkdir -p $outdir
if [ ! -f geo_em.d01.nc ] ; then
  ln -s /cluster/projects/nn9280k/pmo033/TEST_DATA/WPS/geo_em.d0?.nc .
fi

cp namelist.wps.template namelist.wps
sed -i "s|@year|$year|g" namelist.wps
sed -i "s|@opt_output_from_metgrid_path|$outdir|g" namelist.wps
sed -i "s|@fg_name|../IM_NorESM/$year/NorESM2-MM|g" namelist.wps

## Run the application
#srun --mpi=pmi2 metgrid.exe >& metgrid.log
mpirun metgrid.exe >& metgrid-$year.log
