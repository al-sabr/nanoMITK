#-----------------------------------------------------------------------------
# Configure the CppMicroServices build
#-----------------------------------------------------------------------------

set(CppMicroServices_DIR_default "${CMAKE_CURRENT_BINARY_DIR}/CppMicroServices")
if(NOT CppMicroServices_DIR)
  set(CppMicroServices_DIR ${CppMicroServices_DIR_default} CACHE PATH "Path to the CppMicroServices library" FORCE)
endif()
mark_as_advanced(CppMicroServices_DIR)
