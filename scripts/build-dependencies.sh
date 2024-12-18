set -e

source ./scripts/get-binaries-arch.sh
source ./scripts/git-utils.sh

BUILD_DIR="`pwd`/build"
WASM_INSTALL_DIR="$BUILD_DIR/wasm-install"
NATIVE_INSTALL_DIR="$BUILD_DIR/native-install"
BOOST_URL=https://archives.boost.io/release/1.86.0/source/boost_1_86_0.tar.gz
BOOST_PATH=$BUILD_DIR/`basename $BOOST_URL .tar.gz`
SRC_INCLUDE=`pwd`/src/include

function init () {
  mkdir $BUILD_DIR 2>/dev/null ||:
}

function prepare_boost () {
  local boost_archive_name=`basename $BOOST_URL`
  local boost_archive_path=$BUILD_DIR/$boost_archive_name

  if [ ! -f $boost_archive_path ]; then
    wget -P $BUILD_DIR $BOOST_URL
  fi

  if [ ! -d $BOOST_PATH ]; then
    mkdir $BOOST_PATH
    tar -xf $boost_archive_path -C $BUILD_DIR
  fi
}

function is_lib_installed {
  local libname=$1
  local wasm_pc_path=$2
  local native_pc_path=$2

  if [ ! -z "$3" ]; then
    native_pc_path=$3
  fi

  if [[ ${FORCE_REBUILD[@]} =~ "$libname" ]]; then
    IS_LIB_INSTALLED=0
    return 0
  fi

  if ([[ $NATIVE -ne 1 ]] && [ -f $WASM_INSTALL_DIR/$wasm_pc_path ]) || ([[ $NATIVE -eq 1 ]] && [ -f $NATIVE_INSTALL_DIR/$native_pc_path ]); then
    IS_LIB_INSTALLED=1
  else
    IS_LIB_INSTALLED=0
  fi
}

function build_zlib () {
  is_lib_installed "zlib" "share/pkgconfig/zlib.pc" "lib/pkgconfig/zlib.pc"
  if [ $IS_LIB_INSTALLED -eq 1 ]; then
    return 0
  fi

  local lib_path=$BUILD_DIR/zlib
  local current_path=`pwd`

  git_clone_or_update https://github.com/madler/zlib.git master $lib_path
  cd $lib_path

  make distclean 2>/dev/null ||:
  if [ $NATIVE -eq 1 ]; then
    ./configure --prefix=$NATIVE_INSTALL_DIR
    make
    make install
  else
    emcmake cmake . -DCMAKE_INSTALL_PREFIX=$WASM_INSTALL_DIR -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-fexceptions -fwasm-exceptions"
    emmake make
    emmake make install
  fi

  cd $current_path
}

function build_librevenge () {
  is_lib_installed "librevenge" "lib/pkgconfig/librevenge-0.0.pc"
  if [ $IS_LIB_INSTALLED -eq 1 ]; then
    return 0
  fi

  local lib_path="$BUILD_DIR/librevenge"
  local current_path=`pwd`

  git_clone_or_update https://github.com/Distrotech/librevenge.git master $lib_path
  cd $lib_path

  make distclean 2>/dev/null ||:
  ./autogen.sh
  if [ $NATIVE -eq 1 ]; then
    LDFLAGS="-L$NATIVE_INSTALL_DIR/lib" \
    CXXFLAGS="-std=c++17 -isystem $BOOST_PATH -I$NATIVE_INSTALL_DIR/include -include $SRC_INCLUDE/override_ostringstream_operator.h" \
    ./configure --prefix=$NATIVE_INSTALL_DIR
    make
    make install
  else
    LDFLAGS="-L$WASM_INSTALL_DIR/lib" \
    CXXFLAGS="-std=c++17 -fexceptions -fwasm-exceptions -isystem $BOOST_PATH -I$WASM_INSTALL_DIR/include -include $SRC_INCLUDE/override_ostringstream_operator.h" \
    emconfigure ./configure --prefix=$WASM_INSTALL_DIR --enable-tests=0 --disable-shared
    emmake make
    emmake make install
  fi

  cd $current_path
}

