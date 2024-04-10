if(NOT (${IDF_TARGET} STREQUAL "esp32c3"))
     message( FATAL_ERROR "Only esp32c3 target is supported" )
endif()

set(D_COMPILER "ldc2")
set(D_COMPILER_FLAGS "--mtriple=riscv32-unknown-none-elf" "--mattr=+m,+c,+a" "-c" "-betterC")

if(NOT CMAKE_BUILD_EARLY_EXPANSION)
     add_custom_target(d_binding)
     set(d_bindings_dir "${CMAKE_BINARY_DIR}/d_bindings")

     idf_build_get_property(build_components BUILD_COMPONENTS)
     list(PREPEND build_components "?/implicit")
     foreach(compo IN LISTS build_components)
          if(${compo} STREQUAL "?/implicit")
               set(compo_dir "")
               set(compo_include_dirs ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
          else()
               idf_component_get_property(compo_dir ${compo} COMPONENT_DIR)
               idf_component_get_property(compo_include_dirs ${compo} INCLUDE_DIRS)
          endif()

          foreach(incl_dir_rel IN LISTS compo_include_dirs)
               set(incl_dir "${compo_dir}/${incl_dir_rel}")
               message(STATUS "Preprocess headers in ${incl_dir}")

               list(APPEND include_dirs_flags "-I${incl_dir}")

               # Separate variable to be able to escape semicolon
               set(args
                    --type f --glob *.h --base-directory ${incl_dir}
                    --exec mkdir -p "${d_bindings_dir}/\{//\}" "\\\;"
                    --exec ${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS} ${include_dirs_flags}
                    -E -o "${d_bindings_dir}/\{//\}/\{/.\}.i" "{}" "\\\;"
               )

               add_custom_command(
                    TARGET d_binding
                    COMMAND fdfind
                    ARGS ${args}
                    COMMAND_EXPAND_LISTS
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
