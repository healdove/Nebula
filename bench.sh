#!/bin/sh

case $1 in
  system) ;;
  mimalloc) export LD_PRELOAD=$MIMALLOC_LIB ;;
  tcmalloc) export LD_PRELOAD=$TCMALLOC_LIB ;;
  jemalloc) export LD_PRELOAD=$JEMALLOC_LIB ;;
esac

DreamDaemon nebula.dmb -trusted