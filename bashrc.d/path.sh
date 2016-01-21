# PATH

function __jm_cmd_path_reload() {
    local path_dir=$CONFIG_HOME/path
    local path_prefix
    local file

    if [[ -z ${__JM_SYS_PATH} ]]; then
        __JM_SYS_PATH=$PATH
    fi

    for file in $(ls $path_dir 2>/dev/null); do
        local link=$path_dir/$file
        if [[ -L $link && -d $link ]]; then
            local realdir="$(jm readdirlink $link)"
            if [[ -z ${path_prefix} ]]; then
                path_prefix=${realdir}
            else
                path_prefix="${path_prefix}:${realdir}"
            fi
        fi
    done

    if [[ -n ${path_prefix} ]]; then
        export PATH="${path_prefix}:${__JM_SYS_PATH}"
    fi
}

__jm_cmd_path_reload
