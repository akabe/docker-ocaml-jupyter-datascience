#!/bin/bash -eu

function install_jupyter() {
	cat <<'EOF'
    sudo pip3 install --upgrade pip && \
    pip3 install --user --no-cache-dir 'setuptools>=18.5' 'six>=1.9.0' jupyter jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --user && \
    mkdir -p /home/opam/.jupyter
EOF
}

function install_opam_packages() {
    cat <<'EOF'
    eval $(opam config env) && \
    \
    opam update && \
    opam upgrade -y && \
    (opam install -y batteries 'lwt>=3.0.0' lwt_ssl tls cohttp-async cohttp-lwt-unix || :) && \
    opam install -y \
      'cppo=1.5.0' \
      'merlin>=3.0.0' \
      'cairo2>=0.5' \
      archimedes \
      'stdint<0.4.0' \
      jupyter \
      'core>=v0.9.0' \
      'async>=v0.9.0' \
      lacaml \
      slap \
      lbfgs \
      ocephes \
      oml \
      gsl \
      gpr \
      fftw3 \
      mysql \
      'mariadb>=0.8.1' \
      postgresql \
      sqlite3 \
      'oasis>=0.4.0' && \
    \
    : install libsvm && \
    curl -L https://bitbucket.org/ogu/libsvm-ocaml/downloads/libsvm-ocaml-0.9.3.tar.gz \
         -o /tmp/libsvm-ocaml-0.9.3.tar.gz && \
    tar zxf /tmp/libsvm-ocaml-0.9.3.tar.gz -C /tmp && \
    ( \
      cd /tmp/libsvm-ocaml-0.9.3 && \
      oasis setup && \
      ./configure --prefix=$(opam config var prefix) && \
      make && \
      make install \
    ) && \
    rm -rf /tmp/libsvm-ocaml-0.9.3.tar.gz /tmp/libsvm-ocaml-0.9.3 && \
    \
    : install tensorflow && \
    sudo curl -L "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-$TENSORFLOW_VERSION.tar.gz" | sudo tar xz -C /usr && \
    curl -L "https://github.com/LaurentMazare/tensorflow-ocaml/archive/0.0.10.1.tar.gz" \
         -o /tmp/tensorflow-ocaml-0.0.10.1.tar.gz && \
    tar zxf /tmp/tensorflow-ocaml-0.0.10.1.tar.gz -C /tmp && \
    ( \
      cd /tmp/tensorflow-ocaml-0.0.10.1 && \
      sed -i 's/(no_dynlink)//' src/wrapper/jbuild && \
      sed -i 's/(modes (native))//' src/wrapper/jbuild \
    ) && \
    opam pin add -y /tmp/tensorflow-ocaml-0.0.10.1 && \
    rm -rf /tmp/tensorflow-ocaml-0.0.10.1.tar.gz /tmp/tensorflow-ocaml-0.0.10.1 && \
    \
    rm -rf $HOME/.opam/archives \
           $HOME/.opam/repo/default/archives \
           $HOME/.opam/$OCAML_VERSION/man \
           $HOME/.opam/$OCAML_VERSION/build
EOF
}

function centos7_scripts() {
	cat <<'EOF' > dockerfiles/$TAG/MariaDB.repo
[mariadb]
name=MariaDB
baseurl=http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

    cat <<EOF
ADD MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN sudo yum install -y epel-release && \\
    sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm && \\
    sudo yum install -y --enablerepo=epel,nux-dextop \\
      rsync \\
      which \\
      gcc \\
      m4 \\
      time \\
      zeromq-devel \\
      python34-devel \\
      python34-pip \\
      libffi-devel \\
      gmp-devel \\
      cairo-devel \\
      gfortran \\
      openssh-clients \\
      blas-devel \\
      lapack-devel \\
      gsl-devel \\
      fftw-devel \\
      libsvm-devel \\
      MariaDB-devel \\
      postgresql-devel \\
      sqlite-devel \\
      gmp-devel \\
      openssl-devel \\
      ImageMagick \\
      ffmpeg \\
    && \\
    sudo ln -sf /usr/lib64/libmysqlclient.so.18.0.0 /usr/lib/libmysqlclient.so && \\
    \\
$(install_jupyter) && \\
$(install_opam_packages) && \\
    \\
    sudo yum remove -y rsync gfortran python34-devel && \\
    sudo yum clean all
EOF
}

function debian_scripts() {
	cat <<'EOF' > dockerfiles/$TAG/ocaml-jupyter-datascience-extra.list
deb http://ftp.uk.debian.org/debian jessie-backports main
deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/10.2/debian jessie main
EOF

    cat <<EOF
ADD ocaml-jupyter-datascience-extra.list /etc/apt/sources.list.d/ocaml-jupyter-datascience-extra.list

RUN sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db && \\
    sudo apt-get update && \\
    sudo apt-get upgrade -y && \\
    sudo apt-get install -y \\
      rsync \\
      gcc \\
      m4 \\
      time \\
      gfortran \\
      pkg-config \\
      ssh \\
      python3-dev \\
      python3-pip \\
      libzmq3-dev \\
      libffi-dev \\
      libgmp-dev \\
      libcairo2-dev \\
      libffi-dev \\
      libblas-dev \\
      liblapack-dev \\
      libgsl0-dev \\
      libfftw3-dev \\
      libsvm-dev \\
      libcairo2-dev \\
      libmariadb-dev \\
      libpq-dev \\
      libsqlite3-dev \\
      libgmp-dev \\
      imagemagick \\
      ffmpeg \\
    && \\
    sudo ln -sf /usr/lib/x86_64-linux-gnu/libmysqlclient.so.20 /usr/lib/libmysqlclient.so && \\
    \\
$(install_jupyter) && \\
$(install_opam_packages) && \\
    \\
    sudo apt-get purge -y rsync gfortran python3-dev && \\
    sudo apt-get autoremove -y && \\
    sudo apt-get autoclean
EOF
}

echo "Generating dockerfiles/$TAG/Dockerfile (ALIAS=${ALIAS[@]})..."

rm -rf dockerfiles/$TAG
mkdir -p dockerfiles/$TAG

cat <<EOF > dockerfiles/$TAG/Dockerfile
FROM akabe/ocaml:${TAG}

ENV PATH               \$PATH:/home/opam/.local/bin
ENV TENSORFLOW_VERSION 1.1.0
ENV LD_LIBRARY_PATH    /usr/lib:\$LD_LIBRARY_PATH
ENV LIBRARY_PATH       /usr/lib:\$LIBRARY_PATH

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

COPY entrypoint.sh /
COPY .ocamlinit    /home/opam/.ocamlinit
COPY notebook.json /home/opam/.jupyter/nbconfig/notebook.json

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
Topfind.log := ignore ;; (* prevent noisy logs *)
EOF

## notebook.json
cat <<'EOF' > dockerfiles/$TAG/notebook.json
{
  "Cell": {
    "load_extensions": {
      "contrib_nbextensions_help_item/main": true,
      "nbextensions_configurator/config_menu/main": true
    },
    "cm_config": {
      "indentUnit": 2,
      "lineNumbers": true,
      "autoCloseBrackets": true
    }
  }
}
EOF

# entrypoint.sh
cat <<'EOF' > dockerfiles/$TAG/entrypoint.sh
#!/bin/bash
sudo chown -hR opam:opam /notebooks
opam config exec -- "$@"
EOF

chmod +x dockerfiles/$TAG/entrypoint.sh
