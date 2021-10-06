echo -- 4NORWAY NorESM2-MM downscaling Norway using WRF model: Run this on NIRD --
if [ -z "$2" ]; then
    echo "Usage: $0 YEAR script-step"
    echo "  step 1:"
    echo "    - Clean old data IM data - interactive"
    echo "    - Extract_vars_RF.py script"
    echo "    - copy files generated by Extact_Vars_RF.py to FRAM"
    echo "    - Submit Hybrid_To_Pres_new.ncl script on FRAM"
    echo "  step 2:"
    echo "    - Copy output from NCL-script from FRAM to BETZY"
    echo "    - Submit metgrid.exe job on BETZY"
    echo "  step 3:"
    echo "    - Submit real.exe job on BETZY"
    echo "  step 4:"
    echo "    - Submit wrf.exe job on BETZY"
    exit
fi 
# Use $IM work folder:
year=$1
step=$2
user=$USER
proj=4NORWAY-WRF

nird_work=/scratch/$user/$proj
fram_work=/cluster/work/users/$user/$proj
betzy_work=/cluster/work/users/$user/$proj
IM=IM_NorESM
into_ncl=${year}_intoNCL

fram=login.fram.sigma2.no
betzy=login.betzy.sigma2.no

case $step in
    1) 
        echo -- 1a. NIRD: Clean old and extract variables and create $IM variables...
        # Output: NIRD: /scratch/tylo/4NORWAY-WRF/IM_NorESM/1984_intoNCL/atmos_hus.nc ...
        # remove IM_NorESM/????_intoNCL 4NORWAY-WRF/IM_NorESM/OUTPUT_HIST/????
        #./remove.sh $nird_work/$IM/????_intoNCL $nird_work/$IM/OUTPUT_HIST/????
        python Extract_Vars_RF.py $year $nird_work/$IM

        echo -- 1b. NIRD: copy files generated by Extact_Vars_RF.py to FRAM:
        # Output: FRAM: /cluster/work/users/tylo/noresm2-wrf/$IM/1984_intoNCL/atmos_hus.nc ...
        # NOT NEEDED echo ssh $user@$fram mkdir -p $fram_work/$IM/$into_ncl
        scp -r $nird_work/$IM/$into_ncl $user@$fram:$fram_work/$IM

        echo -- 1c. FRAM: Submit Hybrid_To_Pres_new.ncl script:
        # Input:  FRAM: /cluster/work/users/tylo/noresm2-wrf/IM_NorESM/1984_intoNCL/atmos_hus.nc ...
        # Output: FRAM: /cluster/work/users/tylo/noresm2-wrf/IM_NorESM/1984/NorESM2-MM:1984-01-01_00
        scp Hybrid_To_Pres_new.ncl submit2queue.sh $user@$fram:$fram_work/$IM/
        ssh $user@$fram "cd $fram_work/$IM ; sbatch submit2queue.sh $year $fram_work/$IM/"
        ;;
    2)    
        echo -- 2a. FRAM: Copy output from NCL-script to BETZY:
        # Input:  FRAM:  /cluster/work/users/tylo/noresm2-wrf/IM_NorESM/OUTPUT_HIST/1984/
        # Output: BETZY: /cluster/work/users/tylo/noresm2-wrf/IM_NorESM/1984/NorESM2-MM:1984-01-01_00
        #scp -3 -r $user@$fram:$fram_work/$IM/OUTPUT_HIST/$year $user@$betzy:$betzy_work/$IM/

        echo -- 2b. BETZY: run metgrid.exe
        # Input:  namelist.wps, geo_em.d01, geo_em.d02, ../IM_NorESM/$year/NorESM2-MM:1984-01-01_00
        # Output: met_em.DOMAIN.YYYY-MM-DD...
        #scp wps/run_metgrid.sh $user@$betzy:wps/run_metgrid.sh
        ssh $user@$betzy "cd $betzy_work/wps ; sbatch run_metgrid.sh $year"
        ;;
    3)
        echo -- 3. BETZY: Run real.exe
        # Input:  namelist.input, met_em*
        # Output:wrfbdy_d01,wrfinput_d01, wrfbdy_d02,wrfinput_d02
        ssh $user@$betzy "cd $betzy_work/wrf ; sbatch run_real.sh $year"
        ;;
    4)
        echo -- 4. BETZY: Run wrf.exe
        # Input:namelist.input, wrfbdy_d01,wrfinput_d01, wrfbdy_d02,wrfinput_d02
        ssh $user@$betzy "cd $betzy_work/wrf ; sbatch run_wrf.sh $year"
        ;;
    *)
        echo Wrong input
esac
