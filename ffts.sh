#!/bin/bash
#. ffs.sh
echo ****ffts.sh****
#autoconf
if [ -d ${FFTS_DIR} ]; then
pushd ${FFTS_DIR}
#read
#echo "*********$@"

./configure --enable-sse --enable-single
automake --add-missing
make

time make $@
popd
else
echo "${FFTS_DIR} does not exist"
fi
