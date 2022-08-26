FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

# Python 3.7 is required for some build scripts inside CEF
RUN apt-get update && \
    apt-get install -y time curl build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev && \
    curl -fSsL --output python.tgz https://www.python.org/ftp/python/3.7.13/Python-3.7.13.tgz && \
    tar xfz python.tgz && \
    (cd Python-3.7.13 && time ./configure >/dev/null && time make -j10 -s install) && \
    rm python.tgz

# Installing basic build dependencies
RUN apt-get --assume-yes install lsb-core sudo python libgtkglext1-dev default-jdk vim
