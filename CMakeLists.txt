cmake_minimum_required(VERSION 2.8  FATAL_ERROR)
PROJECT( biotrump-cv )

#default build targets
#set_target_properties( biotrump-cv
#    PROPERTIES
#    ARCHIVE_OUTPUT_DIRECTORY "${BIOTRUMP_OUT}"
#    LIBRARY_OUTPUT_DIRECTORY "${BIOTRUMP_OUT}"
#    RUNTIME_OUTPUT_DIRECTORY "${BIOTRUMP_OUT}"
#)

# ----------------------------------------------------------------------------
# Process subdirectories
# ----------------------------------------------------------------------------
#$ENV{VAR} to get shell env
set(V4L2_LIB_DIR $ENV{V4L2_LIB_DIR})
set(V4L2_LIB_OUT $ENV{V4L2_LIB_OUT} )
add_subdirectory(v4l2/v4l2-lib ${V4L2_LIB_OUT})
add_subdirectory(v4l2/v4l-capture ${V4L2_CAPTURE_OUT})
add_subdirectory(pico)