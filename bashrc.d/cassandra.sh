# Cassandra classpath

function __jmt_cmd_cassandra_version() {
    local version="$1"
    
    local cassandra_install_path="${XDG_DATA_HOME:-$HOME/.local/share}/cassandra/"
    local cassandra_home="${cassandra_install_path}/apache-cassandra-$version"

    if [[ -z $version ]]; then
        jm path list cassandra | sed -e "s#.*/apache-cassandra-\\(.*\\)/bin#\\1#"
    else
        if [[ ! -d $cassandra_home ]]; then
            echo "No cassandra $version found"
            echo "Try to install cassandra $version"

            __cassandra_install "$version"
        fi
        jm path add -f "${cassandra_home}/bin" cassandra
        jm path add -f "${cassandra_home}/tools/bin" cassandra_tools
    fi
}

function __jmt_cmd_cassandra_install() {
    local version="$1"
    
    local cassandra_install_path="${XDG_DATA_HOME:-$HOME/.local/share}/cassandra/"
    local cassandra_home="${cassandra_install_path}/apache-cassandra-$version"
    local tar_path="${cassandra_install_path}/apache-cassandra-$version-bin.tar.gz"

    if [[ -e $cassandra_home ]]; then
        echo "Cassandra $version found" >&2
        echo "Skip install" >&2
        return 1
    fi
    
    __cassandra_install "$version"

    jm path add -f "${cassandra_home}/bin" cassandra
    jm path add -f "${cassandra_home}/tools/bin" cassandra_tools
}

function __cassandra_install() {
    local version="$1"
    
    local cassandra_install_path="${XDG_DATA_HOME:-$HOME/.local/share}/cassandra/"
    local tar_path="${cassandra_install_path}/apache-cassandra-$version-bin.tar.gz"

    if [[ ! -e ${cassandra_install_path} ]]; then
        mkdir -p "${cassandra_install_path}"
    fi

    echo "Download https://archive.apache.org/dist/cassandra/${version}/apache-cassandra-${version}-bin.tar.gz"
    curl -o "${tar_path}" "https://archive.apache.org/dist/cassandra/${version}/apache-cassandra-${version}-bin.tar.gz"
    #curl -o "${cassandra_install_path}/apache-cassandra-$version-bin.tar.gz.asc" "https://archive.apache.org/dist/cassandra/${version}/apache-cassandra-${version}-bin.tar.gz.asc"

    echo "Extract apache-cassandra-${version}-bin.tar.gz"
    tar -x -z -C "${cassandra_install_path}" -f "${tar_path}"
}

