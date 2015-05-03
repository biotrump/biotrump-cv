#!/bin/bash
#curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
REPO=${REPO:-~/bin/repo}
sync_flags=""

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $BRANCH -m $1.xml $REPO_INIT_FLAGS &&
	$REPO sync $sync_flags $REPO_SYNC_FLAGS
	ret=$?
	if [ "$GITREPO" = "$GIT_TEMP_REPO" ]; then
		rm -rf $GIT_TEMP_REPO
	fi
	if [ $ret -ne 0 ]; then
		echo Repo sync failed
		exit -1
	fi
}

case `uname` in
"Darwin")
	# Should also work on other BSDs
	CORE_COUNT=`sysctl -n hw.ncpu`
	;;
"Linux")
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
CYGWIN*)
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
*)
	echo Unsupported platform: `uname`
	exit -1
esac

GITREPO=${GITREPO:-"https://github.com/biotrump/manifest-cv"}
BRANCH=${BRANCH:-master}
#BRANCH=${BRANCH:-opencv-2.4.x}

while [ $# -ge 1 ]; do
	case $1 in
	-d|-l|-f|-n|-c|-q|-j*) # repo sync option
		sync_flags="$sync_flags $1"
		if [ $1 = "-j" ]; then
			shift
			sync_flags+=" $1"
		fi
		shift
		;;
	--help|-h)
		# The main case statement will give a usage message.
		echo ---help
		exit 1
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

GIT_TEMP_REPO="tmp_manifest_repo"
if [ -n "$2" ]; then
	GITREPO=$GIT_TEMP_REPO
	rm -rf $GITREPO &&
	git init $GITREPO &&
	cp $2 $GITREPO/$1.xml &&
	cd $GITREPO &&
	git add $1.xml &&
	git commit -m "manifest" &&
	git branch -m $BRANCH &&
	cd ..
fi

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config

#############################################
#biotrump cv Home
#############################################
BIOTRUMP_DIR=${BIOTRUMP_DIR:-$PWD}
echo BIOTRUMP_DIR=${BIOTRUMP_DIR} >> .tmp-config

BIOTRUMP_OUT=${BIOTRUMP_OUT:-$BIOTRUMP_DIR/out}
echo BIOTRUMP_OUT=${BIOTRUMP_OUT} >> .tmp-config
if [ ! -d ${BIOTRUMP_OUT} ]; then
	mkdir ${BIOTRUMP_OUT}
fi

#############################################
#ubuntu x86, android/NDK arm, x86
#############################################
#echo DEVICE_NAME=$1 >> .tmp-config
#echo DEVICE=hammerhead >> .tmp-config &&

#############################################
#NDK and SDK
#############################################
if [ -d ${HOME}/NDK/android-ndk-r10d ]; then
export NDK_ROOT=${HOME}/NDK/android-ndk-r10d
else
echo "I can't find android-ndk-r10d under ${HOME}/NDK!"
echo "Please export NDK_ROOT!!!"
fi
#gofortran is supported in r9
#./toolchains/arm-linux-androideabi-4.8.0/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gfortran
#./toolchains/x86-4.8.0/prebuilt/linux-x86_64/bin/i686-linux-android-gfortran
if [ -d ${HOME}/NDK/android-ndk-r9 ]; then
export NDK_ROOT_FORTRAN=${HOME}/NDK/android-ndk-r9
else
echo "Please specify your gofortran NDK to NDK_ROOT_FORTRAN"
fi

#############################################
#OPENCV_DIR and Branch
#default is static binding for openCV
#############################################
OPENCV_SRC=${OPENCV_SRC:-${BIOTRUMP_DIR}/openCV}
echo OPENCV_SRC=${OPENCV_SRC} >> .tmp-config
#openCV branch is 2.4.x, x >= 9, but openCV 3.0 is still Beta.
#many projects will depend on this branch
#OPENCV_BRANCH=${OPENCV_BRANCH:-Itseez-master}
#OPENCV_BRANCH=${OPENCV_BRANCH:-master}
OPENCV_BRANCH=${OPENCV_BRANCH:-2.4.x}
echo OPENCV_BRANCH=${OPENCV_BRANCH} >> .tmp-config

#static build
OPENCV_BUILD_SHARED_LIBS=${OPENCV_BUILD_SHARED_LIBS:-OFF}
echo OPENCV_BUILD_SHARED_LIBS=${OPENCV_BUILD_SHARED_LIBS} >> .tmp-config
#build/output folder of openCV
if [ ${OPENCV_BUILD_SHARED_LIBS} = "OFF" ]; then
	OPENCV_OUT=${OPENCV_OUT:-${BIOTRUMP_OUT}/openCV/${OPENCV_BRANCH}-static}
else
	OPENCV_OUT=${OPENCV_OUT:-${BIOTRUMP_OUT}/openCV/${OPENCV_BRANCH}-shared}
