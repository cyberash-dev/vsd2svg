NATIVE_BINARIES_DIR=`pwd`/build/native-install

clang++ \
  -std=c++17 \
  -I$NATIVE_BINARIES_DIR/include \
  -I$NATIVE_BINARIES_DIR/include/librevenge-0.0 \
  -I$NATIVE_BINARIES_DIR/include/libvisio-0.1 \
  -I$NATIVE_BINARIES_DIR/include/libxml2 \
  -I$NATIVE_BINARIES_DIR/include/unicode \
  -I$NATIVE_BINARIES_DIR/../boost_1_86_0 \
  -L$NATIVE_BINARIES_DIR/lib \
  -Wl,-rpath,$NATIVE_BINARIES_DIR/lib \
  -lrevenge-0.0 \
  -lrevenge-generators-0.0 \
  -lrevenge-stream-0.0 \
  -lz \
  -lxml2 \
  -licuuc \
  -licudata \
  -lvisio-0.1 \
  -o ./bin/cli \
  ./src/cli.cpp
