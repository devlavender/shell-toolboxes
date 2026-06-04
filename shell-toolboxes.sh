#!/bin/sh

load_toolboxes() {
        for toolbox in "$@"; do
                tbx_path="$HOME/.shell/toolboxes/${toolbox}.sh"
                # shellcheck source=/dev/null
                test -f "${tbx_path}" && . "${tbx_path}" &&
                        echo "${toolbox} loaded" ||
                        echo "Failed to load ${toolbox}"
        done
}
