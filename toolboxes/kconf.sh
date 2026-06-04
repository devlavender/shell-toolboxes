KCONF_CACHE_FILE="/tmp/config-cache"
KCONFIG_LIST_CACHE_FILE="/tmp/kconfig-cache"
KCONFIG_OPT_CACHE_FILE="/tmp/kconfig-options"

kconfig_list_cache() {
        find . -name 'Kconfig*' >"${KCONFIG_LIST_CACHE_FILE}" &&
                xargs grep -hE '^(config|menuconfig)' <"${KCONFIG_LIST_CACHE_FILE}" \
                        >"${KCONFIG_OPT_CACHE_FILE}"
}

kconfig_cache() {
        zcat /proc/config.gz | grep -v '^#' >"${KCONF_CACHE_FILE}" || return 1
}

kconffind() {
        opt="$1"
        case "${opt}" in CONFIG_*) ;; *) return 1 ;; esac
        grep -E "^${opt}=" "${KCONF_CACHE_FILE}" 2>/dev/null
}

kconfgrep() {
        opt="$1"
        grep -E "${opt}" "${KCONF_CACHE_FILE}"
}

kconfscan() {
        test -f "${KCONF_CACHE_FILE}" || kconfig_cache ||
                {
                        echo "Failed to cache /proc/config.gz" >&2
                        return 1
                }
        while read -r line; do
                # shellcheck disable=SC2086
                set -- $line
                for token in "$@"; do
                        kconffind "$token"
                done
        done
}

kgrepdef() {
        test -f "${KCONFIG_LIST_CACHE_FILE}" || kconfig_list_cache ||
                echo "Failed to cache kconfig files from current tree"
        grep "$@" "${KCONFIG_OPT_CACHE_FILE}"
}

kextractconf() {
        sed -E 's/^(config|menuconfig) /CONFIG_/'

}

kgetval() {
        kextractconf | kconfscan
}

kgrepval() {
        kgrepdef "$@" | kgetval
}

kconfoptgrep() {
        xargs grep --color "$@" <"${KCONFIG_LIST_CACHE_FILE}"
}
