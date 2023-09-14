#!/bin/bash
echo -- 4NORWAY NorESM2-MM downscaling Norway using WRF model: Run this on NIRD --
if [ -z "$3" ]; then
    echo "Usage: $0 STARTYEAR ENDYEAR STEP..."
    echo "  step 1:"
    echo "    - # Clean old data IM data - interactive"
    echo "    - Run Extract_vars_RF.py script"
    echo "  step 2:"
    echo "    - Submit Hybrid_To_Pres_new.ncl on NIRD IPCC"
    echo "  step 3:"
    echo "    - Copy output of NCL-script (NorESM2-MM:1984-01-01_00 ...) from NIRD to BETZY"
    echo "  step 4:"
    echo "    - Submit metgrid.exe job on BETZY"
    echo "  step 5:"
    echo "    - Submit real.exe job on BETZY"
    echo "  step 6:"
    echo "    - Submit wrf.exe job on BETZY"
    exit
fi 

# Use $IM work folder:

start_year=$1
end_year=$2
if [ "$2" == "-" ]; then
    end_year=$start_year
fi
shift
shift

user=$USER
proj=4NORWAY-WRF

nird_home=/nird/home/$user
nird_input=$nird_home/proj/4NORWAY-input
nird_proj=$nird_home/proj/4NORWAY-WRF
nird_work=/scratch/$user/4NORWAY
betzy_work=/cluster/work/users/$user/4NORWAY
IM=IM_NorESM

betzy=login-1.betzy.sigma2.no
nird=login0.nird.sigma2.no
ipcc=ipcc.nird.sigma2.no

#fram=login-1.fram.sigma2.no
#fram_work=/cluster/work/users/$user/4NORWAY

for (( year=$start_year; year<=$end_year; ++year )); do
  echo Year $year
  next_year=$(expr $year + 1)
  prev_year=$(expr $year - 2)
  for step in "$@"; do
    case $step in
    1) 
        echo -- 1. NIRD: Clean old and extract variables and create $IM variables...
        # Output: NIRD: /scratch/tylo/4NORWAY/1984_intoNCL/atmos_hus.nc ...
        #rm -rf $nird_work/$IM/${prev_year}_intoNCL # $nird_work/$IM/OUTPUT_HIS/$prev_year
        #python Extract_Vars_RF.py $year $nird_work/$IM
        #ssh $user@$nird "rm -r $nird_work/${year}_intoNCL"
        ssh $user@$nird "mkdir -p $nird_work/${year}_intoNCL ; cp $nird_proj/Extract_Vars_RF.py $nird_work"
        ssh $user@$nird "cp $nird_input/hybrid.nc $nird_input/zsfc.nc $nird_work/${year}_intoNCL"
        ssh $user@$nird "cd $nird_work ; nohup nice python ./Extract_Vars_RF.py $year $nird_work/${year}_intoNCL >Extract_Vars_RF.log 2>&1 < /dev/null &"
        ;;
    2)
        echo -- 2. IPCC: Run Hybrid_To_Pres_new.ncl script and copy result to betzy.:
        # Input:  nird: /scratch/tylo/4NORWAY/1984_intoNCL/atmos_hus.nc ...
        # Output: nird: /scratch/tylo/4NORWAY/1984_outHIST/NorESM2-MM:1984-01-01_00
        #ssh $user@$ipcc "rm -r $nird_work/${year}_outHIST"
        ssh $user@$ipcc "mkdir -p $nird_work/${year}_outHIST ; cp $nird_proj/Hybrid_To_Pres_new.ncl $nird_proj/run_ncl.sh $nird_work"
        #ssh $user@$ipcc "cd $nird_work ; sh ./run_ncl.sh $year ${year}_intoNCL ${year}_outHIST"
        ssh $user@$ipcc "cd $nird_work ; nohup nice sh ./run_ncl.sh $year ${year}_intoNCL ${year}_outHIST >run_ncl-$year.log 2>&1 < /dev/null &"
        ;;
    3)
        echo -- 3. NIRD: Copy output from NCL-script to BETZY:
        # Input:  NIRD:  /scratch/tylo/4NORWAY/1984_outHIST/NorESM2-MM:1984-01-01_00
        # Output: BETZY: /cluster/work/users/tylo/4NORWAY/1984_outHIST/NorESM2-MM:1984-01-01_00
        echo "mkdir -p $betzy_work"
        ssh $user@$betzy "mkdir -p $betzy_work"
        echo "scp -r $user@$nird:$nird_work/${year}_outHIST $user@$betzy:$betzy_work"
        nohup scp -r $user@$nird:$nird_work/${year}_outHIST $user@$betzy:$betzy_work 2>&1 < /dev/null &
        ;;
    4)
        echo -- 4. BETZY: run metgrid.exe
        # Input:  wps/namelist.wps, wps/geo_em.d01, wps/geo_em.d02, IM_NorESM/$year/NorESM2-MM:1984-01-01_00
        # Output: wps/metgrid-out-1984/met_em.d01.1984-01-01_00:00:00.nc
        #scp wps/run_metgrid.sh $user@$betzy:wps/run_metgrid.sh
        ssh $user@$betzy "cd $betzy_work/wps ; sbatch run_metgrid.sh $year"
        ;;
    5)
        echo -- 5. BETZY: Run real.exe
        # Input:  wrf/namelist.input, wrf/met_em*
        # Output: wrf/wrfbdy_d01, wrf/wrfinput_d01, wrf/wrfbdy_d02, wrf/wrfinput_d02
        echo ssh $user@$betzy "cd $betzy_work/wrf ; sbatch run_real.sh ${year}-01-01 $((year + 1))-01-01"
        ;;
    6)
        echo -- 6. BETZY: Run wrf.exe
        # Input: namelist.input, wrfbdy_d01, wrfinput_d01, wrfbdy_d02, wrfinput_d02
        # Output: wrfout_d01
        echo ssh $user@$betzy "cd $betzy_work/wrf ; sbatch run_wrf.sh ${year}-01-01 $((year + 1))-01-01"
        ;;
    *)
        echo Wrong input
    esac
  done
done
