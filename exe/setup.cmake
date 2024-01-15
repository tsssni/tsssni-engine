message("processing executables ...")

file(GLOB exes RELATIVE ${TSSSNI_EXE_DIR} ${TSSSNI_EXE_DIR}/*)

foreach (exe ${exes})
  if (IS_DIRECTORY "${TSSSNI_EXE_DIR}/${exe}")
    message("build ${exe}...")
    set(exe-target tsssni.exe.${exe})

    file(GLOB files ${TSSSNI_EXE_DIR}/${exe}/*.cpp)
    if (files)
      add_executable(${exe-target} ${files})
    else()
      set(gen-file ${TSSSNI_GEN_BUILD_DIR}/exe-${exe}.cpp)
      file(GENERATE OUTPUT ${gen-file} CONTENT "")
      add_executable(${exe-target} ${gen-file})
    endif()
    set_property(TARGET ${exe-target} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${TSSSNI_BIN_BUILD_DIR})

    add_library(${exe-target}.inc INTERFACE)
    target_link_libraries(${exe-target} PUBLIC ${exe-target}.inc)
    target_include_directories(${exe-target}.inc SYSTEM INTERFACE ${TSSSNI_SRC_DIR})

    set(setup ${TSSSNI_EXE_DIR}/${exe}/setup.cmake)
    if (EXISTS ${setup})
      include(${setup})
    endif()

    get_property(link-libs TARGET ${exe-target} PROPERTY tsssni-link-libs)
    if (link-libs)
      add_library(${exe-target}.lib INTERFACE)
      target_link_libraries(${exe-target} PUBLIC ${exe-target}.lib)

      foreach (lib ${link-libs})
        target_link_libraries(${exe-target}.lib INTERFACE tsssni.lib.${lib})
        message("${exe-target} link lib ${lib}")
      endforeach()
    endif()

    get_property(link-srcs TARGET ${exe-target} PROPERTY tsssni-link-srcs)
    if (link-srcs)
      add_library(${exe-target}.src INTERFACE)
      target_link_libraries(${exe-target} PUBLIC ${exe-target}.src)

      foreach (src ${link-srcs})
        target_link_libraries(${exe-target}.src INTERFACE tsssni.src.${src})
        message("${exe-target} link src ${src}")
      endforeach()
    endif()
  endif()
endforeach()