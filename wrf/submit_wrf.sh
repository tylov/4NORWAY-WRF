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

#!/bin/bash
#  Give the job a name
#SBATCH --job-name=CFPS_rerun
#  Specify the project the job belongs to
#SBATCH --account=nn9280k
#  Specify resources
#SBATCH --time=144:00:00
#SBATCH --nodes=24 --ntasks-per-node=32 --cpus-per-task=1

# Set environment and load modules
set -xve
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
module --quiet purge  # Reset the modules to the system default
module load netCDF-Fortran/4.5.3-iompi-2020b
module load netCDF/4.7.4-iompi-2020b
module load HDF5/1.10.7-iompi-2020b
module list    # For easier debugging


# Variables for preprocessing
year=$1
next_year=$(expr $year + 1)
leap_year=$(expr $year % 4 == 0)

# Go to WRF directory
cd /cluster/work/users/$USER/4NORWAY/wrf/

# Clean-up of earlier run and preprocessing
cp rsl.error.0000 rsl.error.0000_${SLURM_JOB_ID}
rm -f wrfbdy_d01 wrfinput_d0? wrflowinp_d0? rsl.out* rsl.error.????
#cp /cluster/projects/nn9280k/torge/FZJ_data/${year}/wrfbdy_d0?_${year}??01000000*.nc.gz .
#cp /cluster/projects/nn9280k/torge/FZJ_data/${year}/wrflowinp_d0?_${year}??01000000*.nc.gz .
#gunzip *.nc.gz
#ncrcat wrfbdy_d01_${year}??01000000.nc wrfbdy_d01
#ncrcat wrflowinp_d01_${year}??01000000.nc wrflowinp_d01
#ncrcat wrflowinp_d02_${year}??01000000.nc wrflowinp_d02
#rm -f wrfbdy_d0?_${year}??01000000*.nc
#rm -f wrflowinp_d0?_${year}??01000000*.nc
cp namelist.input.template namelist.input
sed -i "s/START_YEAR/${year}/g" namelist.input
sed -i "s/END_YEAR/${next_year}/g" namelist.input

if [ $leap_year == 1 ]; then
  sed -i 's/RST_INTERVAL/263520/g' namelist.input
else
  sed -i 's/RST_INTERVAL/262800/g' namelist.input
fi

# Start WRF
#mpirun /cluster/work/users/torge/rerunBCCR/run/wrf.exe
mpirun /cluster/work/users/$USER/4NORWAY-WRF/wrf/wrf.exe

# Archive model config and metadata
mkdir -p ~/torgesubmit/${SLURM_JOB_ID}
cp namelist.input namelist.output slurm-${SLURM_JOB_ID}.out rsl.error.0000 ~/torgesubmit/${SLURM_JOB_ID}/.

# Move WRF output
mkdir -p output/$year
mv wrfout* wrfxtrm* wrfpress* wrfcdx* output/$year/.
mkdir -p restarts/$year
mv wrfrst*$year* restarts/$year/.
