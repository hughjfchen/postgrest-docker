#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "postgrest" "build unbuild"

#set +u to workaround the nix script temperlately.
set +u
. $HOME/.nix-profile/etc/profile.d/nix.sh
set -u

done_banner "postgrest" "build unbuild"
