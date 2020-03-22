# Isolate a single OpenFOAM&reg; app in a Docker image

## Introduction

This repository contains a Dockerfile which creates a Docker image containing only a single application and its dependencies. The [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) works as follows:

1. [OpenFOAM-v1912](https://hub.docker.com/r/openfoamplus/of_v1912_centos73) is used as base image (the image is a containerized build environment)
2. the source code of some [dummy application](https://github.com/AndreWeiner/dummyFoam) is copied onto the image and built
3. the application's dependencies are packed in *tar* balls
4. application + dependencies are copied to a new image

For more information, check out this blog post (to be linked).

## Usage

Copy this repository:
```
git clone https://github.com/AndreWeiner/of_app_isolation
```
Navigate to *of_app_isolation* and copy the *dummyFoam* source code:
```
cd of_app_isolation
git clone https://github.com/AndreWeiner/dummyFoam
```
Build the Docker image and tag it with the latest commit hash of *dummyFoam*:
```
docker build -t andreweiner/dummy_foam:$(git --git-dir dummyFoam/.git log -1 --format=%h) .
```
For comparison, you can also build the app without using multistage-builds.
```
docker build -t andreweiner/dummy_foam:$(git --git-dir dummyFoam/.git log -1 --format=%h) -f Dockerfile.single .
```

To test the app, navigate to a case directory and run the container:
```
cd /path/to/some/openfoam/case
docker container run -it -v"$PWD:/case" \
andreweiner/dummy_foam:f2fbf95 /bin/bash /runDummyFoam.sh
```
You can also forward the solver output to a log file:
```
docker container run -it -v"$PWD:/case" \
andreweiner/dummy_foam:f2fbf95 /bin/bash /runDummyFoam.sh > log.dummyFoam
```
The solver output should look like:
```
...
Create time


ExecutionTime = 0 s  ClockTime = 0 s

End
```
