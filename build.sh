#!/bin/bash

mkdir -p build
rm -rf build/*
cd build
touch dummy.bin
cmake .. && make
