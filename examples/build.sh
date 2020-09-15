#!/bin/bash

cp ../src/fenv.sh .

docker build -t fenv .

docker run -e REACT_APP_TEST='something' fenv
