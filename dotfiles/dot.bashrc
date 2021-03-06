# bash personal configuration
# File to be sourced in .bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

function jm() {
    local debug
    if [[ $1 == '--debug' || $1 == '-d' ]]; then
        shift
        debug=__jmt_debug
    fi

    local what=$1
    local else=$2
    local cmd
    if [[ ( -n $else ) && ( -n $what ) ]] && cmd=$(__jmt_find_function_or_command "${what}_${else}"); then
        shift 2
        $debug "$cmd" "$@"
    elif [[ -n $what ]]; then
        if cmd=$(__jmt_find_function_or_command "${what}"); then
            shift
            $debug "$cmd" "$@"
        else
            echo "jm: Invalid command $*" >&2
            return 1
        fi
    else
        echo "Missing at least one argument" >&2
        return 1
    fi
}

if [[ $(uname -s) == "Darwin" ]]; then

    function __jmt_home() {
        echo "$HOME/jmtools"
    }

    function __jmt_config() {
        echo "$HOME/Library/jmtools"
    }

else 

    function __jmt_home() {
        echo "${XDG_DATA_HOME:-$HOME/.local/share}/jmtools"
    }

    function __jmt_config() {
        echo "${XDG_DATA_HOME:-$HOME/.config}/jmtools"
    }

fi

function __jmt_debug() {
    set -x
    "$@"
    set +x
}

function __jmt_find_function_or_command() {
    for f in "jmt_cmd_${1}" "__jmt_cmd_${1}"; do
        if __jmt_is_function "$f"; then
            echo "$f"
            return 0
        fi
    done
    return 1
}

function __jmt_is_function() {
    if [[ "$(type -t $1)" == 'function' ]]; then
        return 0
    elif which $1 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function __jmt_cmd_readdirlink() {
    local link=$1
    if [[ -L $link && -d $link ]]; then
        pushd "$(dirname $link)" > /dev/null
        pushd "$(readlink $link)" > /dev/null
        pwd -P
        popd > /dev/null
        popd > /dev/null
    fi
}

function __jmt_source_shell_config_file() {
    local bashrc_d_dir=$1/bashrc.d
    local file

    if [[ -d $bashrc_d_dir ]]; then
        for file in $(ls $bashrc_d_dir/*.sh $bashrc_d_dir/*.bash 2>/dev/null); do
            if [[ -x $file ]]; then
                . $file
            fi
        done
    fi
}

function __jmt_source_shell_config_files() {
    if which -s starship; then
        eval "$(starship init bash)"
    fi

    __jmt_source_shell_config_file "$(__jmt_home)"
    __jmt_source_shell_config_file "$(__jmt_config)"
}

__jmt_source_shell_config_files

unset __jmt_source_shell_config_files
unset __jmt_source_shell_config_file
