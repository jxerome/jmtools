# JAVA

function __jmt_cmd_java() {
    local version=$1
    local java_home=/usr/libexec/java_home

    case "$version" in
        -l)
            $java_home -V
            ;;
        6|7|8)
            export JAVA_HOME=$($java_home -v 1.$version)
            ;;
        *)
            export JAVA_HOME=$($java_home -v $version)
            ;;
    esac
}

jm java 8
