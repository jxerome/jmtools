# Cassandra classpath

function __jmt_cmd_cassandra_version() {
    local version=$1
    
    local cassandra_install_path="${XDG_DATA_HOME:-$HOME/.local/share}/cassandra/"

    if [[ -z $version ]]; then
        jm path list cassandra | sed -e "s#${cassandra_install_path}/apache-cassandra-\\(.*\\)/bin#\\1#"
    else
        local cassandra_home="${cassandra_install_path}/apache-cassandra-$version"
        if [[ ! -d $cassandra_home ]]; then
            echo "No cassandra $version found" >&2
            return 1
        fi
        jm path add -f "${cassandra_install_path}/apache-cassandra-$version/bin" cassandra
        jm path add -f "${cassandra_install_path}/apache-cassandra-$version/tools/bin" cassandra_tools
    fi
}
