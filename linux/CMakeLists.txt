cmake_minimum_required(VERSION 3.15)

project(katya_ai_rechain_mesh)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Add Flutter binaries directly.
add_subdirectory("${FLUTTER_MANAGED_DIR}/ephemeral/.plugin_symlinks/window_size/linux"
                 EXCLUDE_FROM_ALL)

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Generated plugin build tree.
add_subdirectory("${FLUTTER_MANAGED_DIR}/ephemeral/.plugin_symlinks/linux/build/linux/plugins"
                 EXCLUDE_FROM_ALL)

# Plugin targets
set(PLUGIN_BUNDLED_LIBRARIES
  $<TARGET_FILE:flutter_secure_storage_linux>
  $<TARGET_FILE:window_size>
  PARENT_SCOPE
)
