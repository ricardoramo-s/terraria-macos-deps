#! /bin/sh

WORK=./terraria-deps
INSTALL_ROOT="$WORK/install"
CPPFLAGS="-I$INSTALL_ROOT/include"
LDFLAGS="-L$INSTALL_ROOT/lib"
PKG_CONFIG_PATH="$INSTALL_ROOT/lib/pkgconfig"
PATH="$INSTALL_ROOT/bin:$PATH"

mkdir -p "$WORK" && cd "$WORK"

FORMULAE=(
  jpeg
  libogg
  openal-soft
  libpng
  sdl2_image
  theora
  libvorbis
)

DESTDIR="$(pwd)/install/lib"
mkdir -p "$DESTDIR"
chown -R "$(whoami)" "$WORK/install"

arch -x86_64 /usr/local/bin/brew install "${FORMULAE[@]}"

for f in "${FORMULAE[@]}"; do
  CELLAR_PATH="$(arch -x86_64 /usr/local/bin/brew --cellar "$f")"
  VER_DIR="$(ls -1d "$CELLAR_PATH"/*/ | tail -1)"
  LIBDIR="$VER_DIR/lib"

  echo "→ Copying from $LIBDIR:"
  ls "$LIBDIR"/*.dylib

  cp "$LIBDIR"/*.dylib "$DESTDIR"/
done

git clone https://github.com/libsdl-org/SDL.git
cd SDL
git checkout release-2.32.8
mkdir build && cd build

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES="x86_64" \
  -DSDL_VULKAN=ON \
  -DCMAKE_INSTALL_PREFIX="$WORK/install" \
  -DCMAKE_PREFIX_PATH="$INSTALL_ROOT" \
  -DCMAKE_INCLUDE_PATH="$INSTALL_ROOT/include" \
  -DCMAKE_LIBRARY_PATH="$INSTALL_ROOT/lib"

make -j$(sysctl -n hw.ncpu)
make install

cd "$WORK"

git clone https://github.com/FNA-XNA/FAudio.git
cd FAudio
git checkout 25.07
mkdir build && cd build

cmake .. \
  -DBUILD_SDL3=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES="x86_64" \
  -DCMAKE_INSTALL_PREFIX="$WORK/install" \
  -DCMAKE_PREFIX_PATH="$INSTALL_ROOT" \
  -DCMAKE_INCLUDE_PATH="$INSTALL_ROOT/include" \
  -DCMAKE_LIBRARY_PATH="$INSTALL_ROOT/lib"

make -j$(sysctl -n hw.ncpu)
make install

cd "$WORK"

git clone https://github.com/FNA-XNA/FNA3D.git
cd FNA3D
git checkout 24.12
git submodule update --init --recursive

cd MojoShader
mkdir build && cd build

cmake .. \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES="x86_64" \
  -DCMAKE_INSTALL_PREFIX="$WORK/install" \
  -DCMAKE_PREFIX_PATH="$INSTALL_ROOT" \
  -DCMAKE_INCLUDE_PATH="$INSTALL_ROOT/include" \
  -DCMAKE_LIBRARY_PATH="$INSTALL_ROOT/lib"

make -j$(sysctl -n hw.ncpu)
cp libmojoshader.dylib "$WORK/install/lib"

cd ../..

mkdir build && cd build

cmake .. \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DBUILD_SDL3=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES="x86_64" \
  -DCMAKE_INSTALL_PREFIX="$WORK/install" \
  -DCMAKE_PREFIX_PATH="$INSTALL_ROOT" \
  -DCMAKE_INCLUDE_PATH="$INSTALL_ROOT/include" \
  -DCMAKE_LIBRARY_PATH="$INSTALL_ROOT/lib"

make -j$(sysctl -n hw.ncpu)
cp libFNA3D.0.dylib "$WORK/install/lib"

cd "$WORK"

git clone https://github.com/FNA-XNA/Theorafile.git
cd Theorafile
arch -x86_64 make -j 8
cp libtheorafile.dylib "$WORK/install/lib"

cd "$WORK"

mkdir -p "$WORK/lib"
cp "$WORK/install/lib"/{libFAudio.0.dylib,libFNA3D.0.dylib,libjpeg.9.dylib,libmojoshader.dylib,libogg.0.dylib,libopenal.1.dylib,libpng16.16.dylib,libSDL2_image-2.0.0.dylib,libSDL2-2.0.0.dylib,libtheoradec.1.dylib,libtheorafile.dylib,libvorbis.0.dylib,libvorbisfile.3.dylib} "$WORK/lib"

echo "All done! Libraries are in $WORK/lib"
