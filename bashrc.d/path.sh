# PATH

function __jmt_add_to_path() {
    if [[ -d "$HOME/bin" ]]; then
        if [[ -z ${path_prefix} ]]; then
            path_prefix=$1
        else
            path_prefix="${path_prefix}:$1"
        fi
    fi
}

function __jmt_cmd_path_reload() {
    local path_dir=$JMT_HOME/path
    local path_prefix
    local file

    if [[ -z ${__JMT_SYS_PATH} ]]; then
        __JMT_SYS_PATH=$PATH
    fi

    __jmt_add_to_path "$HOME/bin"
    __jmt_add_to_path "$JMT_HOME/bin"

    for file in $(ls $path_dir 2>/dev/null); do
        local link=$path_dir/$file
        if [[ -L $link && -d $link ]]; then
            __jmt_add_to_path "$(jm readdirlink $link)"
        fi
    done

    if [[ -n ${path_prefix} ]]; then
        export PATH="${path_prefix}:${__JMT_SYS_PATH}"
    fi
}

__jmt_cmd_path_reload
