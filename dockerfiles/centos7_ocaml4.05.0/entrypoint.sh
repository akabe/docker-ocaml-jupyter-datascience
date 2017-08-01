#!/bin/bash
sudo chown -hR opam:opam /notebooks
opam config exec -- "$@"
