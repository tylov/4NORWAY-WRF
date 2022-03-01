#!/bin/bash
#
#  Give the job a name
#SBATCH --job-name=IM_files
#
#  Specify the project the job belongs to
#SBATCH --account=nn9280k
#SBATCH --time=1:20:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=170G

###SBATCH --nodes=1 --ntasks-per-node=1
#  Set OMP_NUM_THREADS
###SBATCH --cpus-per-task=1

## Set email notifictions
###SBATCH --mail-user=marie.pontoppidan@uni.no
#SBATCH --mail-user=tylo@norceresearch.no
#SBATCH --mail-type=ALL

if [ -z "$1" ]; then
    echo "Usage: $0 year"
    echo "    - Submit Hybrid_To_Pres_new.ncl on FRAM"
    echo "    - Copy output (atmos_hus.nc ... ) from NCL-script from FRAM to BETZY"
    echo "    - Submit metgrid.exe job on BETZY"
    exit
fi 

set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

set -xve

module purge 
module load NCL/6.5.0-intel-2018a
# module load NCL/6.6.2-intel-2019b # betzy - not working with bigmem

user=$USER
proj=4NORWAY-WRF

year=$1
next_year=$(expr $year + 1)
prev_year=$(expr $year - 2)


fram=login.fram.sigma2.no
betzy=login.betzy.sigma2.no

fram_work=/cluster/work/users/$user/$proj
betzy_work=/cluster/work/users/$user/$proj
#nird_work=/scratch/$user/$proj
IM=IM_NorESM
HIST=$IM/OUTPUT_HIST

# 3. FRAM: Submit Hybrid_To_Pres_new.ncl script:
# Input:  FRAM: /cluster/work/users/tylo/noresm2-wrf/IM_NorESM/1984_intoNCL/atmos_hus.nc ...
# Output: FRAM: /cluster/work/users/tylo/noresm2-wrf/IM_NorESM/1984/NorESM2-MM:1984-01-01_00

pushd $fram_work/$IM
ncl Hybrid_To_Pres_new.ncl CASE=\"$year\" OUTROOT=\"$fram_work/$IM\" > $fram_work/$IM/log-Hybrid_To_Pres_new-$1.txt
popd

# step 4:
echo -- 4. Copy output from NCL-script from FRAM to BETZY:
scp -r $user@$fram:$fram_work/$HIST/$next_year $user@$betzy:$betzy_work/$IM/
scp -r $user@$fram:$fram_work/$HIST/$year $user@$betzy:$betzy_work/$IM/

# step 5:
echo -- 5. Run metgrid.exe on BETZY:
# Assume betzy_work/wps has all needed files:
ssh $user@$betzy "cd $betzy_work/wps ; sbatch run_metgrid.sh $year"
