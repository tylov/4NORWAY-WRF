# Setup job to run here.
#sbatch ./run_real.sh "1984-01-01" "1984-04-01" # 3 months
#sbatch ./run_wrf.sh "1984-01-01" "1984-04-01" # 3 months
sbatch ./run_wrf.sh "1984-02-10" "1984-04-01" ".true." # restart
#./run_wrf.sh "1984-02-10" "1984-04-01" ".true." # restart


#sbatch ./run_real.sh "1984-01-01" "1984-01-03"   # 3 days
#sbatch ./run_wrf.sh "1984-01-01" "1984-01-01 6" # 6 hours
