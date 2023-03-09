# ccs8803-env_JUDI
Docker environment for seismic modeling and imaging for CCS8803 class

This repository contains a dockerfile and julia notebooks for running numerical
experiments around seismic modeling and imaging in a prebuild environment.

To build the image do

`> docker build -t ccsenv:v2.0 --platform linux/x86_64 .`

To run the image run

`> docker run --platform linux/x86_64 -p 8888:8888 -v "${PWD}":/notebooks ccsenv:v2.0`

from within the parent directory of notebooks.

