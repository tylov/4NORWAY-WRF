#!/bin/bash
## Project account key and queue
#SBATCH --account=nn9280k 
## Wall time limit:
#!!SBATCH --time=01:00:0
#--SBATCH --time=10:00:0
## Job name
## Number of tasks to start on each node (max is 2 sockets x 16 cores =32)
#--SBATCH --nodes=4 --ntasks-per-node=16

#SBATCH --job-name=real4norway
#SBATCH --time=96:00:00
#SBATCH --account=nn9280k
#SBATCH --nodes=4 --ntasks-per-node=64 --cpus-per-task=1

#//SBATCH --qos=devel
#//SBATCH --job-name=dev-real4norway
#//SBATCH --time=0:60:00
#//SBATCH --account=nn9280k
#//SBATCH --nodes=4 --ntasks-per-node=16


if [ -z "$2" ] ; then
    #echo "Usage: sbatch $0 from-date num-months [num-days [end-hour]]"
    echo "Usage: sbatch $0 from-date to-date"
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
sed -i "s|@end_year|$end_year|g" namelist.input
sed -i "s|@start_month|$month|g" namelist.input
sed -i "s|@end_month|$end_month|g" namelist.input
sed -i "s|@start_day|$day|g" namelist.input
sed -i "s|@end_day|$end_day|g" namelist.input
sed -i "s|@end_hour|$end_hour|g" namelist.input
sed -i "s|@restart|$restart|g" namelist.input

rm -f met_em.d0*.nc
ln -s ../wps/metgrid-out-$year/met_em.d0*.nc .

ulimit -s unlimited

## Run the application
mpirun real.exe >& real.log
