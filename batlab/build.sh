#!/bin/bash

# Prequisite: virtualenv-* directory expanded from https://pypi.python.org/packages/source/v/virtualenv/virtualenv-X.Y[.Z].tar.gz
# and khmer-* directory expanded from https://github.com/ged-lab/khmer/archive/vX.Y.Z.tar.gz

startDir = $PWD

function archive {
	signal=$?
	cd ${startDir}
	mkdir -p env khmer	
	tar czf results.tar.gz env khmer
	exit ${signal}
}

trap archive ERR 

set -e
set -x

cd virtualenv-*
python virtualenv.py ../env
cd ..

source env/bin/activate
pip install --upgrade nose coverage pylint gcovr wheel

ln -s khmer-*/ khmer

pushd khmer
if type gcov && [[ "$OSTYPE" != "darwin"* ]]
then
	export CFLAGS="-pg -fprofile-arcs -ftest-coverage"
        post='--debug --inplace --libraries gcov'
else
        echo "gcov was not found, skipping coverage check"
fi

./setup.py build_ext ${post}
./setup.py develop
coverage run --source=scripts,khmer -m nose --with-xunit --attr=\!known_failing
coverage xml
./setup.py bdist_wheel
make doc
pylint -f parseable khmer/*.py scripts/*.py tests khmer | tee ../pylint.out
gcovr --xml > coverage-gcovr.xml || /bin/true
popd

archive

