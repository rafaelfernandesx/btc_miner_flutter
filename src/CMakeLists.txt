# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(btc_miner_library VERSION 0.0.1 LANGUAGES C)

add_library(btc_miner SHARED
  "btc_miner.cpp"
)

set_target_properties(btc_miner PROPERTIES
  PUBLIC_HEADER btc_miner.h
  OUTPUT_NAME "btc_miner"
)

target_compile_definitions(btc_miner PUBLIC DART_SHARED_LIB)
