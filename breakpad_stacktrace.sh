#!/bin/bash

MAIN_PATH=/tmp/$1_tmp
mkdir $MAIN_PATH
cp -rf $1 $MAIN_PATH
pushd $MAIN_PATH
cd $MAIN_PATH && unzip $1

SO_LIBS=`find . -name *.so`

for LIBNAME_SO in $SO_LIBS
do
	regex=".+\\/(lib.+)\.so$"
	[[ $LIBNAME_SO =~ $regex ]]
	SONAME="${BASH_REMATCH[1]}"

	SYM_SOURCE=$LIBNAME_SO.sym
	rm -rf $SYM_SOURCE
	dump_syms $LIBNAME_SO > $SYM_SOURCE

	regex="MODULE [A-Za-z]+ arm ([A-Z0-9]+)"
	line=$(head -n 1 $SYM_SOURCE)
	[[ $line =~ $regex ]]
	ver="${BASH_REMATCH[1]}"
	echo $ver

	SYM_DIR=$MAIN_PATH/symbols/$SONAME.so/$ver/
	rm -rf $SYM_DIR
	mkdir -pv $SYM_DIR
	cp -rf $SYM_SOURCE $SYM_DIR
done

minidump_stackwalk $2 $MAIN_PATH/symbols > stacktrace.txt
cat stacktrace.txt

popd;