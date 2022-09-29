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

#!!SBATCH --qos=devel
#!!SBATCH --job-name=wrf_4norway-dev
#!!SBATCH --time=00:60:00
#!!SBATCH --account=nn9280k
#!!SBATCH --nodes=4 --ntasks-per-node=128


#         qos=normal
#SBATCH --job-name=wrf_4norway
#SBATCH --time=96:00:00
#SBATCH --account=nn9280k
#SBATCH --nodes=24 --ntasks-per-node=64 --cpus-per-task=1
# Failed:
#//SBATCH --nodes=32 --ntasks-per-node=100 --cpus-per-task=1
# works: 70 mins sim per min:
#//SBATCH --nodes=16 --ntasks-per-node=64 --cpus-per-task=1
# works: 20 mins sim per min:
#//SBATCH --nodes=4 --ntasks-per-node=100 --cpus-per-task=1
# works: 40 mins sim per min:
#//SBATCH --nodes=16 --ntasks-per-node=25 --cpus-per-task=1
#//SBATCH --nodes=8 --ntasks-per-node=50 --cpus-per-task=1

if [ -z "$2" ] ; then
    #echo "Usage: sbatch $0 from-date num-months [num-days [end-hour]]"
    echo "Usage: sbatch $0 from-date to-date [restart] # default restart=false"
    exit
fi
fromdate=$1
todate=$2
restart=".false."
if [ ! -z "$3" ] ; then
    restart=$3
fi

#months=$2
#if [ -z "$3" ] ; then
#    days=0
#else 
#    days=$3
#fi
#if [ -z "$4" ] ; then
#    hours=0
#else 
#    hours=$4
#fi

year=$(date --date="$fromdate" +'%Y')
month=$(date --date="$fromdate" +'%m')
day=$(date --date="$fromdate" +'%d')
hour=$(date --date="$fromdate" +'%H')

#todate=$(date --date="$fromdate +$months months +$days days +$hours hours")
#echo from-date : $fromdate
#echo to-date   : $todate

end_year=$(date --date="$todate" +'%Y')
end_month=$(date --date="$todate" +'%m')
end_day=$(date --date="$todate" +'%d')
end_hour=$(date --date="$todate" +'%H')

echo from: $year-$month-$day $hour hours
echo end : $end_year-$end_month-$end_day $end_hour hours

# Set environment and load modules
#module --quiet purge  # Reset the modules to the system default
module load netCDF-Fortran/4.5.3-iompi-2020b
module load netCDF/4.7.4-iompi-2020b
module load HDF5/1.10.7-iompi-2020b
#module list    # For easier debugging

#set -xve
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

# Variables for preprocessing
next_year=$((year + 1))
leap_year=$((year % 4))

if [ $leap_year == 0 ] ; then 
  echo "$year is leap year"
else
  echo "$year is not leap year"
fi

# Go to WRF directory
#cd /cluster/work/users/$USER/4NORWAY/wrf/

# Add all run files needed
#ln -s /cluster/home/tylo/nn9280k/tyge_wrf/wrf3911_builds/cdx_WRFV3-2020b/run/* .

# for testing without slurm
if [ -z ${SLURM_JOB_ID+x} ] ; then
  SLURM_JOB_ID=9999
fi

# Clean-up of earlier run and preprocessing
#if [ -f rsl.error.0000 ] ; then
#  cp rsl.error.0000 rsl.error.0000_${SLURM_JOB_ID}
#  rm -f rsl.out.* rsl.error.*
#fi

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
sed -i "s|@end_year|$end_year|g" namelist.input
sed -i "s|@start_month|$month|g" namelist.input
sed -i "s|@end_month|$end_month|g" namelist.input
sed -i "s|@start_day|$day|g" namelist.input
sed -i "s|@end_day|$end_day|g" namelist.input
sed -i "s|@end_hour|$end_hour|g" namelist.input
sed -i "s|@restart|$restart|g" namelist.input

#if [ $leap_year == 1 ]; then
#  sed -i 's|RST_INTERVAL|263520|g' namelist.input
#else
#  sed -i 's|RST_INTERVAL|262800|g' namelist.input
#fi


# Start WRF
echo Start wrf.exe
#mpirun wrf.exe >& run_wrf.log
ulimit -s unlimited
srun --mpi=pmi2 wrf.exe >& wrf.log
#echo Done wrf.exe

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
