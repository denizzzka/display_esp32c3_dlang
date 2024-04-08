#!/usr/bin/env bash

# Preprocess *.h to *.i files

set -euox pipefail

CC=$1
CC_FLAGS=$2
SRC_DIR=$3
DST_DIR=$4

fdfind --type f --glob *.h --base-directory ${SRC_DIR} --exec mkdir -p ${DST_DIR}/'{//}' \; --exec $CC $CC_FLAGS -E -o ${DST_DIR}/'{//}'/'{/.}'.i '{}' \; || exit 0
