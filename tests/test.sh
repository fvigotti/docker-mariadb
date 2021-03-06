#!/bin/bash
set -xe

echo 'building image with manually mounted and syncd scripts directory'
export TEST_IMGNAME="localfvigottimariadb"
docker build -t $TEST_IMGNAME ../src

docker run --rm -ti \
 -v $(readlink -f ../src/scripts):/scripts \
 $TEST_IMGNAME \
 /bin/bash

