# PATH

function __jmt_append_to_path() {
    if [[ -d $1 ]]; then
        if [[ -z ${path_prefix} ]]; then
            path_prefix=$1
        else
            path_prefix="${path_prefix}:$1"
        fi
    fi
}

function __jmt_cmd_path_list() {
    local path_dir=$JMT_HOME/path

    (for file in $(ls $path_dir 2>/dev/null); do
        local link=$path_dir/$file
        if [[ -L $link && -d $link ]]; then
            echo "${file};$(jm readdirlink $link)"
        fi
    done) | column -t -s ';'
}

function __jmt_cmd_path_add() {
    local path_dir=$JMT_HOME/path
    local force

    if [[ $1 == -f ]]; then
        force='true'
        shift
    fi

    local target=$1
    local link_name=$2

    if [[ -z $target ]]; then
        echo "USAGE: jm path add [ -f ] <target> [ <link_name> ]" >&2
        return 1
    fi
    if [[ ! -d $target ]]; then
        echo "Target MUST be a directory" >&2
        return 1
    fi
    local absolute_target
    case $target in
        /*) absolute_target=$target;;
        *)  absolute_target=$PWD/$target;;
    esac

    if [[ -z $link_name ]]; then
        link_name=$(basename $absolute_target)
        if [[ $link_name == bin ]]; then
            link_name=$(basename $(dirname $absolute_target))
        fi
    fi
    local link="$path_dir/$link_name"

    if [[ ! -e "$path_dir" ]]; then
        mkdir -p "$path_dir"
    elif [[ ! -d "$path_dir" ]]; then
        echo "Path directory $path_dir is not a directory" >&2
        return 1
    fi

    if [[ ! -e $link ]]; then
        ln -s $absolute_target $link
    elif [[ -L $link ]]; then
        if [[ $force == 'true' ]]; then
            rm $link
            ln -s $absolute_target $link
        else
            echo "$link_name already exists $(jm readdirlink $link)\nUse -f to force the changement" >&2
            return 1
        fi
    else
        echo "$link_name exists and is not a link (cannot force)" >&2
        return 1
    fi
    __jmt_cmd_path_reload
}

function __jmt_cmd_path_rm() {
    local link_name=$1
    local link=$JMT_HOME/path/$link_name

    if [[ -z $link_name ]]; then
        echo "USAGE: jm path rm <link_name>" >&2
        return 1
    fi
    if [[ ! -e $link ]]; then
        echo "$link_name does not exists" >&2
        return 1
    fi
    if [[ ! -L $link ]]; then
        echo "USAGE: jm path rm <link_name>" >&2
        echo "$link_name should be a symlink" >&2
        return 1
    fi
    rm -f $link
    __jmt_cmd_path_reload
}



function __jmt_cmd_path_reload() {
    local path_dir=$JMT_HOME/path
    local path_prefix
    local file

    if [[ -z ${__JMT_SYS_PATH} ]]; then
        __JMT_SYS_PATH=$PATH
    fi

    __jmt_append_to_path "$HOME/bin"
    __jmt_append_to_path "$JMT_HOME/bin"

    for file in $(ls $path_dir 2>/dev/null); do
        local link=$path_dir/$file
        if [[ -L $link && -d $link ]]; then
            __jmt_append_to_path "$(jm readdirlink $link)"
        fi
    done

    if [[ -n ${path_prefix} ]]; then
        export PATH="${path_prefix}:${__JMT_SYS_PATH}"
    fi
}

__jmt_cmd_path_reload
