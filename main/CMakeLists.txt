if(NOT (${IDF_TARGET} STREQUAL "esp32c3"))
     #FIXME:
     message(FATAL_ERROR "Only esp32c3 target is supported")
endif()

idf_component_register(SRCS
     "mcu_software.c"
     INCLUDE_DIRS "."
     REQUIRES esp_driver_spi freertos
)

set(D_COMPILER "ldc2")
set(D_COMPILER_FLAGS "--mtriple=riscv32-unknown-newlib-elf" "--mattr=+m,+c,+a" --fthread-model=local-exec "-c" "-betterC")

set(D_OBJ_PATH "${CMAKE_BINARY_DIR}/d_obj.o")

add_custom_command(
     OUTPUT ${D_OBJ_PATH}
     COMMAND ${D_COMPILER} ${D_COMPILER_FLAGS} "-of=${D_OBJ_PATH}"
     "${CMAKE_SOURCE_DIR}/main/d/seg_enc.d"
     "${CMAKE_SOURCE_DIR}/main/d/displ_driver.d"
     "${CMAKE_SOURCE_DIR}/main/d/effects.d"
     "${CMAKE_SOURCE_DIR}/main/d/main.d"
)
add_library(d_obj STATIC ${D_OBJ_PATH})
set_target_properties(d_obj PROPERTIES LINKER_LANGUAGE C)
target_link_libraries(${COMPONENT_LIB} d_obj)
