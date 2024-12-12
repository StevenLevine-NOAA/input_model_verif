#!/usr/bin/env bash

#JOB CARD GOES HERE
#SBATCH -o /scratch2/STI/mdl-sti/Steven.Levine/ptmp/logs/gethrrr.out
#SBATCH --partition service
#SBATCH --ntasks=1
#SBATCH --time 2:00:00
#SBATCH --account mdl-sti
#SBATCH -J gethrrr
#SBATCH --chdir=/scratch2/STI/mdl-sti/Steven.Levine/stmp

module load prod_util/1.1.0
module load hpss
module load wgrib2/3.1.2_ncep

set -x


awsloc="https://noaa-rap-pds.s3.amazonaws.com"
awsintro="https://noaa-rap-pds.s3.amazonaws.com"

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
PDY=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10` #CYCLE = observed/verifying time

#ORIGCYC=`$NDATE -${FH} ${CYCLE}` #ORIGCYC = model origination time
#OYYYY=`echo $ORIGCYC | cut -c 1-4`
#OYYYYMM=`echo $ORIGCYC | cut -c 1-6`
#OPDY=`echo $ORIGCYC | cut -c 1-8`
#OHH=`echo $ORIGCYC | cut -c 9-10`

wrkdir=${STMPROOT}/getrap.${SLURM_JOBID}.${PDY}
comout=${COM_IN}/mdl/rap

if [ -s ${comout}/rap.${PDY}/rap.t${HH}z.fh${FH}.winds.grib2 ] ; then
	echo "File already exists!  Skipping pull"
	exit 0
fi

mkdir -p ${wrkdir}
cd ${wrkdir}

filename=rap.t${HH}z.wrfnatf${FH}.grib2

wget $awsloc/rap.${PDY}/${filename}

wgrib2 ${filename} -match "10 m above ground" -grib_out rap.t${HH}z.fh${FH}.winds.grib2

mkdir -p ${comout}/rap.${PDY}
mv rap.t${HH}z.fh${FH}.winds.grib2 ${comout}/rap.${PDY}
rm ${filename}

exit
