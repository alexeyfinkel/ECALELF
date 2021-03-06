#!/bin/bash
################
# This script merge the ntuples produced by crab jobs
# It's supposed that all the ntuples are stored in directories which finish by UNMERGED
#######
usage(){
    echo "`basename $0` -u UI_WORKING_DIR"
    echo "--------- optional"
    echo "    --merged_remote_dir dir: merge and copy the merged file  the merged_remote_dir"
    echo "    -g, --grep arg: merge files matching the argument"
    echo "    --noRemove: do not remove original files"
}

#------------------------------ parsing
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -u -o hu:g: -l help,merged_remote_dir:,grep:,noRemove -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
	-h|--help) usage; exit 0;;
	-u|--ui_working_dir) UI_WORKING_DIR=$2; shift;;
	--merged_remote_dir) MERGED_REMOTE_DIR=$2;  shift;;
	-g|--grep) FILENAME_BASE=$2; shift;;
	--noRemove) NOREMOVE=y;;
#	--ntuple) FILENAME_BASE="ntuple";;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage >> /dev/stderr; exit 1;;
    (*) break;;
    esac
    shift
done


#------------------------------ checking
if [ ! -d "${UI_WORKING_DIR}" ];then
    echo "[ERROR] crab working directory ${UI_WORKING_DIR} not found" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
elif [ ! -r "${UI_WORKING_DIR}/share/crab.cfg" ];then
    echo "[ERROR] crab config {UI_WORKING_DIR}/share/crab.cfg not found" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
fi

if [ -e "${UI_WORKING_DIR}/res/merged" ];then
    echo "[REPORT] Ntuples already merged"
    exit 0
fi
### taking the output directory (also possible directly from the crab.cfg file

USER_REMOTE_DIR=`grep '^user_remote_dir=' ${UI_WORKING_DIR}/share/crab.cfg |cut -d '=' -f 2` 
STORAGE_PATH=`grep 'storage_path=' ${UI_WORKING_DIR}/share/crab.cfg  |cut -d '=' -f 2`
echo "RUNRANGE=${RUNRANGE:=`grep 'runselection=' ${UI_WORKING_DIR}/share/crab.cfg  |cut -d '=' -f 2`}"
if [ -z "$RUNRANGE" ];then 
    echo "RUNRANGE=${RUNRANGE:=allRange}"
fi
DATASETNAME=`echo ${USER_REMOTE_DIR} | sed "s|${RUNRANGE}.*||"`
DATASETNAME=`basename $DATASETNAME`

echo "DATASETNAME=${DATASETNAME}"
#crab -c ${UI_WORKING_DIR} -report | grep srmPath | cut -d ' ' -f 6

## make the list of files in the output directory assuming there are
## only unmerged output files from this process 
case ${USER_REMOTE_DIR} in
    */unmerged)
	echo "MERGED_REMOTE_DIR=${MERGED_REMOTE_DIR:=`dirname ${USER_REMOTE_DIR}`}"
	;;
    */UNMERGED)
	echo "MERGED_REMOTE_DIR=${MERGED_REMOTE_DIR:=`dirname ${USER_REMOTE_DIR}`}"
	;;
    *)
	if [ -z "${MERGED_REMOTE_DIR}" ];then
	    echo "[ERROR] Unmerged files not in UNMERGED subdir: ${USER_REMOTE_DIR}" >> /dev/stderr
	    exit 1
	fi
	;;
esac

echo "MERGED_REMOTE_DIR=${MERGED_REMOTE_DIR:=${USER_REMOTE_DIR}}"

if [ -n "${FILENAME_BASE}" ];then
    makefilelist.sh -g ${FILENAME_BASE} unmerged ${STORAGE_PATH}/${USER_REMOTE_DIR} || exit 1
else
    makefilelist.sh unmerged ${STORAGE_PATH}/${USER_REMOTE_DIR} || exit 1
fi

if [ ! -d "/tmp/$USER" ];then
    mkdir -p /tmp/$USER
fi

#if [ -z "$JSON" ];then
#    JSON=`echo ${USER_REMOTE_DIR} | sed "s|.*${RUNRANGE}/||;s|/unmerged.*||"`
MERGEDFILE=${DATASETNAME}-${RUNRANGE}.root
#else
#    MERGEDFILE=${DATASETNAME}-${RUNRANGE}-JSON_${JSON}.root
#fi

hadd -f /tmp/$USER/${MERGEDFILE} `cat filelist/unmerged.list` || exit 1

# copy the merged file to the repository
# dirname is needed to remove "unmerged" subdir from the path
xrdcp -v /tmp/$USER/${MERGEDFILE} ${STORAGE_PATH}/${MERGED_REMOTE_DIR}/${MERGEDFILE} || exit 1

# let's remove the files
if [ -z "${NOREMOVE}" ];then
    for file in `cat filelist/unmerged.list`
      do
      file=`echo $file | sed 's|root://eoscms.cern.ch/||'`
      eos.select rm $file
    done

    if [ -z "${MERGED_REMOTE_DIR}" ];then
	eos.select rmdir `dirname ${STORAGE_PATH}/${USER_REMOTE_DIR} | sed 's|root://eoscms/||'`/unmerged
    fi
fi

rm filelist/unmerged.list

touch $UI_WORKING_DIR/res/merged

exit 0
