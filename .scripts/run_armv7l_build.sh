#!/bin/bash
set -xeo pipefail

export PYTHONUNBUFFERED=1
# export FEEDSTOCK_ROOT="${FEEDSTOCK_ROOT:-/home/conda/feedstock_root}"
export FEEDSTOCK_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
# export CONFIG_FILE="${FEEDSTOCK_ROOT}/linux_armv7l_config.yaml"
export YUM_REQUIREMENTS="${FEEDSTOCK_ROOT}/recipe/yum_requirements.txt"

if [ -z "${CONFIG_FILE}" ]; then
    echo "Empty config file, download global pin config."
    curl -o "/tmp/conda_build_config.yaml" "https://raw.githubusercontent.com/e8035669acarmv7/conda-pin-package/main/conda_build_config.yaml"
    CONFIG_FILE="/tmp/conda_build_config.yaml"
else
    CONFIG_FILE="${FEEDSTOCK_ROOT}/${CONFIG_FILE}"
    echo "Use config file ${CONFIG_FILE}"
fi

if [ -e "${YUM_REQUIREMENTS}" ]; then
    echo "Install yum requirements"
    xargs sudo yum -y install < "${YUM_REQUIREMENTS}"
fi

echo "set anaconda upload"
conda config --set anaconda_upload yes

mkdir -p ${HOME}/.continuum/anaconda-client/
touch ${HOME}/.continuum/anaconda-client/config.yaml
anaconda config --set upload_user e8035669acarmv7

echo "set pkg_format 2"
conda config --set conda_build.pkg_format 2

echo "Who am I"
anaconda -v whoami

echo "Start build conda package"
conda build -m "${CONFIG_FILE}" "${FEEDSTOCK_ROOT}"

