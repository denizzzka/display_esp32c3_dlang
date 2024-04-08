#!/usr/bin/env bash

# Preprocess *.h to *.i files

set -euox pipefail

SRC_DIR=$1
DST_DIR=$2
CC=$3
CC_FLAGS=$4

fdfind --type f --glob *.h --exec mkdir -p ${DST_DIR}/'{//}' \; --exec $CC $CC_FLAGS -E -o ${DST_DIR}/'{//}'/'{/.}'.i '{}' ${SRC_DIR}
