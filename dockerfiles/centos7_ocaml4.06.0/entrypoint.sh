#!/bin/bash

sudo chown -hR opam:opam /notebooks

if ! [[ -f /notebooks/.merlin ]]; then
	cat <<'EOF' >/notebooks/.merlin
PKG jupyter
PKG jupyter.notebook
PKG jupyter.archimedes

PKG core
PKG batteries
PKG lacaml
PKG slap
PKG gsl
PKG owl
PKG fftw3
PKG libsvm
PKG tensorflow
PKG lbfgs
PKG ocephes
PKG oml
PKG gpr
PKG archimedes
PKG cairo2
PKG plplot

PKG async
PKG lwt
PKG lwt.unix
PKG lwt.omp
PKG lwt.log
PKG lwt.preemptive
PKG lwt_ssl
PKG tls

PKG mysql
PKG mariadb
PKG postgresql
PKG sqlite3
PKG cohttp-lwt-unix
PKG cohttp-async
EOF
fi

opam config exec -- "$@"
