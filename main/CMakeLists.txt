if(NOT (${IDF_TARGET} STREQUAL "esp32c3"))
     message( FATAL_ERROR "Only esp32c3 target is supported" )
endif()

set(D_COMPILER "ldc2")
set(D_COMPILER_FLAGS "--mtriple=riscv32-unknown-none-elf" "--mattr=+m,+c,+a" "-c" "-betterC")

if(NOT CMAKE_BUILD_EARLY_EXPANSION)
     #~ list(APPEND include_dirs ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})

     add_custom_target(d_binding)
     set(d_bindings_dir "${CMAKE_BINARY_DIR}/d_bindings")

     idf_build_get_property(build_components BUILD_COMPONENTS)
     foreach(compo IN LISTS "_implicit" build_components)
          idf_component_get_property(compo_dir ${compo} COMPONENT_DIR)
          idf_component_get_property(compo_include_dirs ${compo} INCLUDE_DIRS)

          foreach(incl_dir IN LISTS compo_include_dirs)
               message(STATUS "Preprocess headers in ${compo_dir}/${incl_dir}")

               add_custom_command(
                    TARGET d_binding
                    COMMAND "${CMAKE_SOURCE_DIR}/preprocess.sh"
                    ARGS ${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS} "${compo_dir}/${incl_dir}" "${d_bindings_dir}/${compo}"
                    VERBATIM
               )
          endforeach()
     endforeach()

     set(D_OBJ_PATH "${CMAKE_BINARY_DIR}/d_obj.o")

     add_custom_command(
          OUTPUT ${D_OBJ_PATH}
          COMMAND ${D_COMPILER} ${D_COMPILER_FLAGS} "-I${d_bindings_dir}" "-of=${D_OBJ_PATH}"
          "${CMAKE_SOURCE_DIR}/main/d/main.d"
          DEPENDS d_binding
     )
     add_library(d_obj STATIC ${D_OBJ_PATH})
     set_target_properties(d_obj PROPERTIES LINKER_LANGUAGE C)
     link_libraries(d_obj)
endif()

idf_component_register(SRCS
     "mcu_software.c"
INCLUDE_DIRS ".")