fi
echo OPENCV_OUT=${OPENCV_OUT} >> .tmp-config
echo OPENCV_DIR=${OPENCV_OUT} >> .tmp-config

#############################################
#dsp
#############################################
if [ -d ${BIOTRUMP_DIR}/dsp ]; then
	DSP_HOME=${DSP_HOME:-$BIOTRUMP_DIR/dsp}
	echo DSP_HOME=${DSP_HOME} >> .tmp-config
	DSP_OUT=${DSP_OUT:-${BIOTRUMP_OUT}/dsp}
	echo DSP_OUT=${DSP_OUT} >> .tmp-config
	if [ ! -d ${DSP_OUT} ] ;then
		mkdir ${DSP_OUT}
	fi
else
	echo "${BIOTRUMP_DIR}/dsp does not exist! quit"
	exit -1
fi

#############################################
#ATLAS
#############################################
if [ -d ${DSP_HOME}/ATLAS ]; then
	ATLAS_SRC=${ATLAS_SRC:-${DSP_HOME}/ATLAS}
	echo ATLAS_SRC=${ATLAS_SRC} >> .tmp-config
	ATLAS_BRANCH=${ATLAS_BRANCH:-Rev1531}
	echo ATLAS_BRANCH=${ATLAS_BRANCH} >> .tmp-config
	ATLAS_OUT=${ATLAS_OUT:-${DSP_OUT}/ATLAS}
	echo ATLAS_OUT=${ATLAS_OUT} >> .tmp-config
	if [ ! -d ${ATLAS_OUT} ]; then
		mkdir ${ATLAS_OUT}
	fi
else
	echo "${DSP_HOME}/ATLAS does not exist!"
fi
#############################################
#LAPACK
#############################################
if [ -d ${DSP_HOME}/LAPACK ]; then
	LAPACK_SRC=${LAPACK_SRC:-${DSP_HOME}/LAPACK}
	echo LAPACK_SRC=${LAPACK_SRC} >> .tmp-config
	LAPACK_OUT=${LAPACK_OUT:-${DSP_OUT}/LAPACK}
	echo LAPACK_OUT=${LAPACK_OUT} >> .tmp-config
	if [ ! -d ${LAPACK_OUT} ]; then
		mkdir ${LAPACK_OUT}
	fi
else
	echo "${DSP_HOME}/LAPACK does not exist!"
fi
#############################################
#ffts
#############################################
if [ -d ${DSP_HOME}/ffts ]; then
	FFTS_DIR=${FFTS_DIR:-${DSP_HOME}/ffts}
	echo FFTS_DIR=${FFTS_DIR} >> .tmp-config
	FFTS_OUT=${FFTS_OUT:-${DSP_OUT}/ffts}
	echo FFTS_OUT=${FFTS_OUT} >> .tmp-config
	if [ ! -d ${FFTS_OUT} ]; then
		mkdir ${FFTS_OUT}
	fi
else
	echo "${DSP_HOME}/ffts does not exist!"
fi
#############################################
#blis
#############################################
if [ -d ${DSP_HOME}/ffts ]; then
	BLIS_DIR=${BLIS_DIR:-${DSP_HOME}/blis}
	echo BLIS_DIR=${BLIS_DIR} >> .tmp-config
	BLIS_OUT=${BLIS_OUT:-${DSP_OUT}/blis}
	echo BLIS_OUT=${BLIS_OUT} >> .tmp-config
	if [ ! -d ${BLIS_OUT} ]; then
		mkdir ${BLIS_OUT}
	fi
else
	echo "${DSP_HOME}/blis does not exist!"
fi
#############################################
#v4l2
#############################################
if [ -d ${BIOTRUMP_DIR}/v4l2 ]; then
	V4L2_HOME=${V4L2_HOME:-$BIOTRUMP_DIR/v4l2}
	echo V4L2_HOME=${V4L2_HOME} >> .tmp-config
	V4L2_OUT=${V4L2_OUT:-${BIOTRUMP_OUT}/v4l2}
	echo V4L2_OUT=${V4L2_OUT} >> .tmp-config
	if [ ! -d ${V4L2_OUT} ] ;then
		mkdir ${V4L2_OUT}
	fi
else
	echo "${BIOTRUMP_DIR}/v4l2 does not exist! quit"
	exit -1
fi
#############################################
###v4l2/v4l2-lib
#############################################
if [ -d ${V4L2_HOME}/v4l2-lib ]; then
	V4L2_LIB_DIR=${V4L2_LIB_DIR:-${V4L2_HOME}/v4l2-lib}
	echo V4L2_LIB_DIR=${V4L2_LIB_DIR} >> .tmp-config
	V4L2_LIB_OUT=${V4L2_LIB_OUT:-${V4L2_OUT}/v4l2-lib}
	echo V4L2_LIB_OUT=${V4L2_LIB_OUT} >> .tmp-config
	if [ ! -d ${V4L2_LIB_OUT} ] ;then
		mkdir ${V4L2_LIB_OUT}
	fi
