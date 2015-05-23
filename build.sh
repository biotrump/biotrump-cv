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

###openCV
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
function build_v4l2(){
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

function build_picort-lib(){
	pushd ${PICO_DIR}/rnt/sample
	ret=0
#	if [ "$TARGET_OS" == "ubuntu" ]; then
#		./build_x86_cmake.sh $TARGET_ARCH $@
#	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		./NDK_all.sh $@
#		if [ "$TARGET_ARCH" == "arm" ]; then
#			./build_NDK_cmake.sh $TARGET_ARCH $@
#		fi
#		if [ "$TARGET_ARCH" == "x86_64" ]; then
#			./build_NDK_cmake.sh x86 $MAKE_FLAGS $@
#		fi
	fi
	ret=$?
	echo "pico ret=$ret"
	if [ "$ret" = "0" ]; then
		echo "***************************"
		ls -lR $PICO_OUT/libs
		echo "***************************"
	fi
	popd
	return $ret
}

function build_opencv(){
	pushd ${OPENCV_SRC}
    if [ "$TARGET_OS" == "ubuntu" ]; then
	. opencv.sh $MAKE_FLAGS $@
	ret=$?
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
	echo "TODO"
	fi
	popd
	return $ret
}

#ubuntu x86 only
function build_atlas(){
	if [ "$TARGET_OS" == "ubuntu" ]; then
		pushd ${ATLAS_SRC}
		./atlas_x86.sh config $MAKE_FLAGS $@
		./atlas_x86.sh build $MAKE_FLAGS $@
		ret=$?
		popd
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		echo "ATLAS is not supported in NDK yet"
	fi
	return $ret
}

function build_blis(){
	pushd ${BLIS_DIR}
	ret=0
	if [ "$TARGET_OS" == "ubuntu" ]; then
		./build_x86.sh $MAKE_FLAGS $@
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		if [ "$TARGET_ARCH" == "arm" ]; then
			./build_NDK.sh $TARGET_ARCH $MAKE_FLAGS $@
		fi
		if [ "$TARGET_ARCH" == "x86_64" ]; then
			./build_NDK.sh x86 $MAKE_FLAGS $@
		fi
	fi
	ret=$?
	popd
	return $ret
}

function build_lapack(){
	pushd ${LAPACK_SRC}
	ret=0
	if [ "$TARGET_OS" == "ubuntu" ]; then
		./build_x86.sh $MAKE_FLAGS $@
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		if [ "$TARGET_ARCH" == "arm" ]; then
			./build_NDK_cmake.sh $TARGET_ARCH $MAKE_FLAGS $@
		fi
		if [ "$TARGET_ARCH" == "x86_64" ]; then
			./build_NDK_cmake.sh x86 $MAKE_FLAGS $@
		fi
	fi
	ret=$?
	popd
	return $ret
}

function build_dsplib(){
	pushd ${DSPLIB_DIR}
	ret=0
	if [ "$TARGET_OS" == "ubuntu" ]; then
		./build_x86_cmake.sh $MAKE_FLAGS $@
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		./NDK_all.sh $@
#		if [ "$TARGET_ARCH" == "arm" ]; then
#			./build_NDK_cmake.sh $TARGET_ARCH $MAKE_FLAGS $@
#		fi
#		if [ "$TARGET_ARCH" == "x86_64" ]; then
#			./build_NDK_cmake.sh x86 $MAKE_FLAGS $@
#		fi
	fi
	ret=$?
	echo "dsplib ret=$ret"
	if [ "$ret" = "0" ]; then
		echo "***************************"
		ls -lR $DSP_OUT/lib/libs
		echo "***************************"
	fi
	popd
	return $ret
}

function build_ffts(){
	ret=0
	pushd ${FFTS_DIR}
	if [ "$TARGET_OS" == "ubuntu" ]; then
		./build_x86.sh $MAKE_FLAGS $@
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		./NDK_all.sh $@
#		if [ "$TARGET_ARCH" == "arm" ]; then
#			./build_NDK.sh $TARGET_ARCH $MAKE_FLAGS $@
#		fi
#		if [ "$TARGET_ARCH" == "x86_64" ]; then
#			./build_NDK.sh x86 $MAKE_FLAGS $@
#		fi
	fi
	ret=$?
	popd
	return $ret
}

function build_ffte(){
	ret=0
	pushd ${FFTE_DIR}
	if [ "$TARGET_OS" == "ubuntu" ]; then
		./build_x86.sh $MAKE_FLAGS $@
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		./NDK_all.sh $@
	fi
	ret=$?
	popd
	return $ret
}

function build_nufft(){
	ret=0
	pushd ${NUFFT_DIR}
	if [ "$TARGET_OS" == "ubuntu" ]; then
		./build_x86.sh $MAKE_FLAGS $@
	fi
	if [ "$TARGET_OS" == "NDK" ]; then
		./NDK_all.sh $@
	fi
	ret=$?
	popd
	return $ret
}

function build_rppg(){
	ret=0
	pushd ${rPPG_DIR}
	if [ "$TARGET_OS" == "ubuntu" ]; then
		./build_x86_cmake.sh $MAKE_FLAGS $@
	fi
#	if [ "$TARGET_OS" == "NDK" ]; then
#		if [ "$TARGET_ARCH" == "arm" ]; then
#			./buid_NDK.sh $TARGET_ARCH $MAKE_FLAGS $@
#		fi
#		if [ "$TARGET_ARCH" == "x86_64" ]; then
#			./buid_NDK.sh x86 $MAKE_FLAGS $@
#		fi
#	fi
	ret=$?
	popd
	return $ret
}

function make-all(){
#openCV first
if [ "$TARGET_OS" == "ubuntu" ]; then
	build_ffts $*
	build_opencv $*
	build_atlas $*
	build_blis  $*
	build_rppg $*
	echo "cmake ...."
	pushd ${BIOTRUMP_OUT}
	if [ "$TARGET_OS" == "ubuntu" ]; then
		cmake ${BIOTRUMP_DIR}
		make $@
		ret=$?
	fi
	echo -ne \\a
	if [ $ret -ne 0 ]; then
		echo "top build make error"
		return $ret
	fi
fi
if [ "$TARGET_OS" == "NDK" ]; then
	build_picort-lib $*
	build_ffts $*
	build_ffte $*
	build_nufft $*
#	build_opencv $*
	build_blis  $*
	build_lapack $*
	build_dsplib $*
	ret=$?
fi
	return 0
}

ret=1
. setup.sh
export
if [[ "$#" -eq 0 || "$#" -eq 1 && "$1" == "-j"* ]]; then
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
			build_opencv $*
			;;

		"ATLAS")
			echo "building ATLAS and lapack ..."
			shift
			build_atlas $*
			;;

		"picort-lib")
			echo "building picort-lib only..."
			shift
			build_picort-lib $*
			;;

		"ffts")
			echo "building ffts only..."
			shift
			build_ffts $*
			;;

		"ffte")
			echo "building ffte only..."
			shift
			build_ffte $*
			;;

		"nufft")
			echo "building nufft only..."
			shift
			build_nufft $*
			;;

		"blis")
			echo "building blis only..."
			shift
			build_blis $*
			;;

		"v4l2")
			###v4l2 lib
			echo "buiding v4l2 library only..."
			shift
			build_v4l2 $*

			;;

		"lapack")
			echo "building lapack only..."
			shift
			build_lapack $*
			#. lapack.sh $MAKE_FLAGS $@
			ret=$?
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

		"dsplib")
			echo "building dsplib only..."
			shift
			build_dsplib $*
			ret=$?
			;;

		"rPPG")
			echo "building rPPG only..."
			shift
			build_rppg $*
			ret=$?
			;;

		*)
			echo ""
			echo "???? unknown args: ./build.sh -j# target "
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