function build_xml2 () {
  is_lib_installed "libxml2" "lib/pkgconfig/libxml-2.0.pc"
  if [ $IS_LIB_INSTALLED -eq 1 ]; then
    return 0
  fi

  local lib_path="$BUILD_DIR/libxml2"
  local current_path=`pwd`

  git_clone_or_update https://github.com/GNOME/libxml2.git master $lib_path
  cd $lib_path

  make distclean 2>/dev/null ||:
  ./autogen.sh
  if [ $NATIVE -eq 1 ]; then
    ./configure --prefix=$NATIVE_INSTALL_DIR --without-python
    make
    make install
  else
    CXXFLAGS="-std=c++17 -fexceptions -fwasm-exceptions"
    emconfigure ./configure --prefix=$WASM_INSTALL_DIR --without-python
    emmake make
    emmake make install
  fi


  cd $current_path
}

function build_icu () {
  is_lib_installed "icu" "lib/pkgconfig/icu-uc.pc"
  if [ $IS_LIB_INSTALLED -eq 1 ]; then
    return 0
  fi

  local lib_path="$BUILD_DIR/icu"
  local current_path=`pwd`

  git_clone_or_update https://github.com/unicode-org/icu.git main $lib_path
  cd $lib_path
  cd ./icu4c/source

  rm -rf ./build-native 2>/dev/null ||:
  mkdir ./build-native 2>/dev/null ||:
  cd ./build-native
  local native_build=`pwd`

  ../configure --prefix=$NATIVE_INSTALL_DIR
  make
  make install

  if [[ $NATIVE -ne 1 ]]; then
    cd ..

    emconfigure ./configure \
        --prefix=$WASM_INSTALL_DIR \
        --with-cross-build=$native_build \
        --disable-tests \
        --disable-samples \
        --disable-tools \
        --disable-extras \
        --disable-shared \
        --with-data-packaging=archive \
        --enable-static

    emmake make
    emmake make install
  fi

  cd $current_path
}

function build_libvisio () {
  is_lib_installed "libvisio" "lib/pkgconfig/libvisio-0.1.pc"
  if [ $IS_LIB_INSTALLED -eq 1 ]; then
    return 0
  fi

  local lib_path="$BUILD_DIR/libvisio"
  local current_path=`pwd`

  git_clone_or_update https://github.com/LibreOffice/libvisio.git master $lib_path
  cd $lib_path

  make distclean 2>/dev/null ||:
  ./autogen.sh
  if [ $NATIVE -eq 1 ]; then
    CXXFLAGS="-std=c++17 -isystem $BOOST_PATH" \
    ./configure --prefix=$NATIVE_INSTALL_DIR PKG_CONFIG_PATH="$NATIVE_INSTALL_DIR/lib/pkgconfig"
    make
    make install
  else
    CXXFLAGS="-std=c++17 -fexceptions -fwasm-exceptions -isystem $BOOST_PATH" \
    emconfigure ./configure \
      --prefix=$WASM_INSTALL_DIR \
      --disable-shared \
      --enable-tests=0 \
      PKG_CONFIG_PATH="$WASM_INSTALL_DIR/lib/pkgconfig:$WASM_INSTALL_DIR/share/pkgconfig"

    emmake make
    emmake make install
  fi

  cd $current_path
}

usage() { echo "Usage: $0 [-f lib1,lib2] [-n]" 1>&2; exit 1; }

while getopts ":f:n" o; do
    case "${o}" in
        f)
            IFS=',' read -r -a FORCE_REBUILD <<< "$OPTARG"
            ;;
        n)
            NATIVE=1
            ;;
        *)
            usage
            ;;
    esac
done

init
prepare_boost
build_zlib
build_librevenge
build_xml2
build_icu
build_libvisio