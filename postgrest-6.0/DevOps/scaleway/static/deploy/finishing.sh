#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "postgrest" "deploy finishing"

info "Currently, nothing to do for postgrest deploy finishing. In the future, maybe add some start/stop script for non-docker deployment"

done_banner "postgrest" "deploy finishing"
