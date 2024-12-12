#!/usr/bin/bash

set -x

if [[ -s ${COM_IN}/obs/dailyobs/obs_wind_${CYCLE}.json ]] ; then
	echo "Ob file already exists - skipping this pull job"
else
	python ${HOME}/ush/getobs.py -date ${CYCLE} -path ${COM_IN}/obs/dailyobs
fi

exit
