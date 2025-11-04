cmake_minimum_required(VERSION 3.15)
project(KatyaMeshCpp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Options
option(BUILD_TESTS "Build tests" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# Find dependencies
find_package(OpenSSL REQUIRED)
find_package(Boost REQUIRED COMPONENTS system thread)

# Include directories
include_directories(include)
include_directories(src)

# Sources
set(BROKER_SOURCES
    src/broker/broker.cpp
    src/broker/message_queue.cpp
    src/broker/peer_manager.cpp
)

set(CRYPTO_SOURCES
    src/crypto/handshake.cpp
    src/crypto/aes_gcm.cpp
    src/crypto/key_derivation.cpp
)

set(DISCOVERY_SOURCES
    src/discovery/udp_discovery.cpp
    src/discovery/peer_discovery.cpp
)

set(PROTOCOL_SOURCES
    src/protocol/message.cpp
    src/protocol/voting.cpp
)

set(UTILS_SOURCES
    src/utils/logger.cpp
    src/utils/config.cpp
)

# Libraries
add_library(mesh_crypto STATIC ${CRYPTO_SOURCES})
target_link_libraries(mesh_crypto PRIVATE OpenSSL::SSL OpenSSL::Crypto)

add_library(mesh_protocol STATIC ${PROTOCOL_SOURCES})

add_library(mesh_discovery STATIC ${DISCOVERY_SOURCES})
target_link_libraries(mesh_discovery PRIVATE Boost::system Boost::thread)

add_library(mesh_utils STATIC ${UTILS_SOURCES})

# Broker executable
add_executable(mesh-broker-cpp
    src/main/broker_main.cpp
    ${BROKER_SOURCES}
)

target_link_libraries(mesh-broker-cpp
    PRIVATE
    mesh_crypto
    mesh_protocol
    mesh_discovery
    mesh_utils
    OpenSSL::SSL
    OpenSSL::Crypto
    Boost::system
    Boost::thread
)

# CLI executable
add_executable(meshctl-cpp
    src/main/cli_main.cpp
    src/broker/broker.cpp
)

target_link_libraries(meshctl-cpp
    PRIVATE
    mesh_crypto
    mesh_protocol
    mesh_discovery
    mesh_utils
    OpenSSL::SSL
    OpenSSL::Crypto
    Boost::system
    Boost::thread
)

# Install
install(TARGETS mesh-broker-cpp meshctl-cpp
    RUNTIME DESTINATION bin
)

# Tests
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

