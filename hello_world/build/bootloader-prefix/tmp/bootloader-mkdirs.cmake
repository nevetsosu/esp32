# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/home/nevets/esp/v5.4.1/esp-idf/components/bootloader/subproject"
  "/home/nevets/code/esp32/hello_world/build/bootloader"
  "/home/nevets/code/esp32/hello_world/build/bootloader-prefix"
  "/home/nevets/code/esp32/hello_world/build/bootloader-prefix/tmp"
  "/home/nevets/code/esp32/hello_world/build/bootloader-prefix/src/bootloader-stamp"
  "/home/nevets/code/esp32/hello_world/build/bootloader-prefix/src"
  "/home/nevets/code/esp32/hello_world/build/bootloader-prefix/src/bootloader-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/nevets/code/esp32/hello_world/build/bootloader-prefix/src/bootloader-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/nevets/code/esp32/hello_world/build/bootloader-prefix/src/bootloader-stamp${cfgdir}") # cfgdir has leading slash
endif()
