#!/bin/bash

# I have added you as a user for NN9280K on Betzy. 
# Regarding the CAMtr_volume_mixing_ratio, WRF will use whichever file you copy
# into the run directory with that exact name: CAMtr_volume_mixing_ratio 
# The compiler flag to activate this feature is -DCLWRFGHG.
# As far as I understand it, it is not a default option, even in WRF3.9.1.  
# But maybe it is already inserted into your configure.wrf
# My submitting script is attached for inspiration. 
# To handle the varying start and end dates of the simulation in the namelist, 
# I had a namelist.input.template with placeholders, which I was modifying via
# the sed command in the script. The same goes for the restart interval which
# may be different for leap-years ;)
# - Torge

#  Give the job a name
#SBATCH --job-name=_4NORWAY
#  Specify the project the job belongs to
#SBATCH --account=nn9280k
#  Specify resources
#SBATCH --time=20:00:00
#SBATCH --nodes=4 --ntasks-per-node=16 --cpus-per-task=1

if [ -z "$1" ] ; then
    echo Usage: $0 YEAR
    exit
fi
year=$1

# Set environment and load modules
#module --quiet purge  # Reset the modules to the system default
module load netCDF-Fortran/4.5.3-iompi-2020b
module load netCDF/4.7.4-iompi-2020b
module load HDF5/1.10.7-iompi-2020b
#module list    # For easier debugging

set -xve
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

# Variables for preprocessing
next_year=$(expr $year + 1)
echo "next:" $next_year
leap_year=$(expr $year % 4)
if [ $leap_year == 0 ] ; then 
  echo "leap year"
else
  echo "no leap year"
fi


# Go to WRF directory
#cd /cluster/work/users/$USER/4NORWAY/wrf/

# Add all run files needed
#ln -s /cluster/home/tylo/nn9280k/tyge_wrf/wrf3911_builds/cdx_WRFV3-2020b/run/* .

# for testing without slurm
if [ -z ${SLURM_JOB_ID+x} ] ; then
  SLURM_JOB_ID=999
fi

# Clean-up of earlier run and preprocessing
if [ -f rsl.error.0000 ] ; then
  cp rsl.error.0000 rsl.error.0000_${SLURM_JOB_ID}
  rm -f rsl.files.zip
  zip -qm rsl.files.zip rsl.out.* rsl.error.*
fi
#rm -f wrfbdy_d01 wrfinput_d0? wrflowinp_d0?
#cp /cluster/projects/nn9280k/torge/FZJ_data/${year}/wrfbdy_d0?_${year}??01000000*.nc.gz .
#cp /cluster/projects/nn9280k/torge/FZJ_data/${year}/wrflowinp_d0?_${year}??01000000*.nc.gz .
#gunzip *.nc.gz
#ncrcat wrfbdy_d01_${year}??01000000.nc wrfbdy_d01
#ncrcat wrflowinp_d01_${year}??01000000.nc wrflowinp_d01
#ncrcat wrflowinp_d02_${year}??01000000.nc wrflowinp_d02
#rm -f wrfbdy_d0?_${year}??01000000*.nc
#rm -f wrflowinp_d0?_${year}??01000000*.nc
cp namelist.input.template namelist.input
sed -i "s|@start_year|$year|g" namelist.input
sed -i "s|@end_year|$year|g" namelist.input

#if [ $leap_year == 1 ]; then
#  sed -i 's|RST_INTERVAL|263520|g' namelist.input
#else
#  sed -i 's|RST_INTERVAL|262800|g' namelist.input
#fi

# Start WRF
#mpirun /cluster/work/users/torge/rerunBCCR/run/wrf.exe
echo Start wrf.exe
mpirun wrf.exe >& run_wrf.log
echo Done wrf.exe

# archive model config and metadata
submitted=/cluster/projects/nn9280k/4NORWAY/submitted
output=/cluster/projects/nn9280k/4NORWAY/output
restarts=/cluster/projects/nn9280k/4NORWAY/restarts

mkdir -p $submitted/${SLURM_JOB_ID}
cp namelist.input namelist.output slurm-${SLURM_JOB_ID}.out rsl.error.0000 $submitted/${SLURM_JOB_ID}/.

# Move WRF output
mkdir -p $output/$year
mv wrfout* wrfxtrm* wrfpress* wrfcdx* $output/$year/.
mkdir -p $restarts/$year
mv wrfrst*$year* $restarts/$year/.
