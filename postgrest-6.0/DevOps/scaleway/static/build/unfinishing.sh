#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "MY_SUB_PROJECT_NAEM" "build unfinishing"

info "Clean up the tarball"

rm -fr ${SCRIPT_ABS_PATH}/../../../../postgrest.tar.gz

done_banner "MY_SUB_PROJECT_NAEM" "build unfinishing"
