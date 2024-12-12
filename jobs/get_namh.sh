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

awsloc="https://noaa-nam-pds.s3.amazonaws.com"
awsintro="https://noaa-nam-pds.s3.amazonaws.com"

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
PDY=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10` #CYCLE = observed/verifying time

#ORIGCYC=`$NDATE -${FH} ${CYCLE}` #ORIGCYC = model origination time
#OYYYY=`echo $ORIGCYC | cut -c 1-4`
#OYYYYMM=`echo $ORIGCYC | cut -c 1-6`
#OPDY=`echo $ORIGCYC | cut -c 1-8`
#OHH=`echo $ORIGCYC | cut -c 9-10`

wrkdir=${STMPROOT}/getnamh.${SLURM_JOBID}.${PDY}
comout=${COM_IN}/mdl/namh

if [ -s ${comout}/namh.${PDY}/namh.t${HH}z.fh${FH}.winds.grib2 ] ; then
	echo "File already exists!  Skipping pull"
	exit 0
fi

mkdir -p ${wrkdir}
cd ${wrkdir}

filename=nam.t${HH}z.conusnest.hiresf${FH}.tm00.grib2

wget $awsloc/nam.${PDY}/${filename}

wgrib2 ${filename} -match "10 m above ground" -grib_out namh.t${HH}z.fh${FH}.winds.grib2

mkdir -p ${comout}/namh.${PDY}
mv namh.t${HH}z.fh${FH}.winds.grib2 ${comout}/namh.${PDY}
rm ${filename}

exit
