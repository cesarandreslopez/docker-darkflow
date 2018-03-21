FROM tensorflow/tensorflow:latest-gpu-py3

LABEL maintainer="cal@datumcon.com"

# OpenCV dependencies
RUN apt-get update && \
        apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libpq-dev \
        curl \
        nano \
        python-pip \
        libgtk2.0-dev

# OpenCV
ENV opencv=3.3.1
WORKDIR /
RUN wget https://github.com/opencv/opencv/archive/$opencv.zip \
&& unzip $opencv.zip \
&& mkdir /opencv-$opencv/cmake_binary \
&& cd /opencv-$opencv/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DWITH_GTK=ON \
  -DWITH_GTK_2_X=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3) \
  -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /$opencv.zip 

# Cython
RUN pip install --no-cache-dir Cython

# darkflow
RUN git clone https://github.com/thtrieu/darkflow.git \
    && cd darkflow \
    && pip install .

WORKDIR /darkflow
RUN wget https://pjreddie.com/media/files/tiny-yolo-voc.weights -P ./bin
RUN wget https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/tiny-yolo-voc.cfg -P ./cfg 
RUN wget https://pjreddie.com/media/files/yolo.weights -P ./bin
RUN wget https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolo.cfg -P ./cfg 