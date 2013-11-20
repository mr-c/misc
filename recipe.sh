#!/bin/bash

#requires subversion, autoconf (for autoreconf), libtool, gcc

svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_33/final/ llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_33/final/ clang
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
cd ../..
mkdir -p llvm_clang_build
cd llvm_clang_build
../llvm/configure --config-cache --enable-cxx11 --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols --enable-optimized --prefix=${HOME}
make install

cd ..
git clone git://github.com/xiw/stack stack-git
cd stack-git
autoreconf -fvi
mkdir -p build
cd build
CPPFLAGS="-I${HOME}/include" LDFLAGS="-L${HOME}/lib" ../configure --config-cache --prefix=${HOME}

# to update clang+llvm; run `make update` in the llvm directory if the trunk was checked out or svn switch to a different tag
# to update stack; run `git pull` in the stack-git directory
