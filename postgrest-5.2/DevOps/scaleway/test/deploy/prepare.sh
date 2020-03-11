#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "postgrest" "deploy prepare"

if [ ! -L ${SCRIPT_ABS_PATH}/../../../../result ]; then
    warn "no postgrest build result found, suppose that the image would be pull from registry"
else
    sudo sg docker -c "docker load -i ${SCRIPT_ABS_PATH}/../../../../result"
fi

set +e
myGroup2=$(awk -F":" '{print $1}' /etc/group | grep -w postgrest)
set -e
if [ "X${myGroup2}" = "X" ]; then
    info "no postgrest group defined yet, create it..."
    sudo groupadd -f --gid 90001 postgrest
fi

set +e
myUser2=$(awk -F":" '{print $1}' /etc/passwd | grep -w postgrest)
set -e
if [ "X${myUser2}" = "X" ]; then
    info "no postgrest user defined yet, create it..."
    sudo useradd -G docker -m -p Passw0rd --uid 90001 --gid 90001 postgrest
fi

if [ ! -d /var/postgrest ]; then
    info "no /var/postgrest directory found, create it..."
    sudo mkdir -p /var/postgrest/data
    sudo mkdir -p /var/postgrest/config
    sudo chown -R postgrest:postgrest /var/postgrest
fi

sudo cp ${SCRIPT_ABS_PATH}/docker-compose.yml /var/postgrest/docker-compose-postgrest.yml.orig
sudo chown postgrest:postgrest /var/postgrest/docker-compose-postgrest.yml.orig

sudo sed "s:postgrest_config_path:/var/postgrest/config:g" < /var/postgrest/docker-compose-postgrest.yml.orig | sudo su -p -c "dd of=/var/postgrest/docker-compose-postgrest.yml.01" postgrest 
sudo sed "s:postgrest_data_path:/var/postgrest/data:g" < /var/postgrest/docker-compose-postgrest.yml.01 | sudo su -p -c "dd of=/var/postgrest/docker-compose-postgrest.yml" postgrest

if [ -L ${SCRIPT_ABS_PATH}/../../../../result ]; then
    postgrest_IMAGE_ID=$(sudo sg docker -c "docker images"|grep -w postgrest|awk '{print $3}')
    cmdPath=$(sudo sg docker -c "docker image inspect ${postgrest_IMAGE_ID}" | grep "/nix/store/" | awk -F"/" '{print "/nix/store/"$4}')
    sudo sed "s:static_postgrest_nix_store_path:${cmdPath}:g" < /var/postgrest/docker-compose-postgrest.yml | sudo su -p -c "dd of=/var/postgrest/docker-compose-postgrest.yml.02" postgrest
    sudo cat /var/postgrest/docker-compose-postgrest.yml.02 | sudo su -p -c "dd of=/var/postgrest/docker-compose-postgrest.yml" postgrest
fi

done_banner "postgrest" "deploy prepare"
