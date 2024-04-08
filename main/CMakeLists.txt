if(NOT (${IDF_TARGET} STREQUAL "esp32c3"))
     message( FATAL_ERROR "Only esp32c3 target is supported" )
endif()

set(D_COMPILER "ldc2")
set(D_COMPILER_FLAGS "--mtriple=riscv32-unknown-none-elf" "--mattr=+m,+c,+a" "-c" "-betterC")

if(NOT CMAKE_BUILD_EARLY_EXPANSION)
     set(d_bindings_dir "${CMAKE_BINARY_DIR}/d_bindings")

     add_custom_target(
          d_bindings
          ALL
          COMMENT "Preprocess *.h files to *.i files"
          COMMAND "${CMAKE_SOURCE_DIR}/preprocess.sh" ${d_bindings_dir} ${d_bindings_dir} ${C_COMPILER} ${CMAKE_C_FLAGS}
          OUTPUT ${D_OBJ_PATH}
     )

     set(D_OBJ_PATH "${CMAKE_BINARY_DIR}/d_obj.o")

     add_custom_command(
          OUTPUT ${D_OBJ_PATH}
          COMMAND ${D_COMPILER} ${D_COMPILER_FLAGS} "-I${d_bindings_dir}" "-of=${D_OBJ_PATH}"
          "${CMAKE_SOURCE_DIR}/main/d/main.d"
     )
     add_library(d_obj STATIC ${D_OBJ_PATH})
     set_target_properties(d_obj PROPERTIES LINKER_LANGUAGE C)
     link_libraries(d_obj)
endif()

idf_component_register(SRCS
     "mcu_software.c"
INCLUDE_DIRS ".")
