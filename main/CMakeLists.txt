if(NOT (${IDF_TARGET} STREQUAL "esp32c3"))
     message( FATAL_ERROR "Only esp32c3 target is supported" )
endif()

set(D_COMPILER "ldc2")
set(D_COMPILER_FLAGS "--mtriple=riscv32-unknown-none-elf" "--mattr=+m,+c,+a" "-c" "-betterC")

if(NOT CMAKE_BUILD_EARLY_EXPANSION)
     #~ add_library(c_stub "${CMAKE_SOURCE_DIR}/main/unused_stub.c")

     set(d_bindings_dir "${CMAKE_BINARY_DIR}/esp-idf")

     # Separate args variable to be able to escape semicolon
     set(args
          --type f --glob *.i --base-directory "${d_bindings_dir}"
          --exec cp {} "{.}cc" "\\\;"
          --exec rename.ul .ccc .i "{.}cc" "\\\;"
     )

     add_custom_target(d_binding)
     add_custom_command(
          TARGET d_binding
          DEPENDS c_stub
          #~ DEPENDS "unused_stub.c"
          COMMAND fdfind
          ARGS ${args}
          COMMAND_EXPAND_LISTS
          VERBATIM
     )

     set(D_OBJ_PATH "${CMAKE_BINARY_DIR}/d_obj.o")

     add_custom_command(
          OUTPUT ${D_OBJ_PATH}
          COMMAND ${D_COMPILER} ${D_COMPILER_FLAGS} "-I${CMAKE_SOURCE_DIR}/i_files" "-of=${D_OBJ_PATH}"
          "${CMAKE_SOURCE_DIR}/main/d/main.d"
          #~ DEPENDS d_binding
     )
     add_library(d_obj STATIC ${D_OBJ_PATH})
     set_target_properties(d_obj PROPERTIES LINKER_LANGUAGE C)
     link_libraries(d_obj)
endif()

idf_component_register(SRCS
     "mcu_software.c" "unused_stub.c"
     INCLUDE_DIRS "."
     REQUIRES "driver"
)
