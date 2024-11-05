#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

VERSION=cbioportal/cbioportal:latest

docker run --rm -it $VERSION cat /cbioportal-webapp/application.properties |
    sed 's|spring.datasource.password=.*|spring.datasource.password=somepassword|' | \
    sed 's|spring.datasource.username=.*|spring.datasource.username=cbio_user|' | \
    sed 's|spring.datasource.url=.*|spring.datasource.url=jdbc:mysql://cbioportal-database:3306/cbioportal?useSSL=false\&allowPublicKeyRetrieval=true|' \
> application.properties
