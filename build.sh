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
function cmake_opencv(){
	if [ -f ${OPENCV_SRC}/CMakeLists.txt ]; then
		if [ ! -d ${OPENCV_OUTT} ]; then
			mkdir ${OPENCV_OUTT}
		else
			echo $OPENCV_OUT} exist
		fi
		cd ${OPENCV_OUT}
		cmake ${OPENCV_SRC} -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
	else
		echo "${OPENCV_SRC}/CMakeLists.txt does not exist!"
		return 1
	fi
	cd ${BIOTRUMP_DIR}
	return $?
}

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
	#cmake to create top build folder
	cd ${BIOTRUMP_OUT}
	cmake -Wno-dev ${BIOTRUMP_DIR}
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "top build cmake error"
	fi
#	echo ">>>> $?"
#	read
	return  $ret

#	cmake_opencv
#	ret=$?
#	echo -ne \\a
#	if [ $ret -ne 0 ]; then
#		echo "opencv cmake error"
#		return $ret
#	fi

	cmake_v4l2_lib
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "v4l2_lib cmake error"
		return $ret
	fi

	### v4l2/v4l-capture
	cmake_v4l2_capture
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "v4l2_capture cmake error"
		return $ret
	fi

	###PICO face detection
	cmake_pico
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "pico cmake error"
		return $ret
	fi

	cmake_pico_bin
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "pico_bin cmake error"
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
#building base lib first!
	v4l2_lib $*
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "make error"
	fi

	cd ${BIOTRUMP_OUT}
	make $@
	ret=$?
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "top build make error"
		return $ret
	fi
	return 0

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

ret=1
. setup.sh
if [[ "$#" -eq 0 || "$#" -eq 1 && "$1" == "-j"* ]]; then
#	echo "###: $#, $1"
	#"." or "source" to run a script: the script will run in the same process space of the shell.
	. opencv.sh $MAKE_FLAGS $@ &&
	#if [ -f patches/patch.sh ] ; then
	#    . patches/patch.sh
	#fi &&
	cmake_config &&
	time make-all $MAKE_FLAGS $@
	#time nice -n19 make-all $MAKE_FLAGS $@
else
	if [[ "$1" == "-j"* ]]; then
		MAKE_FLAGS=$1
		shift
	fi
	case "$1" in
		"openCV")
			echo "building openCV only..."
			shift
			. opencv.sh $MAKE_FLAGS $@
			ret=$?
			;;

		"v4l2")
			###v4l2 lib
			echo "buiding v4l2 library only..."
			shift
			#cmake has prepared the make!
			if [ -f ${V4L2_LIB_OUT}/Makefile ]; then
				pushd ${V4L2_LIB_OUT}
				time make $@
				ret=$?
				popd
			else
				echo ${V4L2_LIB_OUT}/Makefile does not exists.
				echo please \"./build.sh\" first
			fi
			;;

		"pico")
			###PICO face detection
			echo "buiding pico only..."
			shift
			#cmake has prepared the make!
			if [ -f ${PICO_OUT}/Makefile ]; then
				pushd ${PICO_OUT}
				time make $MAKE_FLAGS $@
				ret=$?
				popd
			else
				echo ${PICO_OUT}/Makefile does not exists.
				echo please \"./build.sh\" first
			fi
			;;

		*)
			echo "unknown args: ./build.sh -j# target "
			;;
		esac
fi

#ret=$?
echo -ne \\a
if [ $ret -ne 0 ]; then
	echo
	echo \> Build failed\! \<
	echo
	echo Build with \|./build.sh -j1\| for better messages
	echo If all else fails, use \|rm -rf out/openCV\| to clobber openCV or \|rm -rf out\| to clobber everything else.
#else
#	case "$1" in
#	"openCV")
#		echo Run \|openCV\| to build openCV only
#		;;
#	"pico")
#		echo Run \|pico\| to build pico only
#		;;
#	*)
#		echo Run \|./flash.sh\| to flash all partitions of your device
#		;;
#	esac
#	exit 0
fi

exit $ret
