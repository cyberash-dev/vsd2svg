WASM_BINARIES_DIR=`pwd`/build/wasm-install

em++ -std=c++17 -O3 \
  -fexceptions -fwasm-exceptions \
  -I$WASM_BINARIES_DIR/include \
  -I$WASM_BINARIES_DIR/include/librevenge-0.0 \
  -I$WASM_BINARIES_DIR/include/libvisio-0.1 \
  -I$WASM_BINARIES_DIR/include/libxml2 \
  -I$WASM_BINARIES_DIR/include/unicode \
  -I$WASM_BINARIES_DIR/../boost_1_86_0 \
  -s WASM=1 \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s MODULARIZE=1 \
  -sASSERTIONS=1 \
  --bind \
  -o ./wasm/wasm.js \
  ./src/wasm.cpp \
  -L$WASM_BINARIES_DIR/lib \
  -lrevenge-0.0 \
  -lrevenge-generators-0.0 \
  -lrevenge-stream-0.0 \
  -lz \
  -lxml2 \
  -licuuc \
  -licudata \
  -lvisio-0.1