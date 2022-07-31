set(proj CppMicroServices)
set(proj_DEPENDENCIES nlohmann_json)

if(MITK_USE_${proj})
  set(${proj}_DEPENDS ${proj})

  if(DEFINED ${proj}_DIR AND NOT EXISTS ${${proj}_DIR})
    message(FATAL_ERROR "${proj}_DIR variable is defined but corresponds to non-existing directory!")
  endif()

  mitk_query_custom_ep_vars()

  set(custom_path "${ep_prefix}/lib/cmake/CppMicroServices")

  if(NOT DEFINED ${proj}_DIR AND NOT nlohmann_json_FOUND)
    ExternalProject_Add(${proj}
      LIST_SEPARATOR ${sep}
      GIT_REPOSITORY https://github.com/al-sabr/CppMicroServices
      GIT_TAG v2.99.0
      CMAKE_GENERATOR ${gen}
      CMAKE_GENERATOR_PLATFORM ${gen_platform}
      CMAKE_ARGS
        ${ep_common_args}
        -DUS_ENABLE_AUTOLOADING_SUPPORT:BOOL=ON
        -DUS_ENABLE_THREADING_SUPPORT:BOOL=ON
        -DUS_NO_DOCUMENTATION:BOOL=ON
        #-DUS_NO_INSTALL:STRING=1
        -DUS_BUILD_TESTING:BOOL=${BUILD_TESTING}
        -Dnlohmann_json_DIR:STRING=${nlohmann_json_DIR}
        -DAUXILIARY_INSTALL_DIR:STRING=${custom_path}
        -DAUXILIARY_INSTALL_DIR_IS_CUSTOM:BOOL=TRUE
        ${${proj}_CUSTOM_CMAKE_ARGS}
      CMAKE_CACHE_ARGS
        ${ep_common_cache_args}
        ${${proj}_CUSTOM_CMAKE_CACHE_ARGS}
      CMAKE_CACHE_DEFAULT_ARGS
        ${ep_common_cache_default_args}
        ${${proj}_CUSTOM_CMAKE_CACHE_DEFAULT_ARGS}
      DEPENDS ${proj_DEPENDENCIES}
    )

    set(CppMicroServices_DIR ${custom_path})
    mitkFunctionInstallExternalCMakeProject(${proj})

  else()
    mitkMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
  endif()
endif()
