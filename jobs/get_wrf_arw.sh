#!/usr/bin/env bash

module load prod_util/1.1.0
module load hpss
module load wgrib2/3.1.2_ncep

set -x

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
PDY=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10` #CYCLE = observed/verifying time

ORIGCYC=`$NDATE -${FH} ${CYCLE}` #ORIGCYC = model origination time
OYYYY=`echo $ORIGCYC | cut -c 1-4`
OYYYYMM=`echo $ORIGCYC | cut -c 1-6`
OPDY=`echo $ORIGCYC | cut -c 1-8`
OHH=`echo $ORIGCYC | cut -c 9-10`

wrkdir=${STMPROOT}/getarw.${SLURM_JOBID}.${PDY}
comout=${COM_IN}/mdl/wrf_arw

mkdir -p ${wrkdir}
cd ${wrkdir}

hpsspath=/NCEPPROD/2year/hpssprod/runhistory/rh${OYYYY}/${OYYYYMM}/${OPDY}
tarfile=com_hiresw_v8.1_hiresw.${OPDY}${HH}.5km.tar

filename=hiresw.t${HH}z.arw_5km.f${FH}.conus.grib2

htar -tvf ${hpsspath}/${tarfile} > arw_prep.${CYCLE}

grep ${filename} arw_prep.${CYCLE} | awk '{print $7}' > arw_find.${CYCLE}

if [ -s arw_find.${CYCLE} ] ; then
	htar -H nostage -xvf ${hpsspath}/${tarfile} -L arw_find.${CYCLE}

	wgrib2 ${filename} -match "10 m above ground" -grib_out wrf_arw.t${OHH}z.fh${OFH}.winds.grib2

	mkdir -p ${comout}/wrf_arw.${OPDY}
	mv wrf_arw.t${HH}z.fh${FH}.winds.grib2 ${comout}/wrf_arw.${OPDY}
	rm ${filename}
else
	echo "Can't find relevant files in archive for $CYCLE"
fi

exit
