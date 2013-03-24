#!/bin/sh

PROJECT_DIR=$(pwd)

# sanity check: executed in the root folder?
if [ ! -f src/store.js ]; then
  echo "store/update.sh must be executed in the root dir of the repository."
fi

##########################
# command line options
#

EXTERNALS=/tmp/substance_store
VERBOSE=0
BUILD=0
BUILD_JSC_EXTENSION=0
BUILD_V8_EXTENSION=0

function readopts {
  while ((OPTIND<=$#)); do
    if getopts ":d:e:hb" opt; then
      case $opt in
        d) EXTERNALS=$OPTARG;;
        e)  if [ "$OPTARG"=="jsc" ]; then
              BUILD_JSC_EXTENSION=1
            elif [ "$OPTARG"=="v8" ]; then
              BUILD_V8_EXTENSION=1
            fi;;
    b) BUILD=1;;
    h) echo "Usage: update.sh [-d <directory>] [-b]" $$ exit;;
        *) ;;
      esac
    else
        let OPTIND++
    fi
  done
}

OPTIND=1
readopts "$@"

echo "Updating store..."
echo "Storing into directory: $EXTERNALS"
echo "Building: $BUILD"
if [ $BUILD==1 ]; then
  echo "JSC: $BUILD_JSC_EXTENSION"
  echo "V8: $BUILD_V8_EXTENSION"
fi

if [ ! -d $EXTERNALS ]; then
  mkdir $EXTERNALS
fi

######################
# boost
cd $EXTERNALS

boost_modules="config detail exception smart_ptr algorithm iterator mpl range type_traits preprocessor utility concept function bind format optional"

if [ ! -d boost ]; then
  svn co --depth files http://svn.boost.org/svn/boost/tags/release/Boost_1_50_0/boost
  cd boost
  svn update $boost_modules
fi

######################
# swig

cd $EXTERNALS

if [ ! -d swig ]; then
  git clone https://github.com/oliver----/swig-v8.git swig
fi

cd swig

if [ ! -f configure ]; then
  ./autogen.sh
fi

if [ ! -f Makefile ]; then
  ./configure
fi

# always pull

git pull origin devel
make

######################
# jsobjects
cd $EXTERNALS

if [ ! -d jsobjects ]; then
  git clone https://github.com/oliver----/jsobjects.git
fi

cd jsobjects
./update.sh -d $EXTERNALS -v

######################
# hiredis
cd $EXTERNALS

if [ ! -d hiredis ]; then
  git clone https://github.com/redis/hiredis.git
fi

cd hiredis
make static

######################
# Build the store

if [ $BUILD == 1 ]; then
  echo "Building the store..."
  cd $PROJECT_DIR

  git pull

  if [ ! -d build ]; then
    mkdir build
  fi
  cd build
  #if [ ! -f CMakeCache.txt ]; then
    CMAKE_ARGS="-DEXTERNALS_DIR=$EXTERNALS -DSWIG_COMMAND=$EXTERNALS/swig/preinst-swig -DCMAKE_PREFIX_PATH=$EXTERNALS"
    if [  $BUILD_V8_EXTENSION==1 ]; then
      CMAKE_ARGS="$CMAKE_ARGS -DENABLE_V8=ON"
    fi
    if [  $BUILD_JSC_EXTENSION==1 ]; then
      CMAKE_ARGS="$CMAKE_ARGS -DENABLE_JSC=ON"
    fi
    cmake  $CMAKE_ARGS ..
  #fi
  make
fi