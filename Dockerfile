FROM openfoamplus/of_v1906_centos73 AS builder
COPY dummyFoam /opt/OpenFOAM/OpenFOAM-v1906/applications/solvers/dummyFoam
WORKDIR /opt/OpenFOAM/OpenFOAM-v1906/applications/solvers/dummyFoam
RUN source /opt/OpenFOAM/OpenFOAM-v1906/etc/bashrc && \
    wmake && \
    ldd $(which dummyFoam) | cut -d" " -f3 | xargs tar --dereference -cf libs.tar && \
    tar --dereference -rvf libs.tar /lib64/ld-linux-x86-64.so.2 && \
    tar -cf etc.tar /opt/OpenFOAM/OpenFOAM-v1906/etc

FROM alpine:latest
RUN apk add --no-cache bash tar
COPY --from=builder /opt/OpenFOAM/OpenFOAM-v1906/applications/solvers/dummyFoam/libs.tar \
                    /root/OpenFOAM/-v1906/platforms/linux64GccDPInt32Opt/bin/dummyFoam \
                    /opt/OpenFOAM/OpenFOAM-v1906/applications/solvers/dummyFoam/etc.tar \
                    /
RUN tar -xf libs.tar && \
    tar -xf etc.tar && \
    rm *.tar && \
    sed -i '/projectDir=\"\$HOME\/OpenFOAM\/OpenFOAM-\$WM_PROJECT_VERSION\"/c\projectDir=\"\/opt\/OpenFOAM\/OpenFOAM-\$WM_PROJECT_VERSION\"' /opt/OpenFOAM/OpenFOAM-v1906/etc/bashrc && \
    mkdir case && \
    echo "source /opt/OpenFOAM/OpenFOAM-v1906/etc/bashrc &> /dev/null; /dummyFoam -case /case" > runDummyFoam.sh
ENV LD_LIBRARY_PATH=/opt/OpenFOAM/OpenFOAM-v1906/platforms/linux64GccDPInt32Opt/lib:\
lib:lib64:/opt/OpenFOAM/ThirdParty-v1906/platforms/linux64Gcc/openmpi-1.10.4/lib64/lib:\
/opt/OpenFOAM/OpenFOAM-v1906/platforms/linux64GccDPInt32Opt/lib/openmpi-1.10.4:\
/opt/OpenFOAM/ThirdParty-v1906/platforms/linux64Gcc/openmpi-1.10.4/lib64
