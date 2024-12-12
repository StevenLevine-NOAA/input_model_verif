#!/usr/bin/env bash

module load prod_util/1.1.0
module load hpss
module load wgrib2/3.1.2_ncep

set -x

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
PDY=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10` #CYCLE = observed/verifying time

wrkdir=${STMPROOT}/geturma.${SLURM_JOBID}.${PDY}
comout=${COM_IN}/mdl/urma

mkdir -p ${wrkdir}
cd ${wrkdir}

hpssdir=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${PDY}

if [[ ${HH} -le '05' ]] ; then
	tarfile=com_urma_v2.10_urma2p5.${PDY}00-05.tar
elif [[ ${HH} -le '11' ]] ; then
	tarfile=com_urma_v2.10_urma2p5.${PDY}06-11.tar
elif [[ ${HH} -le '17' ]] ; then
	tarfile=com_urma_v2.10_urma2p5.${PDY}12-17.tar
else
	tarfile=com_urma_v2.10_urma2p5.${PDY}18-23.tar
fi

filename=urma2p5.t${HH}z.2dvaranl_ndfd.grb2_wexp

htar -tvf ${hpssdir}/${tarfile} > urma_prep.${CYCLE}

grep ${filename} urma_prep.${CYCLE} | awk '{print $7}' > urma_find.${CYCLE}

if [ -s urma_find.${CYCLE} ] ; then
	htar -H nostage -xvf ${hpssdir}/${tarfile} -L urma_find.${CYCLE}

	wgrib2 ${filename} -match "10 m above ground" -grib_out urma.t${HH}z.winds.grib2

	mkdir -p ${comout}/urma.${PDY}
	mv urma.t${HH}z.winds.grib2 ${comout}/urma.${PDY}
	rm ${filename}
else
	echo "Can't find relevant files in archive for $CYCLE"
fi

exit
