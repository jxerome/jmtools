# bash personal configuration
# File to be sourced in .bashrc

export JMT_HOME=~/jmtools
export JMT_LOCAL_HOME=$JMT_HOME/local


function jm() {
    local debug
    if [[ $1 == '--debug' || $1 == '-d' ]]; then
        shift
        debug=__jm_debug
    fi

    local what=$1
    local else=$2
    if [[ -n $what ]]; then
        if __jm_is_function __jm_cmd_${what}; then
            shift
            $debug __jm_cmd_${what} "$@"
        elif [[ -n $else ]] && __jm_is_function __jm_cmd_${what}_${else}; then
            shift 2
            $debug __jm_cmd_${what}_${else} "$@"
        else
            echo "Invalid command jm $*" >&2
            return 1
        fi
    else
        echo "Missing argument" >&2
        return 1
    fi
}

function __jm_debug() {
    set -x
    "$@"
    set +x
}

function __jm_is_function() {
    if [[ "$(type -t $1)" == 'function' ]]; then
        return 0
    else
        return 1
    fi
}

function __jm_cmd_readdirlink() {
    local link=$1
    if [[ -L $link && -d $link ]]; then
        pushd "$(dirname $link)" > /dev/null
        pushd "$(readlink $link)" > /dev/null
        pwd -P
        popd > /dev/null
        popd > /dev/null
    fi
}

function __jm_source_shell_config_file() {
    local bashrc_d_dir=$1/bashrc.d
    local file

    for file in $(ls $bashrc_d_dir/*.sh $bashrc_d_dir/*.bash 2>/dev/null); do
        if [[ -x $file ]]; then
            . $file
        fi
    done
}

function __jm_source_shell_config_files() {
    local local_dir
    local local_dir_name

    __jm_source_shell_config_file "${JMT_HOME}"
    for local_dir_name in $(ls $JMT_LOCAL_HOME); do
        local_dir="${JMT_LOCAL_HOME}/${local_dir_name}"
        if [[ -d $local_dir ]]; then
            __jm_source_shell_config_file "$local_dir"
        fi
    done
}

__jm_source_shell_config_files

unset __jm_source_shell_config_files
unset __jm_source_shell_config_file
