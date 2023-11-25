# CMake Toolchain file for the RP6502 SDK.

set(CMAKE_SYSTEM_NAME Generic)
find_program(CMAKE_C_COMPILER cl65)
find_program(CMAKE_ASM_COMPILER cl65)
find_program(CMAKE_LINKER ld65)
find_program(CMAKE_AR ar65)
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> --add-source -l <OBJECT>.s -c <SOURCE>")
set(CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> a <TARGET> <LINK_FLAGS> <OBJECTS>")
set(CMAKE_C_FLAGS "--target none")
set(CMAKE_C_FLAGS_DEBUG_INIT "-O")
set(CMAKE_C_FLAGS_RELEASE_INIT "-Oirs")
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_C_ABI_COMPILED 0)
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_ASM_CREATE_STATIC_LIBRARY ${CMAKE_C_CREATE_STATIC_LIBRARY})
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} --asm-include-dir ${CMAKE_CURRENT_LIST_DIR}/include")
set(CMAKE_ASM_LINK_FLAGS ${CMAKE_C_LINK_FLAGS})
