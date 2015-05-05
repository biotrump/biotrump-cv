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
#export ENVs to cmake subproejcts
#set variable from shell's env var by $ENV{env_var}
include(cmake/CVEnvImport.cmake)
set(BCV_ENV_EXPORTED "1")

# ----------------------------------------------------------------------------
#openMP to avoid link error : omp_xxx error!
# undefined reference to `GOMP_loop_dynamic_start
#pass the OPENMP_FOUND to subfolders
find_package(OpenMP)
if(OPENMP_FOUND)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

# --------------------------------------------------
# Make a target to generate the documentation.  If Doxygen isn't installed, then
# I guess this option will just be unavailable.
find_package(Doxygen)

if(ANDROID_NDK)
find_host_package(Doxygen)
endif(ANDROID_NDK)

if (DOXYGEN_FOUND)
  # Preprocess the Doxyfile.  This is done before 'make doc'.
  add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/Doxyfile
      PRE_BUILD
      COMMAND ${CMAKE_COMMAND} -D DESTDIR="${CMAKE_BINARY_DIR}" -P
          "${CMAKE_CURRENT_SOURCE_DIR}/CMake/GenerateDoxyfile.cmake"
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
      COMMENT "Creating Doxyfile to generate Doxygen documentation"
  )

  # Generate documentation.
  add_custom_target(doc
      COMMAND "${DOXYGEN_EXECUTABLE}" "${CMAKE_BINARY_DIR}/Doxyfile"
      DEPENDS "${CMAKE_BINARY_DIR}/Doxyfile"
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      COMMENT "Generating API documentation with Doxygen"
  )

  install(DIRECTORY ${CMAKE_BINARY_DIR}/doc/html
      DESTINATION share/doc/mlpack
      COMPONENT doc
      OPTIONAL
  )
endif (DOXYGEN_FOUND)
# ----------------------------------------------------------------------------
# openCV for x86
if(ANDROID_NDK)
	#buld openCV, static
#	add_custom_target ( opencv
#		COMMAND bash ./cmake_android_arm.sh
#		WORKING_DIRECTORY ${BCV_SOURCE_DIR}/openCV )
else(ANDROID_NDK)
	message("++++OPENCV_OUT:${OPENCV_OUT}")
	message("++++OpenCV_FOUND:${OpenCV_FOUND}")
	message("++++OpenCV_DIR:${OpenCV_DIR}")
	FIND_PACKAGE( OpenCV REQUIRED)
	if(OpenCV_FOUND)
		message("found")
		message( "OpenCV_INCLUDE_DIRS:${OpenCV_INCLUDE_DIRS}" )
		message( "OpenCV_INCLUDES:${OpenCV_INCLUDES}")
		message( "OpenCV_LIBRARIES:${OpenCV_LIBRARIES}")
		message( "OpenCV_LIBS:${OpenCV_LIBS}")
		message( "OpenCV_DEFINITIONS:${OpenCV_DEFINITIONS}")
	else(OpenCV_FOUND)
		message(FATAL_ERROR "openCV not foud")
	endif(OpenCV_FOUND)

endif(ANDROID_NDK)

# ----------------------------------------------------------------------------
# Process subdirectories
# ----------------------------------------------------------------------------
#v4l2/v4l2-lib
# ----------------------------------------------------------------------------
if("${V4L2_LIB_DIR}" STREQUAL "")
	set(V4L2_LIB_DIR ${BCV_SOURCE_DIR}/v4l2/v4l2-lib )
endif()
message( "V4L2_LIB_DIR=${V4L2_LIB_DIR}" )
find_path(V4L2_INC capture-v4l2.h
			HINTS "${V4L2_LIB_DIR}" )
message( "V4L2_INC=${V4L2_INC}" )
if(V4L2_INC)
	add_subdirectory(v4l2/v4l2-lib)
	include_directories("${V4L2_INC}")
endif(V4L2_INC)
# ----------------------------------------------------------------------------
add_subdirectory(dsp)
# ----------------------------------------------------------------------------
#cv/pico
# ----------------------------------------------------------------------------
#if("${PICO_DIR}" STREQUAL "")
#	set(PICO_DIR ${BCV_SOURCE_DIR}/cv/pico )
#endif()
message( "PICO_DIR=${PICO_DIR}" )
find_path(PICO_INC picornt.h
			HINTS "${PICO_DIR}/rnt" )
message( "PICO_INC=${PICO_INC}" )
if(PICO_INC)
	add_subdirectory(cv/pico)
	include_directories("${PICO_INC}")
endif(PICO_INC)
# ----------------------------------------------------------------------------
#cv/rPPG
# ----------------------------------------------------------------------------
#if(rPPG_DIR)
#	add_subdirectory(cv/rPPG)
if(ANDROID_NDK)
	#buld openCV, static
#	add_custom_target ( opencv
#		COMMAND bash ./cmake_android_arm.sh
#		WORKING_DIRECTORY ${BCV_SOURCE_DIR}/openCV )
else(ANDROID_NDK)
	#x86 ubuntu : buld openCV, static
	add_custom_target ( rPPG
		COMMAND bash ./build_x86_cmake.sh ${MAKE_FLAGS}
		WORKING_DIRECTORY ${rPPG_DIR} )
endif(ANDROID_NDK)
#endif(rPPG_DIR)
# --------------------------------------------------
if(ANDROID_NDK)
	add_executable(dummy
		dummy.c
	)
else(ANDROID_NDK)
	add_executable(dummy
		dummy.c
	)
	#opencv should be built first before all projects are built.
	add_dependencies(dummy
					rPPG
	#				dsp
					)
endif(ANDROID_NDK)