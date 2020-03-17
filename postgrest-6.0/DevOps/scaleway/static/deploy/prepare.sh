#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "postgrest" "deploy prepare"

if [ ! -e ${SCRIPT_ABS_PATH}/../../../../postgrest.tar.gz ]; then
    my_exit "no postgrest tarball found, make sure you build it and pack it as a tarball with its dependencies" 1
fi

# install third-party dependencies
case ${THE_DISTRIBUTION_ID} in
    debian) for MY_DEB_PKG in $(ls ${SCRIPT_ABS_PATH}/non-docker-dependencies/*.deb)
            do
                if ! dpkg -s $(echo ${MY_DEB_PKG}|awk -F"_" '{print $1}') > /dev/null 2>&1; then
                    dpkg -i --force-depends ${SCRIPT_ABS_PATH}/non-docker-dependencies/${MY_DEB_PKG}
                fi
            done
            ;;
    centos|rhel) for MY_RPM_PKG in $(ls ${SCRIPT_ABS_PATH}/non-docker-dependencies/*.rpm)
                 do
                     if ! rpm -q $(basename ${MY_RPM_PKG} '.rpm') > /dev/null 2>&1; then
                         rpm -i --nodeps ${SCRIPT_ABS_PATH}/non-docker-dependencies/${MY_RPM_PKG}
                     fi
                 done
                 ;;
    Darwin) warn "Don't konw how to install packages for MacOs, skip"
            ;;
    *) my_exit "Unsupported OS/Distribution,abort" 1
       ;;
esac

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
    sudo useradd -m -p Passw0rd --uid 90001 --gid 90001 postgrest
fi

if [ ! -d /var/postgrest ]; then
    info "no /var/postgrest directory found, create it..."
    sudo mkdir -p /var/postgrest/data
    sudo mkdir -p /var/postgrest/config
    sudo chown -R postgrest:postgrest /var/postgrest
fi

done_banner "postgrest" "deploy prepare"
