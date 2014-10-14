#!/bin/bash

function configure_device() {
#		if [! out/opencv/static exist]; then
#			mkdir
#			cd out/opencv/static
#			cmake opencv source
#		fi


#		cd out/v4l2/
#		cmake source_path
#		cd out/pico
#		cmake source_path

    return $?
}

###cmake config
###v4l2/v4l2-lib
function cmake_v4l2_lib(){
	if [ -f ${V4L2_LIB_DIR}/CMakeLists.txt ]; then
		if [ ! -d ${V4L2_LIB_OUT} ]; then
			mkdir ${V4L2_LIB_OUT}
		else
			echo ${V4L2_LIB_OUT} exist
		fi
		cd ${V4L2_LIB_OUT}
		cmake ${V4L2_LIB_DIR}
	else
		echo "${V4L2_LIB_DIR}/CMakeLists.txt does not exist!"
		return 1
	fi
	cd ${BIOTRUMP_DIR}
	return $?
}

###
function cmake_v4l2_capture(){
	if [ -f ${V4L2_CAPTURE_DIR}/CMakeLists.txt ]; then
		if [ ! -d ${V4L2_CAPTURE_OUT} ]; then
			mkdir ${V4L2_CAPTURE_OUT}
		else
			echo ${V4L2_CAPTURE_OUT} exist
		fi
		cd ${V4L2_CAPTURE_OUT}
		cmake ${V4L2_CAPTURE_DIR}
	else
		echo "${V4L2_CAPTURE_DIR}/CMakeLists.txt does not exist!"
		return 1
	fi
	cd ${BIOTRUMP_DIR}
	return $?
}

function cmake_pico_bin(){
	if [ -f ${PICOBIN_DIR}/CMakeLists.txt ]; then
		if [ ! -d ${PICOBIN_OUT} ]; then
			mkdir ${PICOBIN_OUT}
		else
			echo ${PICOBIN_OUT} exists
		fi
		cd ${PICOBIN_OUT}
		cmake ${PICOBIN_DIR}
	else
		echo "${PICOBIN_DIR}/CMakeLists.txt does not exist!"
		return 1
	fi
	cd ${BIOTRUMP_DIR}
	return $?
}

function cmake_pico(){
	if [ -f ${PICO_DIR}/CMakeLists.txt ]; then
		if [ ! -d ${PICO_OUT} ]; then
			mkdir ${PICO_OUT}
		else
			echo ${PICO_OUT} exists
		fi
		cd ${PICO_OUT}
		cmake ${PICO_DIR}
	else
		echo "${PICO_DIR}/CMakeLists.txt does not exist!"
		return 1
	fi
	cd ${BIOTRUMP_DIR}
	return $?
}

function cmake_config(){
#cmake or cmake-gui first
	mkdir ${BIOTRUMP_OUT}/build
	cd ${BIOTRUMP_OUT}/build
	cmake ${BIOTRUMP_DIR}

	cmake_v4l2_lib
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "cmake error"
		return $ret
	fi

	### v4l2/v4l-capture
	cmake_v4l2_capture
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "cmake error"
		return $ret
	fi

	###PICO face detection
	cmake_pico
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "cmake error"
		return $ret
	fi

	cmake_pico_bin
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "cmake error"
		return $ret
	fi
	return 0
}

#### make targets
###v4l2/v4l2-lib
function v4l2_lib(){
	ret=1
#	echo *=$@
#	read
	if [ -d ${V4L2_LIB_OUT} ]; then
		cd ${V4L2_LIB_OUT}
		make $@
		ret=$?
	else
		echo "${V4L2_LIB_OUT} does not exist."
	fi
	cd ${BIOTRUMP_DIR}
	return ${ret}
}

###
function v4l2_capture(){
	ret=1
#	echo *=$@
#	read
	if [ -d ${V4L2_CAPTURE_OUT} ]; then
		cd ${V4L2_CAPTURE_OUT}
		make $@
		ret=$?
	else
		echo "${V4L2_CAPTURE_OUT} does not exist."
	fi
	cd ${BIOTRUMP_DIR}
	return $ret
}

function pico_bin(){
	ret=1
#	echo *=$@
#	read
	if [ -d ${PICOBIN_OUT} ]; then
		cd ${PICOBIN_OUT}
		make $@
		ret=$?
	else
		echo "${PICOBIN_OUT} does not exist."
	fi
	cd ${BIOTRUMP_DIR}
	return $ret
}

function pico(){
	ret=1
#	echo *=$@
#	read
	if [ -d ${PICO_OUT} ]; then
		cd ${PICO_OUT}
		make $@
		ret=$?
	else
		echo "${PICO_OUT} does not exist"
	fi
	cd ${BIOTRUMP_DIR}
	return $ret
}

function make-all(){
#cmake or cmake-gui first
	v4l2_lib $*
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "make error"
	fi

	### v4l2/v4l-capture
	v4l2_capture $*
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "make error"
	fi

	###PICO face detection
	pico $*
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "make error"
	fi

	pico_bin $*
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "make error"
	fi
}

unset CDPATH
. setup.sh
#if [ -f patches/patch.sh ] ; then
#    . patches/patch.sh
#fi &&
cmake_config
make-all $MAKE_FLAGS $@
#time nice -n19 make-all $MAKE_FLAGS $@

ret=$?
echo -ne \\a
if [ $ret -ne 0 ]; then
	echo
	echo \> Build failed\! \<
	echo
	echo Build with \|./build.sh -j1\| for better messages
	echo If all else fails, use \|rm -rf objdir-gecko\| to clobber gecko and \|rm -rf out\| to clobber everything else.
else
	if echo $DEVICE | grep generic > /dev/null ; then
		echo Run \|./run-emulator.sh\| to start the emulator
		exit 0
	fi
	case "$1" in
	"openCV")
		echo Run \|openCV\| to build openCV only
		;;
	"pico")
		echo Run \|pico\| to build pico only
		;;
	*)
		echo Run \|./flash.sh\| to flash all partitions of your device
		;;
	esac
	exit 0
fi

exit $ret
