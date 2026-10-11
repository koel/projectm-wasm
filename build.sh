#!/usr/bin/env bash
# Builds koel_projectm.js and koel_projectm.wasm into dist/. Needs Docker.
set -euo pipefail

PROJECTM_VERSION="${PROJECTM_VERSION:-v4.1.8}"
EMSDK_IMAGE="emscripten/emsdk:3.1.53"

cd "$(dirname "$0")"
mkdir -p build dist

if [ ! -d build/projectm ]; then
  git clone --depth 1 --branch "$PROJECTM_VERSION" --recurse-submodules \
    https://github.com/projectM-visualizer/projectm.git build/projectm
fi

docker run --rm --platform linux/amd64 -v "$PWD":/src -w /src "$EMSDK_IMAGE" bash -lc '
  set -euo pipefail

  emcmake cmake -G "Unix Makefiles" -S build/projectm -B build/projectm-build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/src/build/install \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=NO \
    -DENABLE_PLAYLIST=NO
  emmake cmake --build build/projectm-build --parallel
  emmake cmake --install build/projectm-build

  em++ -O3 src/koel_projectm.cpp \
    -Ibuild/install/include \
    build/projectm-build/src/libprojectM/libprojectM-4.a \
    build/projectm-build/vendor/projectm-eval/projectm-eval/libprojectM_eval.a \
    -o dist/koel_projectm.js \
    -sMIN_WEBGL_VERSION=2 -sMAX_WEBGL_VERSION=2 -sFULL_ES3=1 \
    -sALLOW_MEMORY_GROWTH=1 -sMODULARIZE=1 -sEXPORT_NAME=KoelProjectM \
    -sEXPORTED_RUNTIME_METHODS=cwrap \
    -sEXPORTED_FUNCTIONS=_malloc,_free,_koel_projectm_init,_koel_projectm_load_preset,_koel_projectm_add_pcm,_koel_projectm_render,_koel_projectm_resize,_koel_projectm_destroy
'

ls -l dist
