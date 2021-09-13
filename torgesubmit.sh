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
module load WRF/3.8.1-DCLWRFGHG-intel-2016a-dmpar
module unload WRF/3.8.1-DCLWRFGHG-intel-2016a-dmpar
module load NCO/4.6.0-intel-2016a
module list    # For easier debugging

# Variables for preprocessing
completed_year="2000"
year="2001"
next_year="2002"

# Go to WRF directory
cd /cluster/work/users/torge/WRFV3/run/

# Clean-up of earlier run and preprocessing
cp rsl.error.0000 rsl.error.0000_${SLURM_JOB_ID}
rm -f wrfbdy_d01 wrfinput_d0? wrflowinp_d0? rsl.out* rsl.error.????
cp /cluster/projects/nn9280k/torge/FZJ_data/${year}/wrfbdy_d0?_${year}??01000000*.nc.gz .
cp /cluster/projects/nn9280k/torge/FZJ_data/${year}/wrflowinp_d0?_${year}??01000000*.nc.gz .
gunzip *.nc.gz
ncrcat wrfbdy_d01_${year}??01000000.nc wrfbdy_d01
ncrcat wrflowinp_d01_${year}??01000000.nc wrflowinp_d01
ncrcat wrflowinp_d02_${year}??01000000.nc wrflowinp_d02
rm -f wrfbdy_d0?_${year}??01000000*.nc
rm -f wrflowinp_d0?_${year}??01000000*.nc
cp namelist.input.template namelist.input
sed -i "s/START_YEAR/${year}/g" namelist.input
sed -i "s/END_YEAR/${next_year}/g" namelist.input
if [ "$year" == "2000" -o "$year" == "2004" -o "$year" == "2008" -o "$year" == "2012" ]; then
sed -i 's/RST_INTERVAL/263520/g' namelist.input
else
sed -i 's/RST_INTERVAL/262800/g' namelist.input
fi

# Start WRF
mpirun /cluster/work/users/torge/rerunBCCR/run/wrf.exe

# Archive model config and metadata
mkdir -p ~/torgesubmit/${SLURM_JOB_ID}
cp namelist.input namelist.output slurm-${SLURM_JOB_ID}.out rsl.error.0000 ~/torgesubmit/${SLURM_JOB_ID}/.

# Move WRF output
mkdir -p output/$year
mv wrfout* wrfxtrm* wrfpress* wrfcdx* output/$year/.
mkdir -p restarts/$year
mv wrfrst*$year* restarts/$year/.
