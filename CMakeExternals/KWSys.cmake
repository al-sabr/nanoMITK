#-----------------------------------------------------------------------------
# KWSys
#-----------------------------------------------------------------------------

if(MITK_USE_KWSys)
  # Sanity checks
  if(DEFINED KWSys_DIR AND NOT EXISTS "${KWSys_DIR}")
    message(FATAL_ERROR "KWSys_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj KWSys)
  set(proj_DEPENDENCIES )
  set(KWSys_DEPENDS ${proj})

  if(NOT DEFINED KWSys_DIR)

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
      GIT_REPOSITORY https://github.com/al-sabr/KWSys.git
      GIT_TAG main
      CMAKE_GENERATOR ${gen}
      CMAKE_GENERATOR_PLATFORM ${gen_platform}
      CMAKE_ARGS
        ${ep_common_args}
        ${additional_args}
        -DKWSYS_BUILD_SHARED:BOOL=FALSE
        #-DKWSYS_NAMESPACE:STRING=mitk
        -DKWSYS_INSTALL_EXPORT_NAME:STRING=kwsys
        #-DKWSYS_INSTALL_EXPORT_DIR:STRING=${ep_prefix}/lib/cmake/${KWSYS_INSTALL_EXPORT_NAME}
        -DKWSYS_INSTALL_INCLUDE_DIR:STRING=${ep_prefix}/include/${KWSYS_INSTALL_EXPORT_NAME}
        -DKWSYS_INSTALL_LIB_DIR:STRING=${ep_prefix}/lib
        -DKWSYS_INSTALL_BIN_DIR:STRING=${ep_prefix}/bin
        -DKWSYS_INSTALL_COMPONENT_NAME_RUNTIME:STRING=Runtime
        -DKWSYS_INSTALL_COMPONENT_NAME_DEVELOPMENT:STRING=Development
      CMAKE_CACHE_ARGS
        ${ep_common_cache_args}
      CMAKE_CACHE_DEFAULT_ARGS
        ${ep_common_cache_default_args}
      DEPENDS ${proj_DEPENDENCIES}
    )

    set(${proj}_DIR "${ep_prefix}")
    mitkFunctionInstallExternalCMakeProject(${proj})

  else()
    mitkMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
  endif()
endif()
