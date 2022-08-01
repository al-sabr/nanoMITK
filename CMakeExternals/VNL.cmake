#-----------------------------------------------------------------------------
# VNL
#-----------------------------------------------------------------------------

if(MITK_USE_VNL)
  # Sanity checks
  if(DEFINED VNL_DIR AND NOT EXISTS "${VNL_DIR}")
    message(FATAL_ERROR "VNL_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj VNL)
  set(proj_DEPENDENCIES )
  set(VNL_DEPENDS ${proj})

  if(NOT DEFINED VNL_DIR)

    set(additional_args )

    if(NOT CMAKE_DEBUG_POSTFIX)
      list(APPEND additional_args "-DCMAKE_DEBUG_POSTFIX:STRING=d")
    endif()

    if(CTEST_USE_LAUNCHERS)
      list(APPEND additional_args
        "-DCMAKE_PROJECT_${proj}_INCLUDE:FILEPATH=${CMAKE_ROOT}/Modules/CTestUseLaunchers.cmake"
      )
    endif()

    ExternalProject_Add(${proj}
      LIST_SEPARATOR ${sep}
      GIT_REPOSITORY https://github.com/al-sabr/VNL.git
      GIT_TAG main
      CMAKE_GENERATOR ${gen}
      CMAKE_GENERATOR_PLATFORM ${gen_platform}
      CMAKE_ARGS
        ${ep_common_args}
        ${additional_args}
        -DVNL_BUILD_SHARED:BOOL=FALSE
        #-DVXL_INSTALL_EXPORT_NAME:STRING=
        -DVXL_LIBRARY_DIR:STRING=${ep_prefix}/lib
        -DVXL_CONFIG_CMAKE_DIR:STRING=${ep_prefix}/lib/cmake/vxl
        -DBUILD_SHARED_LIBS:BOOL=OFF

      CMAKE_CACHE_ARGS
        ${ep_common_cache_args}
      CMAKE_CACHE_DEFAULT_ARGS
        ${ep_common_cache_default_args}
      DEPENDS ${proj_DEPENDENCIES}
    )

    set(${proj}_DIR ${VXL_CONFIG_CMAKE_DIR})
    mitkFunctionInstallExternalCMakeProject(${proj})

  else()
    mitkMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
  endif()
endif()
