if(NOT (${IDF_TARGET} STREQUAL "esp32c3"))
     message( FATAL_ERROR "Only esp32c3 target is supported" )
endif()

set(D_COMPILER "ldc2")
set(D_COMPILER_FLAGS "--mtriple=riscv32-unknown-none-elf" "--mattr=+m,+c,+a" "-c" "-betterC")

if(NOT CMAKE_BUILD_EARLY_EXPANSION)
     set(d_bindings_dir "${CMAKE_BINARY_DIR}")

     add_custom_target(d_binding)
     #~ add_library(d_binding OBJECT "${CMAKE_SOURCE_DIR}/mcu_software.c")
     #~ target_link_libraries(d_binding INTERFACE "${CMAKE_BINARY_DIR}/esp-idf/main/CMakeFiles/__idf_main.dir/mcu_software.c.obj")

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
     INCLUDE_DIRS "."
     REQUIRES "driver"
)

# Also before first configuring ensure to invoke:
# $ idf_tools.py install esp-clang
idf_build_get_property(idf_toolchain IDF_TOOLCHAIN)
if(NOT (${idf_toolchain} STREQUAL "clang"))
     message(FATAL_ERROR "Only clang toolchain is supported")
endif()
