#!/bin/bash -eu

function jupyter_scripts() {
    cat <<'EOF'
    eval $(opam config env) && \
    \
    sudo pip3 install --upgrade pip && \
    pip3 install --user --no-cache-dir jupyter && \
    opam update && \
    opam install -y 'merlin>=3.0.0' cairo2 archimedes jupyter && \
    \
    rm -rf $HOME/.opam/archives \
           $HOME/.opam/repo/default/archives \
           $HOME/.opam/$OCAML_VERSION/man \
           $HOME/.opam/$OCAML_VERSION/build
EOF
}

function centos7_scripts() {
    cat <<EOF
RUN sudo yum install -y epel-release && \\
    sudo yum install -y --enablerepo=epel \\
      which gcc m4 zeromq-devel libffi-devel gmp-devel cairo-devel python34-devel python34-pip && \\
    \\
$(jupyter_scripts) && \\
    \\
    sudo yum clean all
EOF
}

function debian_scripts() {
    cat <<EOF
RUN sudo apt-get update && \\
    sudo apt-get upgrade -y && \\
    sudo apt-get install -y gcc m4 pkg-config libzmq3-dev libffi-dev libgmp-dev libcairo2-dev python3-dev python3-pip && \\
    \\
$(jupyter_scripts) && \\
    \\
    sudo apt-get autoremove -y && \\
    sudo apt-get autoclean
EOF
}

echo "Generating dockerfiles/$TAG/Dockerfile (ALIAS=${ALIAS[@]})..."

rm -rf dockerfiles/$TAG
mkdir -p dockerfiles/$TAG

cat <<EOF > dockerfiles/$TAG/Dockerfile
FROM akabe/ocaml:${TAG}

ENV PATH \$PATH:/home/opam/.local/bin

EOF

if [[ "$OS" =~ ^centos:7 ]]; then
    centos7_scripts >> dockerfiles/$TAG/Dockerfile
    SHELL=bash
elif [[ "$OS" =~ ^debian: ]]; then
    debian_scripts >> dockerfiles/$TAG/Dockerfile
    SHELL=bash
else
    echo -e "\033[31m[ERROR] Unknown base image: ${OS}\033[0m"
    exit 1
fi

cat <<'EOF' >> dockerfiles/$TAG/Dockerfile

RUN mkdir -p /home/opam/.jupyter

COPY entrypoint.sh /
COPY .ocamlinit    /home/opam/.ocamlinit

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "jupyter", "notebook", "--no-browser", "--ip=*" ]
EOF

## .ocamlinit
cat <<'EOF' > dockerfiles/$TAG/.ocamlinit
let () =
  try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
  with Not_found -> ()
;;

#use "topfind" ;;
EOF

# entrypoint.sh
cat <<'EOF' > dockerfiles/$TAG/entrypoint.sh
#!/bin/bash
sudo chown -hR opam:opam /notebooks
opam config exec -- "$@"
EOF

chmod +x dockerfiles/$TAG/entrypoint.sh
