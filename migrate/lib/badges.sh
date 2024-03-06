function migrate_badges() {

    readme_yaml="${1:-README.yaml}"

    if [ ! -f "${readme_yaml}" ]; then
        error "${readme_yaml} file not found."
    fi

    ${MIGRATE_PATH}/lib/badges.py ${readme_yaml}
}
