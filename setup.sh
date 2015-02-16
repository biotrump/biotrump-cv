#!/bin/bash

. load-config.sh

export	OPENCV_DIR &&
export 	OPENCV_BUILD_SHARED_LIBS &&
export 	OPENCV_BRANCH &&
export 	OPENCV_SRC &&
export 	OPENCV_OUT &&
export	BIOTRUMP_DIR &&
export	BIOTRUMP_OUT &&
export	FFTS_DIR &&
export	FFTS_LIB_DIR &&
export	V4L2_LIB_DIR &&
export	V4L2_LIB_OUT &&
export	V4L2_CAPTURE_DIR &&
export	V4L2_CAPTURE_OUT &&
export	PICOBIN_DIR &&
export	PICOBIN_OUT &&
export	PICO_DIR &&
export	PICO_OUT &&
export DSP_ICA_DIR &&
export DSP_ICA_OUT

#export USE_CCACHE=yes &&
#export GECKO_PATH &&
#export GAIA_PATH &&
#export GAIA_DOMAIN &&
#export GAIA_PORT &&
#export GAIA_DEBUG &&
#export GECKO_OBJDIR &&
#export B2G_NOOPT &&
#export B2G_DEBUG &&
#export MOZ_CHROME_MULTILOCALE &&
#export L10NBASEDIR &&
#export MOZ_B2G_DSDS &&
#. build/envsetup.sh &&
#lunch $LUNCH
