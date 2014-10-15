#!/bin/bash
#curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
REPO=${REPO:-~/bin/repo}
sync_flags=""

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $OPENCV_BRANCH -m $1.xml $REPO_INIT_FLAGS &&
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
*)
	echo Unsupported platform: `uname`
	exit -1
esac

GITREPO=${GITREPO:-"https://github.com/biotrump/manifest-cv"}
OPENCV_BRANCH=${OPENCV_BRANCH:-2.4.x}
while [ $# -ge 1 ]; do
	case $1 in
	-d|-l|-f|-n|-c|-q|-j*)
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
	git branch -m $OPENCV_BRANCH &&
	cd ..
fi

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config

BIOTRUMP_DIR=${BIOTRUMP_DIR:-$PWD}
echo BIOTRUMP_DIR=${BIOTRUMP_DIR} >> .tmp-config
BIOTRUMP_OUT=${BIOTRUMP_OUT:-$PWD/out}
echo BIOTRUMP_OUT=${BIOTRUMP_OUT} >> .tmp-config
#echo DEVICE_NAME=$1 >> .tmp-config
#echo DEVICE=hammerhead >> .tmp-config &&

###OPENCV_DIR and Branch
#default is static binding for openCV
OPENCV_BUILD_SHARED_LIBS=${OPENCV_BUILD_SHARED_LIBS:-OFF}
echo OPENCV_BUILD_SHARED_LIBS=${OPENCV_BUILD_SHARED_LIBS} >> .tmp-config
#openCV branch is 2.4.x, x >= 9
#many projects will depend on this branch
echo OPENCV_BRANCH=${OPENCV_BRANCH} >> .tmp-config
#source of openCV
OPENCV_SRC=${OPENCV_SRC:-${BIOTRUMP_DIR}/openCV}
echo OPENCV_SRC=${OPENCV_SRC} >> .tmp-config

#build/output folder of openCV
if [ ${OPENCV_BUILD_SHARED_LIBS} = "OFF" ]; then
OPENCV_OUT=${OPENCV_OUT:-${BIOTRUMP_OUT}/openCV/${OPENCV_BRANCH}-static}
else
OPENCV_OUT=${OPENCV_OUT:-${BIOTRUMP_OUT}/openCV/${OPENCV_BRANCH}-shared}
fi
OPENCV_OUT=${OPENCV_OUT:-${BIOTRUMP_OUT}/openCV/${OPENCV_BRANCH}-${}}
echo OPENCV_OUT=${OPENCV_OUT} >> .tmp-config
echo OPENCV_DIR=${OPENCV_OUT} >> .tmp-config

###v4l2/v4l2-lib
if [ -d ${BIOTRUMP_DIR}/v4l2/v4l2-lib ]; then
	if [ -f ${BIOTRUMP_DIR}/v4l2/v4l2-lib/CMakeLists.txt ]; then
		V4L2_LIB_DIR=${V4L2_LIB_DIR:-${BIOTRUMP_DIR}/v4l2/v4l2-lib}
		echo V4L2_LIB_DIR=${V4L2_LIB_DIR} >> .tmp-config
		V4L2_LIB_OUT=${V4L2_LIB_OUT:-${BIOTRUMP_OUT}/v4l2/v4l2-lib}
		echo V4L2_LIB_OUT=${V4L2_LIB_OUT} >> .tmp-config
	else
		echo "${BIOTRUMP_DIR}/v4l2/v4l2-lib/CMakeLists.txt does not exist!"
	fi
else
	echo "${BIOTRUMP_DIR}/v4l2/v4l2-lib does not exist!"
fi

### v4l2/v4l-capture
if [ -d ${BIOTRUMP_DIR}/v4l2/v4l-capture ]; then
	if [ -f ${BIOTRUMP_DIR}/v4l2/v4l-capture/CMakeLists.txt ]; then
		V4L2_CAPTURE_DIR=${V4L2_CAPTURE_DIR:-${BIOTRUMP_DIR}/v4l2/v4l-capture}
		echo V4L2_CAPTURE_DIR=${V4L2_CAPTURE_DIR} >> .tmp-config
		V4L2_CAPTURE_OUT=${V4L2_CAPTURE_OUT:-${BIOTRUMP_OUT}/v4l2/v4l-capture}
		echo V4L2_CAPTURE_OUT=${V4L2_CAPTURE_OUT} >> .tmp-config
	else
		echo "${BIOTRUMP_DIR}/v4l2/v4l-capture/CMakeLists.txt does not exist!"
	fi
else
	echo "${BIOTRUMP_DIR}/v4l2/v4l-capture does not exist!"
fi

###PICO
if [ -d ${BIOTRUMP_DIR}/pico ]; then
	if [ -f ${BIOTRUMP_DIR}/pico/runtime/pico-bin/C/CMakeLists.txt ]; then
		PICOBIN_DIR=${PICOBIN_DIR:-${BIOTRUMP_DIR}/pico/runtime/pico-bin/C}
		echo PICOBIN_DIR=${PICOBIN_DIR} >> .tmp-config
		PICOBIN_OUT=${PICOBIN_OUT:-${BIOTRUMP_OUT}/pico-bin}
		if [ ! -d ${PICOBIN_OUT} ]; then
			mkdir ${PICOBIN_OUT}
		fi
		echo PICOBIN_OUT=${PICOBIN_OUT} >> .tmp-config
	else
		echo "${BIOTRUMP_DIR}/pico/runtime/pico-bin/C/CMakeLists.txt does not exist!"
	fi

	if [ -f ${BIOTRUMP_DIR}/pico/runtime/samples/C/CMakeLists.txt ]; then
		PICO_DIR=${PICO_DIR:-${BIOTRUMP_DIR}/pico/runtime/samples/C}
		echo PICO_DIR=${PICO_DIR} >> .tmp-config
		PICO_OUT=${PICO_OUT:-${BIOTRUMP_OUT}/pico}
		if [ ! -d ${PICO_OUT} ]; then
			mkdir ${PICO_OUT}
		fi
		echo PICO_OUT=${PICO_OUT} >> .tmp-config
	else
		echo "${BIOTRUMP_DIR}/pico/runtime/samples/C/CMakeLists.txt does not exist!"
	fi

#	if [ -f ${BIOTRUMP_DIR}/pico/learning/sample/CMakeLists.txt ]; then

#	fi
else
	echo "${BIOTRUMP_DIR}/pico does not exist!"
fi

#sync codes
#repo_sync pico-bin
repo_sync cv
if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config
echo "config file is stored in ${PWD}/.config"

echo Run \|./build.sh\| to start building

