#!/bin/bash -x

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

EXIT_CODE=0

blacklist = {}

is_blacklisted() {
    local sought="$1"
    local elem
    shift

    for elem in "${blacklist[@]}"
    do
        if [ "$elem" = "$sought" ]
        then
            return 0
        fi
    done

    return 1
}

TARGETS=$(cat ${TRAVIS_BUILD_DIR/targets.txt)
for unittet in ${TARGETS}; do
    if [ ${TRAVIS_OS_NAME} = "linux" ]; then
        if is_blacklisted "$unittest"
        then
            echo "Ignoring $unittest"
            continue
        fi
    fi

    echo "Testing unittest=$unittest"


    if [[ $NEWT_TEST_DEBUG == *"{unitest}"* ]]; then
        newt test -ldebug -v $unittest
    else
        newt test -q $unittest
    fi

    rc=$?
    [[ $rc -ne 0 ]] && EXIT_CODE=$rc
done

exit $EXIT_CODE
