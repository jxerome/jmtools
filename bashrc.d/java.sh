# JAVA

if [[ $(uname) == "Darwin" ]]; then

    function __jmt_cmd_java() {
        local version=$1
        local java_home_cmd=/usr/libexec/java_home
        local java_home

        case "$version" in
            -l)
                $java_home_cmd -V
                ;;
            6|7|8)
                if java_home=$($java_home_cmd -v 1.$version 2>/dev/null); then
                    export JAVA_HOME=$java_home
                elif java_home=$($java_home_cmd -v $version 2>/dev/null); then
                    export JAVA_HOME=$java_home
                else
                    echo "Il n'y a pas de JDK en version $version" >&2
                    return 1
                fi
                ;;
            *)
                if java_home=$($java_home_cmd -v $version 2>/dev/null); then
                    export JAVA_HOME=$java_home
                else
                    echo "Il n'y a pas de JDK en version $version" >&2
                    return 1
                fi
                ;;
        esac
    }

    __jmt_cmd_java 1.8

fi
