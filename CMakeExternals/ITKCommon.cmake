#-----------------------------------------------------------------------------
# ITKCommon
#-----------------------------------------------------------------------------

if(MITK_USE_ITKCommon)
  # Sanity checks
  if(DEFINED ITKCommon_DIR AND NOT EXISTS "${ITKCommon_DIR}")
    message(FATAL_ERROR "ITKCommon_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj ITKCommon)
  set(proj_DEPENDENCIES )
  set(ITKCommon_DEPENDS ${proj})

  if(NOT DEFINED ITKCommon_DIR)

    set(additional_args )

    if(NOT CMAKE_DEBUG_POSTFIX)
      list(APPEND additional_args "-DCMAKE_DEBUG_POSTFIX:STRING=d")
    endif()

    if(CTEST_USE_LAUNCHERS)
      list(APPEND additional_args
        "-DCMAKE_PROJECT_${proj}_INCLUDE:FILEPATH=${CMAKE_ROOT}/Modules/CTestUseLaunchers.cmake"
      )
    endif()

    mitk_query_custom_ep_vars()
    
    ExternalProject_Add(${proj}
      LIST_SEPARATOR ${sep}
      GIT_REPOSITORY https://github.com/al-sabr/ITKCommon
      GIT_TAG main
      CMAKE_GENERATOR ${gen}
      CMAKE_GENERATOR_PLATFORM ${gen_platform}
      CMAKE_ARGS
        ${ep_common_args}
        ${additional_args}
        ${${proj}_CUSTOM_CMAKE_ARGS}
      CMAKE_CACHE_ARGS
        ${ep_common_cache_args}
        ${${proj}_CUSTOM_CMAKE_CACHE_ARGS}
      CMAKE_CACHE_DEFAULT_ARGS
        ${ep_common_cache_default_args}
        ${${proj}_CUSTOM_CMAKE_CACHE_DEFAULT_ARGS}
      DEPENDS ${proj_DEPENDENCIES}
    )

    set(${proj}_DIR "${ep_prefix}")
    mitkFunctionInstallExternalCMakeProject(${proj})

  else()
    mitkMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
  endif()
endif()
