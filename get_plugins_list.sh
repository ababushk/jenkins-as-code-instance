#!/bin/bash
set -euf -o pipefail

if [ -z "${JENKINS_HOST}" ]; then
    echo "Please export JENKINS_HOST variable like this:"
    echo "export JENKINS_HOST=username:password@myhost.com:port"
    echo "Note: some symbols need to be url encoded"
    echo "For example: '#' should be written as '%32'"
    echo "You can use API token instead"
    exit 1
fi

curl -sSL "http://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/'
