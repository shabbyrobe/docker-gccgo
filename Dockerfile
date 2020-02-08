# Build stage
# ===========

FROM debian:buster-slim AS builder
LABEL gccgo_cleanup="true"

# g++ is required to silence this: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63509
RUN apt-get update \
 && apt-get install -y gpg curl xz-utils \
 && apt-get install -y \
        g++ \
        gcc \
        gcc-multilib \
        libgcc1 \
        libgmp-dev \
        libmpfr-dev \
        make \
 && rm -rf /var/lib/apt/lists/*

# GCC will be signed by one of the following GnuPG keys:
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys \
    B215C1633BCA0477615F1B35A5B3A004745C015A \
    B3C42148A44E6983B3E4CC0793FA9B1AB75C61B8 \
    90AA470469D3965A87A5DCB494D03953902C9419 \
    80F98B2E0DAB6C8281BDF541A7C8C3B2F71EDF1C \
    7F74F97C103468EE5D750B583AB00996FC26A641 \
    33C235A34C46AA3FFB293709A328C3A2C3C45C06

# MPC:
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys \
    AD17A21EF8AED8F1CC02DBD9F7D5C9BF765C61E3

RUN curl -sO https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
RUN curl -sO https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz.sig

ARG GCC_VERSION=9.2.0
RUN curl -sO https://mirrors.kernel.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz
RUN curl -sO https://mirrors.kernel.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz.sig

# These will still report a warning that I haven't worked out how to silence yet:
RUN gpg --verify gcc-$GCC_VERSION.tar.xz.sig gcc-$GCC_VERSION.tar.xz
RUN gpg --verify mpc-1.1.0.tar.gz.sig mpc-1.1.0.tar.gz

RUN tar -xf gcc-$GCC_VERSION.tar.xz
RUN cd gcc-$GCC_VERSION && tar -xf /mpc-1.1.0.tar.gz --transform 's/^mpc-1.1.0/mpc/'

RUN mkdir /build
WORKDIR /build
RUN /gcc-$GCC_VERSION/configure --prefix=/gcc --enable-languages=c,c++,go

RUN echo "$GCCGO_PARALLEL" && make -j "$( nproc )" && make install


# Install stage
# =============

FROM debian:buster-slim
COPY --from=builder /gcc /gcc

# git, hg and svn are required by the 'go' tool to download modules
RUN apt-get update \
 && apt-get install -y \
        binutils \
        git \
        libc6-dev \
        libmpfr-dev \
        mercurial \
        subversion \
        vim \
 && rm -rf /var/lib/apt/lists/*

RUN echo 'PATH="$PATH:/gcc/bin"' > /etc/profile
RUN echo "/gcc/lib64" > /etc/ld.so.conf.d/gcc.conf
RUN ldconfig
RUN find /gcc/bin -type f -exec ln -sf {} /usr/local/bin \;
