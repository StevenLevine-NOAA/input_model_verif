#!/bin/sh
  
set -x

wrkdir=${STMPROOT}/interpstats.${SLURM_JOBID}
mkdir -p ${wrkdir}
cd ${wrkdir}

cp ${HOME}/ush/interp2grib.py .
cp ${HOME}/ush/landvswater.py .
cp ${HOME}/ush/getmdlcyc.py .
cp ${HOME}/ush/convert.py .

python interp2grib.py -startdate ${START} -enddate ${END} -obloc ${COM_IN}/obs/dailyobs -mdlloc ${COM_IN}/mdl -blendloc ${BLEND_IN} -shploc ${NOSCRUB}/fix/shps -models ${mdlList}

if [ ! -d ${COM_OUT} ] ; then
        mkdir -p ${COM_OUT}
fi

fnames="lakeObs oceanObs landObs waterStats oceanStats landStats"
for nm in $fnames; do
        mv ${nm}.csv ${nm}_${runName}.csv
        cp *${runName}.csv ${COM_OUT}
done

pnames="lakePoints landPoints oceanPoints waterPoints"
for p in $pnames; do
        mv ${p}.parquet ${p}_${runName}.parquet
        cp *${runName}.parquet ${COM_OUT}
done

exit
