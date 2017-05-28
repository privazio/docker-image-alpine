GPG=$(shell which gpg)
CURL=$(shell which curl)
DOCKER=$(shell which docker)
ARI=$(shell which alpine_release_info)

ARCH=$(shell uname -m)
BRANCH=latest-stable
ARI_OPS=--branch ${BRANCH} --arch ${ARCH} --flavor alpine-minirootfs

VERSION=$(shell ${ARI} ${ARI_OPS} --query version)
VERSION_NP=${shell echo ${VERSION} | cut -d. -f1-2}

PKGURL=$(shell ${ARI} ${ARI_OPS} --query url)
PKGSIG=$(shell ${ARI} ${ARI_OPS} --query gpgsig)

GPG_OPS=--no-default-keyring --trust-model always --keyring ./publishers.gpg

ifeq ($(BRANCH),latest-stable)
  LTAG= -t alpine-${ARCH}:latest
endif

TAGS= -t alpine-${ARCH}:${VERSION} -t alpine-${ARCH}:${VERSION_NP} ${LTAG}

all: clean build

rootfs.tgz:
	${CURL} ${PKGURL} > rootfs.tgz

rootfs.tgz.asc:
	${CURL} ${PKGSIG} > rootfs.tgz.asc

publishers.gpg: 
	${GPG} --no-default-keyring --keyring ./$@ --import publishers-gpg-keys/*.asc 

build: rootfs.tgz rootfs.tgz.asc publishers.gpg
	${GPG} ${GPG_OPS} --verify rootfs.tgz.asc rootfs.tgz && ${DOCKER} build . ${TAGS}

clean:
	rm -f *.tgz
	rm -f *.tgz.asc
	rm -f *.gpg
	rm -f *~

.PHONY: clean build
