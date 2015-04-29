#!/bin/bash
set -xe

export TEST_IMGNAME="localfvigottimariadb"

docker run --rm -ti \
 -v $(readlink -f ../src/scripts):/scripts \
 $TEST_IMGNAME \
# /bin/bash
