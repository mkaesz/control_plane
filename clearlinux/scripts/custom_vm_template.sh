#!/bin/sh

# This script create a custom VM template on Upcloud based on the latest release of Legacy KVM.


set -x

NAME=clearlinux_custom_template
ZONE=de-fra1
CLEARLINUX_VERSION=$(curl https://cdn.download.clearlinux.org/image/latest-images | grep '[0-9]'-kvm-legacy'\.' | cut -d- -f2)
INIT_SCRIPT=https://raw.githubusercontent.com/mkaesz/control_plane/master/clearlinux/scripts/prepare_image.sh
UPCLOUD_API=https://api.upcloud.com/1.3
CONTENT_TYPE='Content-Type: application/json'

#Create storage device for clearlinux template creation
storage_uuid_1=$(curl -X POST -H "$CONTENT_TYPE" -d "$(jo -p storage=$(jo size=10 tier=maxiops title=disk2 zone=$ZONE))" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/storage | jq -r '.storage.uuid') 

storage_uuid_2=$(curl -X POST -H "$CONTENT_TYPE" -d "$(jo -p storage=$(jo size=10 tier=maxiops title=disk3 zone=$ZONE))" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/storage | jq -r '.storage.uuid')

#Get CentOS template uuid
centos_image_uuid=$(curl --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/storage/template | jq -r '.storages.storage[]  | select(.title | contains("CentOS 7")) | .uuid')

#Create a server based on CentOS and attached empty volume
server=$(curl -X POST -H "$CONTENT_TYPE" -d "$(jo -p server=$(jo zone=de-fra1 user_data=$INIT_SCRIPT title=clearlinux_custom_template_build_server hostname=buildserver.msk.pub plan=1xCPU-2GB password_delivery=none timezone=Europe/Berlin storage_devices=$(jo storage_device[]=$(jo action=clone storage=$centos_image_uuid tier=maxiops title=disk1 address=virtio) storage_device[]=$(jo action=attach size=10 title=disk2 storage=$storage_uuid_1 address=virtio) storage_device[]=$(jo action=attach title=disk3 size=10 storage=$storage_uuid_2 address=virtio))))" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server)

ip=$(echo $server | jq -r '.server.ip_addresses.ip_address[] | select((.access | contains("public")) and (.family |contains("IPv4"))) | .address')
password=$(echo $server | jq -r .server.password)
server_uuid=$(echo $server | jq -r .server.uuid)
centos_storage_address=$(echo $server | jq -r '.server.storage_devices.storage_device[] | select(.storage_title | contains("disk1")) | .address')
centos_storage_uuid=$(echo $server | jq -r '.server.storage_devices.storage_device[] | select(.storage_title | contains("disk1")) | .storage')

sleep 300

#Stop server
curl -X POST -H "$CONTENT_TYPE" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server/$server_uuid/stop

sleep 100

#Detach CentOS volume
curl -X POST -H "$CONTENT_TYPE" -d "$(jo storage_device=$(jo address=$centos_storage_address))" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server/$server_uuid/storage/detach



#Start server with standard KVM image
curl -X POST -H "$CONTENT_TYPE" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server/$server_uuid/start

sleep 300

#Stop server
curl -X POST -H "$CONTENT_TYPE" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server/$server_uuid/stop
sleep 100

default_clearlinux_storage_address=$(echo $server | jq -r '.server.storage_devices.storage_device[] | select(.storage_title | contains("disk2")) | .address')

#Detach volume
curl -X POST -H "$CONTENT_TYPE" -d "$(jo storage_device=$(jo address=$default_clearlinux_storage_address))" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server/$server_uuid/storage/detach

custom_clearlinux_storage_address=$(echo $server | jq -r '.server.storage_devices.storage_device[] | select(.storage_title | contains("disk3")) | .address')
curl -X POST -H "$CONTENT_TYPE" -d "$(jo storage_device=$(jo address=$custom_clearlinux_storage_address))" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server/$server_uuid/storage/detach

#Create template from storage
template_uuid=$(curl -X POST -H "$CONTENT_TYPE" -d "$(jo storage=$(jo title="${NAME}_${CLEARLINUX_VERSION}"))" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/storage/$storage_uuid_2/templatize | jq -r '.storage.uuid')

sleep 100

#Delete the server
curl -X DELETE -H "$CONTENT_TYPE" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/server/$server_uuid/?storages=1

#Delete the storage
curl -X DELETE -H "$CONTENT_TYPE" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/storage/$centos_storage_uuid
curl -X DELETE -H "$CONTENT_TYPE" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/storage/$storage_uuid_1

curl -X DELETE -H "$CONTENT_TYPE" --user $UPCLOUD_USERNAME:$UPCLOUD_PASSWORD $UPCLOUD_API/storage/$storage_uuid_2

