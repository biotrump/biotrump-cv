cmake_minimum_required(VERSION 2.8  FATAL_ERROR)
#PROJECT( biotrump-cv )

include(cmake/CVEnvImport.cmake)

#set variable from shell's env var by $ENV{env_var}

#opencv should be built first!
set(OpenCV_DIR $ENV{OPENCV_OUT})
#message("++++OpenCV_DIR:""${OpenCV_DIR}")
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

#openMP to avoid link error : omp_xxx error!
# undefined reference to `GOMP_loop_dynamic_start
find_package(OpenMP)
if(OPENMP_FOUND)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

# ----------------------------------------------------------------------------
# Process subdirectories
# ----------------------------------------------------------------------------
#add_subdirectory(v4l2/v4l2-lib ${V4L2_LIB_OUT})
#add_subdirectory(v4l2/v4l-capture ${V4L2_CAPTURE_OUT})
add_subdirectory(dsp/ica)
add_subdirectory(v4l2/v4l2-lib)
add_subdirectory(v4l2/v4l-capture)
add_subdirectory(pico)
