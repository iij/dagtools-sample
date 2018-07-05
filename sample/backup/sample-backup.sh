#!/bin/sh

#
# dagtools backup sample script.
# 

## load setthings.
. $(cd $(dirname $0); pwd)/sample-backup.conf

# delete local dir over hold generation.
function delete_old_at_local() {
    # get list of directories
    list=();
    for dir in `find  ${backup_root_dir}// -maxdepth 1 -type d |awk -F/ '{print $NF}' |egrep ${gen_manager_target_dir_pattern}| sort`
    do
        list+=("${dir}")
    done

    # count directries
    current=`echo ${#list[@]}`
    echo "total direcries in backup dir: ${current}"

    delete_target_count=0
    if [[ $current -gt $local_generation ]] ; then
        delete_target_count=$(( $current - $local_generation ))
    fi

    if [[ delete_target_count -le 0 ]] ; then 
        return 0
    fi

    echo "deleting old backup data on local directories...."

    delete_count=0
    for dir in ${list[@]};
    do
        if [[ $delete_count -lt $delete_target_count ]] ; then
            echo "Delete ${backup_root_dir}/${dir} ### This script is sample. This script execute mv(rename) command instead of rm(delete)."
            mv ${backup_root_dir}/${dir} ${backup_root_dir}/del_${dir} 
            delete_count=$(( $delete_count + 1 ))
        fi
    done
    echo "done!"
    return 0
}

#sync
function sync() {
    ${dagtools_command} sync ${backup_root_dir} ${bucket_name}:
    sync_result=`echo $?`

    if [[ $sync_result != 0 ]] ; then
        echo "error has occurred. see dagtools.log."
        exit 1
    fi
}

# main
## call sync function
echo "start sync ..."
sync
echo "done."

## call to delete old dir
delete_old_at_local


