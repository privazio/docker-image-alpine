GPG=gpg
CURL=curl
DOCKER=docker

ARCH=$(shell uname -m)
VERSION=$(shell cat VERSION)
VERSION_NP=${shell echo ${VERSION} | cut -d. -f1-2}

MIRROR=${shell cat MIRROR}
PKG=alpine-minirootfs-${VERSION}-${ARCH}.tar.gz
PKGURL=https://${MIRROR}/alpine/v${VERSION_NP}/releases/${ARCH}/${PKG}

GPG_OPS=--no-default-keyring --trust-model always --keyring ./publishers.gpg

TAGS= -t alpine-${ARCH}:${VERSION} -t alpine-${ARCH}:${VERSION_NP} -t alpine-${ARCH}:latest

all: clean build

rootfs.tgz:
	${CURL} ${PKGURL} > rootfs.tgz

rootfs.tgz.asc:
	${CURL} ${PKGURL}.asc > rootfs.tgz.asc

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
