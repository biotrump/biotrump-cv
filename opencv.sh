#!/bin/bash
#. setup.sh
echo opencv.sh
#make openCV out folder
if [ ! -d ${BIOTRUMP_OUT} ]; then
  echo "${BIOTRUMP_OUT} does not exist. mkdir"
  mkdir ${BIOTRUMP_OUT}
fi
if [ ! -d ${BIOTRUMP_OUT}/openCV ]; then
  echo "${BIOTRUMP_OUT}/openCV does not exist. mkdir"
  mkdir ${BIOTRUMP_OUT}/openCV
fi
if [ ! -d ${OPENCV_OUT} ]; then
  echo "${OPENCV_OUT} does not exis. mkdir"
  mkdir ${OPENCV_OUT}
fi
pushd ${OPENCV_OUT}
#read
#echo "*********$@"

#cmake	-DBUILD_EXAMPLES:BOOL=ON -DBUILD_JASPER:BOOL=ON -DBUILD_JPEG:BOOL=ON \
#-DBUILD_PNG:BOOL=ON -DBUILD_OPENEXR:BOOL=ON -DBUILD_TIFF:BOOL=ON \
#-DBUILD_ZLIB:BOOL=ON -DBUILD_opencv_world:BOOL=ON -DWITH_OPENGL:BOOL=ON \
#-DWITH_OPENMP:BOOL=ON -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF \
#-DCMAKE_SKIP_RPATH:BOOL=OFF -DBUILD_opencv_ocl:BOOL=OFF \
#-DBUILD_SHARED_LIBS:BOOL=OFF \

#copied from cmake-gui : tools->show my changes
cmake -DBUILD_EXAMPLES:BOOL="1" -DBUILD_OPENEXR:BOOL="1" -DBUILD_SHARED_LIBS:BOOL=${OPENCV_BUILD_SHARED_LIBS} \
-DBUILD_opencv_world:BOOL="1" -DBUILD_JASPER:BOOL="1" -DBUILD_ZLIB:BOOL="1" \
-DWITH_OPENCL:BOOL="0" -DWITH_OPENMP:BOOL="1" -DBUILD_TIFF:BOOL="1" -DBUILD_JPEG:BOOL="1" \
-DWITH_OPENGL:BOOL="1" -DWITH_GTK:BOOL="1" -DWITH_GTK_2_X:BOOL="1" \
-DWITH_WEBP:BOOL="1" -DBUILD_WEBP:BOOL="1" -DBUILD_PNG:BOOL="1" -DWITH_OPENCL:BOOL="1" \
${OPENCV_SRC}
time make $@
popd
