#!/bin/bash
# Copyright 2016 Telefonica Investigacion y Desarrollo, S.A.U
#
# This file is part of the iotagent-ul.
#
# the iotagent-ul is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# the iotagent-ul is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
# General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with the iotagent-ul. If not, see http://www.gnu.org/licenses/.
#
# For those usages not covered by this license please contact with
# iot_support at tid dot es


function usage() {
    SCRIPT=$(basename $0)

    printf "\n" >&2
    printf "usage: ${SCRIPT} [options] \n" >&2
    printf "\n" >&2
    printf "Options:\n" >&2
    printf "\n" >&2
    printf "    -h                    show usage\n" >&2
    printf "    -v VERSION            Mandatory parameter. Version for rpm product preferably in format x.y.z \n" >&2
    printf "    -r RELEASE            Mandatory parameter. Release for product. I.E. 0.ge58dffa \n" >&2
    printf "\n" >&2
}

while getopts ":v:r:u:a:h" opt

do
    case $opt in
        v)
            VERSION_ARG=${OPTARG}
            ;;
        r)
            RELEASE_ARG=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "invalid argument: '${OPTARG}'"
            exit 1
            ;;
    esac
done

BASE_DIR="$(cd ${0%/*} && pwd -P)/.."
RPM_BASE_DIR="${BASE_DIR}/rpm"

if [[ ! -z ${VERSION_ARG} ]]; then
  PRODUCT_VERSION=${VERSION_ARG}
else
  echo "A product version must be specified with -v parameter."
  usage
  exit 2
fi

if [[ ! -z ${RELEASE_ARG} ]]; then
  PRODUCT_RELEASE=${RELEASE_ARG}
else
  echo "A product release must be specified with -r parameter."
  usage
  exit 2
fi

# RabbitMQ version whwre this plugin may run
# Plugins are very tied to specific RabbitMQ Version
RABBITMQ_VERSION=3.6.6

rpmbuild -ba ${RPM_BASE_DIR}/SPECS/rabbitmq_topic_acl.spec \
    --define "_srcdir ${BASE_DIR}/plugins" \
    --define "_project_user root" \
    --define "_topdir ${RPM_BASE_DIR}" \
    --define "_product_version ${PRODUCT_VERSION}" \
    --define "_product_release ${PRODUCT_RELEASE}" \
    --define "_rabbitmq_version ${RABBITMQ_VERSION}"

rpmbuild -ba ${RPM_BASE_DIR}/SPECS/rabbitmq_lager_plugin.spec \
    --define "_srcdir ${BASE_DIR}/plugins" \
    --define "_project_user root" \
    --define "_topdir ${RPM_BASE_DIR}" \
    --define "_rabbitmq_version ${RABBITMQ_VERSION}"

