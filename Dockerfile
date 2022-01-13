# Use Ubuntu 18.04 (will be supported until April 2023)
FROM ubuntu:bionic

# Add openMVG binaries to path
ENV PATH $PATH:/openMVG_Build/install/bin

# Get dependencies
RUN apt-get update && apt-get install -y \
  cmake \
  build-essential \
  graphviz \
  vim \
  git \
  mercurial \
  coinor-libclp-dev \
  libceres-dev \
  libflann-dev \
  liblemon-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libglu1-mesa-dev \
  python-minimal; \
  apt-get autoclean && apt-get clean

# Clone the openvMVG repo
RUN git clone https://github.com/BorodinDK/openMVG
RUN cd /openMVG && git submodule update --init --recursive

RUN mkdir /openMVG_Build; \
  cd /openMVG_Build; \
  cmake -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX="/opt/openMVG_Build/install" \
    -DOpenMVG_BUILD_TESTS=ON \
    -DOpenMVG_BUILD_EXAMPLES=OFF \
    -DFLANN_INCLUDE_DIR_HINTS=/usr/include/flann \
    -DLEMON_INCLUDE_DIR_HINTS=/usr/include/lemon \
    -DCOINUTILS_INCLUDE_DIR_HINTS=/usr/include \
    -DCLP_INCLUDE_DIR_HINTS=/usr/include \
    -DOSI_INCLUDE_DIR_HINTS=/usr/include \
    ../openMVG/src; \
    make -j 4;

RUN cd /openMVG_Build && make test && make install;


# openMVS
# Eigen (Known issues with eigen 3.3.7 as of 12/10/2019, so using this tested branch/commit instead)
RUN git clone https://gitlab.com/libeigen/eigen --branch 3.2; \
  mkdir eigen_build && cd eigen_build; \
  cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="/usr/local/include/eigen32" . ../eigen; \
  make && make install; \
  cd .. && rm -rf eigen_build

# VCGLib
RUN git clone https://github.com/cdcseacave/VCG.git vcglib

# Build latest openMVS
RUN git clone https://github.com/cdcseacave/openMVS.git --branch develop; \
  mkdir openMVS_build && cd openMVS_build; \
  cmake . ../openMVS -DCMAKE_BUILD_TYPE=Release \
    -DVCG_ROOT=/vcglib \
    -DEIGEN3_INCLUDE_DIR=/usr/local/include/eigen32/include/eigen3 \
    -DCMAKE_INSTALL_PREFIX="/opt"; \
  make -j4 && make install; \
  cp ../openMVS/MvgMvsPipeline.py /opt/bin/; \
  cd .. && rm -rf openMVS_build

# Install cmvs-pmvs
RUN git clone https://github.com/pmoulon/CMVS-PMVS cmvs-pmvs; \
  mkdir cmvs_pmvs_build && cd cmvs_pmvs_build; \
  cmake ../cmvs-pmvs/program -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt; \
  make -j4 && make install; \
  cd .. && rm -rf cmvs_pmvs_build

# Add binaries to path
ENV PATH $PATH:/opt/bin:/opt/bin/OpenMVS