else
	echo "${BIOTRUMP_DIR}/v4l2/v4l2-lib/CMakeLists.txt does not exist!"
fi

#############################################
### v4l2/v4l-capture
#############################################
#if [ -d ${BIOTRUMP_DIR}/v4l2/v4l-capture ]; then
#	if [ -f ${BIOTRUMP_DIR}/v4l2/v4l-capture/CMakeLists.txt ]; then
#		V4L2_CAPTURE_DIR=${V4L2_CAPTURE_DIR:-${BIOTRUMP_DIR}/v4l2/v4l-capture}
#		echo V4L2_CAPTURE_DIR=${V4L2_CAPTURE_DIR} >> .tmp-config
#		V4L2_CAPTURE_OUT=${V4L2_CAPTURE_OUT:-${BIOTRUMP_OUT}/v4l2/v4l-capture}
#		echo V4L2_CAPTURE_OUT=${V4L2_CAPTURE_OUT} >> .tmp-config
#	else
#		echo "${BIOTRUMP_DIR}/v4l2/v4l-capture/CMakeLists.txt does not exist!"
#	fi
#else
#	echo "${BIOTRUMP_DIR}/v4l2/v4l-capture does not exist!"
#fi
#
#############################################
#cv
#############################################
if [ -d ${BIOTRUMP_DIR}/cv ]; then
	CV_HOME=${CV_HOME:-$BIOTRUMP_DIR/cv}
	echo CV_HOME=${CV_HOME} >> .tmp-config
	CV_OUT=${CV_OUT:-${BIOTRUMP_OUT}/cv}
	echo CV_OUT=${CV_OUT} >> .tmp-config
	if [ ! -d ${CV_OUT} ] ;then
		mkdir ${CV_OUT}
	fi
else
	echo "${BIOTRUMP_DIR}/cv does not exist! quit"
	exit -1
fi
#############################################
###PICO
#############################################
#	if [ -f ${BIOTRUMP_DIR}/pico/runtime/pico-bin/C/CMakeLists.txt ]; then
#		PICOBIN_DIR=${PICOBIN_DIR:-${BIOTRUMP_DIR}/pico/runtime/pico-bin/C}
#		echo PICOBIN_DIR=${PICOBIN_DIR} >> .tmp-config
#		PICOBIN_OUT=${PICOBIN_OUT:-${BIOTRUMP_OUT}/pico-bin}
#		if [ ! -d ${PICOBIN_OUT} ]; then
#			mkdir ${PICOBIN_OUT}
#		fi
#		echo PICOBIN_OUT=${PICOBIN_OUT} >> .tmp-config
#	else
#		echo "${BIOTRUMP_DIR}/pico/runtime/pico-bin/C/CMakeLists.txt does not exist!"
#	fi
if [ -d ${CV_HOME}/pico ]; then
	PICO_DIR=${PICO_DIR:-${CV_HOME}/pico}
	echo PICO_DIR=${PICO_DIR} >> .tmp-config
	PICO_OUT=${PICO_OUT:-${CV_OUT}/pico}
	echo PICO_OUT=${PICO_OUT} >> .tmp-config
	if [ ! -d ${PICO_OUT} ] ;then
		mkdir ${PICO_OUT}
	fi
else
	echo "${CV_HOME}/pico does not exist!"
fi
#############################################
#rPPG
#############################################
if [ -d ${CV_HOME}/rPPG ]; then
	rPPG_DIR=${rPPG_DIR:-${CV_HOME}/rPPG}
	echo rPPG_DIR=${rPPG_DIR} >> .tmp-config
	rPPG_OUT=${rPPG_OUT:-${CV_OUT}/rPPG}
	echo rPPG_OUT=${rPPG_OUT} >> .tmp-config
	echo rPPG_OUT=${rPPG_OUT}
	if [ ! -d ${rPPG_OUT} ] ;then
		mkdir ${rPPG_OUT}
	fi
else
	echo "${CV_HOME}/rPPG does not exist!"
fi
#############################################
#stasms
#############################################
if [ -d ${CV_HOME}/stasms ]; then
	STASMS_DIR=${STASMS_DIR:-${CV_HOME}/stasms}
	echo STASMS_DIR=${STASMS_DIR} >> .tmp-config
	STASMS_OUT=${STASMS_OUT:-${CV_OUT}/stasms}
	echo STASMS_OUT=${STASMS_OUT} >> .tmp-config
	if [ ! -d ${STASMS_OUT} ] ;then
		mkdir ${STASMS_OUT}
	fi
else
	echo "${CV_HOME}/stasms does not exist!"
fi
#############################################
#sync codes
repo_sync cv
if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config
echo
echo "*** config file is stored in ${PWD}/.config"
cat ${PWD}/.config

echo Run \|./build.sh\| to start building
echo "Or . setup.sh to export ENV before you build any specific project."
