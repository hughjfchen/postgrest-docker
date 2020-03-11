#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "postgrest" "deploy unprepare"

if [ -d /var/postgrest ]; then
    info "/var/postgrest directory found, delete it..."
    sudo rm -fr /var/postgrest
fi

set +e
myUser2=$(awk -F":" '{print $1}' /etc/passwd | grep -w postgrest)
if [ "X${myUser2}" != "X" ]; then
    info "postgrest user defined, delete it..."
    sudo userdel -fr postgrest
fi

myGroup2=$(awk -F":" '{print $1}' /etc/group | grep -w postgrest)
if [ "X${myGroup2}" != "X" ]; then
    info "postgrest group defined, delete it..."
    sudo groupdel -f postgrest
fi
set -e

MY_TO_REMOVE_IMAGES=$(sudo sg docker -c "docker images"|grep -w postgrest|awk '{print $3}')
for MY_TO_REMOVE_IMAGE in ${MY_TO_REMOVE_IMAGES}
do
    sudo sg docker -c "docker image rm -f ${MY_TO_REMOVE_IMAGE}"
done

done_banner "postgrest" "deploy unprepare"
