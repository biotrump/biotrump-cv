cmake_minimum_required(VERSION 2.8  FATAL_ERROR)
PROJECT( BCV )

#BCV_SOURCE_DIR == CMAKE_SOURCE_DIR
message("CMAKE_SOURCE_DIR : ${CMAKE_SOURCE_DIR}")
message("PROJECT_NAME : ${PROJECT_NAME}")
message("BCV_SOURCE_DIR : ${BCV_SOURCE_DIR}")
message("BCV_BINARY_DIR : ${BCV_BINARY_DIR}")
#${PROJECT_NAME} : Name of the "project" given to the project(BCV) command.
#${BCV_SOURCE_DIR} : path of the "project" source given to the project(BCV) command.
#${BCV_BINARY_DIR} : path of the "project" binary given to the project(BCV) command.
# --------------------------------------------------
#In order to see the symbols from the static library, use:
set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--export-all-symbols")

# --------------------------------------------------
# Organize output files.  On Windows this also keeps .dll files next
# to the .exe files that need them, making tests easy to run.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BCV_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${BCV_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${BCV_BINARY_DIR}/lib)
# --------------------------------------------------

include(cmake/CVEnvImport.cmake)

#set variable from shell's env var by $ENV{env_var}
# ----------------------------------------------------------------------------
if(ANDROID_NDK)
	#buld openCV, static
#	add_custom_target ( opencv
#		COMMAND bash ./opencv.sh
#		WORKING_DIRECTORY ${BCV_SOURCE_DIR}/openCV )
else(ANDROID_NDK)
	#x86 ubuntu : buld openCV, static
	add_custom_target ( opencv
		COMMAND bash ./opencv.sh
		WORKING_DIRECTORY ${BCV_SOURCE_DIR}/openCV )
endif(ANDROID_NDK)

# ----------------------------------------------------------------------------
if(0)
	# ----------------------------------------------------------------------------
	#openMP to avoid link error : omp_xxx error!
	# undefined reference to `GOMP_loop_dynamic_start
	find_package(OpenMP)
	if(OPENMP_FOUND)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	endif()
	# ----------------------------------------------------------------------------
	#opencv should be built first!
	set(OpenCV_DIR $ENV{OPENCV_OUT})
	message("++++OpenCV_DIR:""${OpenCV_DIR}")
	FIND_PACKAGE( OpenCV REQUIRED)
	if(OpenCV_FOUND)
		message("found")
		message( "OpenCV_INCLUDE_DIRS:""${OpenCV_INCLUDE_DIRS}" )
		message( "OpenCV_INCLUDES:""${OpenCV_INCLUDES}")
		message( "OpenCV_LIBRARIES:""${OpenCV_LIBRARIES}")
		message( "OpenCV_LIBS:""${OpenCV_LIBS}")
		message( "OpenCV_DEFINITIONS:""${OpenCV_DEFINITIONS}")
	else()
		message(FATAL_ERROR "openCV not foud")
	endif()
endif(0)
# ----------------------------------------------------------------------------
# Process subdirectories
# ----------------------------------------------------------------------------
#add_subdirectory(v4l2/v4l2-lib ${V4L2_LIB_OUT})
#add_subdirectory(v4l2/v4l-capture ${V4L2_CAPTURE_OUT})
#add_subdirectory(dsp/ica)
#add_subdirectory(v4l2/v4l2-lib)
#add_subdirectory(v4l2/v4l-capture)
#add_subdirectory(pico)
