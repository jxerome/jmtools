#
# Add a function to launche the gradle wrapper
#

function gw() {
    local project_dir=$(pwd)

    while [[ ( ${project_dir} != "/" ) && ( ! -x "${project_dir}/gradlew" ) ]]; do
        project_dir=$(dirname ${project_dir})
    done

    if [[ -x "${project_dir}/gradlew" ]]; then
        ${project_dir}/gradlew
    else
        echo "Not in a gradle project" 1>&2 
    fi
}
