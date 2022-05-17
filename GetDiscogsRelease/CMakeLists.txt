# CMakeLists.txt : CMake project for GetDiscogsRelease, include source and define
# project specific logic here.

cmake_minimum_required (VERSION 3.22)
find_package(fmt CONFIG REQUIRED)

# Add source to this project's executable.
add_executable (GetDiscogsRelease "GetDiscogsRelease.cpp" "GetDiscogsRelease.h" "Constants.h" "Functions.h" "Functions.cpp")
target_link_libraries(GetDiscogsRelease PRIVATE fmt::fmt)
