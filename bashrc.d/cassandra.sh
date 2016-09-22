# Cassandra classpath

function __jmt_cmd_cassandra_version() {
    local version=$1

    if [[ -z $version ]]; then
        jm path list cassandra | sed -e "s#$HOME/opt/apache-cassandra-\\(.*\\)/bin#\\1#"
    else
        local cassandra_home=$HOME/opt/apache-cassandra-$version
        if [[ ! -d $cassandra_home ]]; then
            echo "No cassandra $version found" >&2
            return 1
        fi
        jm path add -f $HOME/opt/apache-cassandra-$version/bin cassandra
        jm path add -f $HOME/opt/apache-cassandra-$version/tools/bin cassandra_tools
    fi
}
