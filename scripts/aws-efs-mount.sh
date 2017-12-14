#!/usr/bin/env bash

# Mount our EFS volume for use across Elastic Beanstalk instances.

if [ -f "/opt/elasticbeanstalk/support/envvars" ]
then
    . /opt/elasticbeanstalk/support/envvars
fi

if [ -z "$EFS_DNS_NAME" ]
then
    echo "ERROR: Missing the environment variable EFS_DNS_NAME for the EFS mount."
    exit 1
fi

EFS_MOUNT_DIR=/efs

echo "Mounting EFS filesystem ${EFS_DNS_NAME} to directory ${EFS_MOUNT_DIR} ..."

echo 'Stopping NFS ID Mapper...'
service rpcidmapd status &> /dev/null
if [ $? -ne 0 ] ; then
    echo 'rpc.idmapd is already stopped!'
else
    service rpcidmapd stop
    if [ $? -ne 0 ] ; then
        echo 'ERROR: Failed to stop NFS ID Mapper!'
        exit 1
    fi
fi

echo 'Checking if EFS mount directory exists...'
if [ ! -d ${EFS_MOUNT_DIR} ]; then
    echo "Creating directory ${EFS_MOUNT_DIR} ..."
    mkdir -p ${EFS_MOUNT_DIR}
    if [ $? -ne 0 ]; then
        echo 'ERROR: Directory creation failed!'
        exit 1
    fi
else
    echo "Directory ${EFS_MOUNT_DIR} already exists!"
fi

mountpoint -q ${EFS_MOUNT_DIR}
if [ $? -ne 0 ]
then
    echo "mount -v -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${EFS_DNS_NAME}:/ ${EFS_MOUNT_DIR}"
    mount -v -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${EFS_DNS_NAME}:/ ${EFS_MOUNT_DIR}
    if [[ $? -ne 0 ]]
    then
        echo 'ERROR: Mount command failed!'
        exit 1
    fi
    chmod 777 ${EFS_MOUNT_DIR}
    sudo -u webapp bash -c "touch ${EFS_MOUNT_DIR}/.efc_test"
    if [[ $? -ne 0 ]]
    then
        echo 'ERROR: Permission Error!'
        exit 1
    else
        sudo -u webapp bash  -c "rm -f ${EFS_MOUNT_DIR}/.efc_test"
    fi
else
    echo "Directory ${EFS_MOUNT_DIR} is already a valid mountpoint!"
fi

echo 'EFS mount complete.'