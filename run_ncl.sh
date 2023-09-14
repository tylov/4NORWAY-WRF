year=$1
varsDIR=$2
outDIR=$3

module purge
module load NCL/6.6.2-intel-2019b

##nohup nice ncl Hybrid_To_Pres_new.ncl CASE=\"$year\" varsDIR=\"$varsDIR\" outDIR=\"$outDIR\" >run_ncl-cp.log 2>&1 < /dev/null &
ncl Hybrid_To_Pres_new.ncl CASE=\"$year\" varsDIR=\"$varsDIR\" outDIR=\"$outDIR\"

ssh $USER@login.betzy.sigma2.no "mkdir -p /cluster/work/users/$USER/4NORWAY"
scp -r $outDIR $USER@login.betzy.sigma2.no:/cluster/work/users/$USER/4NORWAY
