FROM akabe/ocaml:centos7_ocaml4.04.2

ENV PATH               $PATH:/home/opam/.local/bin
ENV TENSORFLOW_VERSION 1.1.0
ENV LD_LIBRARY_PATH    /usr/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH       /usr/lib:$LIBRARY_PATH
# For phantomjs:
ENV QT_QPA_PLATFORM    offscreen

ADD MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN sudo yum install -y epel-release && \
    sudo yum install -y python34-devel python34-pip && \
    sudo pip3 install --upgrade pip && \
    pip3 install --user --no-cache-dir 'setuptools>=18.5' 'six>=1.9.0' jupyter jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --user && \
    mkdir -p /home/opam/.jupyter && \
    sudo yum remove -y python34-devel && \
    sudo yum clean all

RUN sudo curl -o /usr/bin/aspcud 'https://raw.githubusercontent.com/avsm/opam-solver-proxy/8f162de1fe89b2e243d89961f376c80fde6de76d/aspcud.docker' && \
    sudo chmod 755 /usr/bin/aspcud && \
    sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm && \
    sudo rpm -ivh http://repo.okay.com.mx/centos/7/x86_64/release/okay-release-1-1.noarch.rpm && \
    sudo yum install -y --enablerepo=epel,nux-dextop \
      which \
      m4 \
      rsync \
      gcc \
      gcc-c++ \
      zeromq-devel \
      libffi-devel \
      gmp-devel \
      cairo-devel \
      plplot-devel \
      openssh-clients \
      blas-devel \
      lapack-devel \
      openblas-devel \
      gsl-devel \
      fftw-devel \
      libsvm-devel \
      MariaDB-devel \
      postgresql-devel \
      sqlite-devel \
      gmp-devel \
      openssl-devel \
      ImageMagick \
      ffmpeg \
      phantomjs \
    && \
    sudo mv /usr/include/openblas/* /usr/include/ && \
    sudo ln -sf /usr/lib64/libmysqlclient.so.18.0.0 /usr/lib/libmysqlclient.so && \
    sudo ln -sf /usr/lib64/libmysqlclient.so.18.0.0 /usr/lib/libmariadb.so && \
    sudo ln -sf /usr/lib64/libopenblas.so.0 /usr/lib/libopenblas.so && \
    \
    eval $(opam config env) && \
    \
    opam update && \
    opam upgrade -y && \
    opam install -y \
      batteries \
      'core>=v0.9.0' \
      'async>=v0.9.0' \
      'lwt>=3.0.0' \
      lwt_ssl \
      'cstruct>=3.1.1' 'ppx_cstruct>=3.1.1' 'tls>=0.8.0' \
      cohttp-async \
      cohttp-lwt-unix \
      cohttp-top \
      'cairo2>=0.5' archimedes \
      'merlin>=3.0.0' 'jupyter>=1.0.0' \
      lacaml \
      slap \
      lbfgs \
      ocephes \
      oml \
      gsl \
      gpr \
      fftw3 \
      'dolog>=3.0' 'eigen>=0.0.3' 'oasis>=0.4.10' 'owl>=0.2.6' \
      mysql \
      'mariadb>=0.8.1' \
      postgresql \
      sqlite3 \
      lambdasoup \
      csv csv-lwt \
      camomile \
      ppx_sexp_conv \
      ppx_deriving_yojson \
      ppx_regexp && \
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
           $HOME/.opam/$OCAML_VERSION/build && \
    \
    sudo yum remove -y which m4 rsync gcc gcc-c++ gcc-gfortran && \
    sudo yum clean all && \
    sudo rm -f /usr/bin/aspcud

VOLUME /notebooks
VOLUME /home/opam/.jupyter
WORKDIR /notebooks

COPY entrypoint.sh /
COPY .ocamlinit    /home/opam/.ocamlinit
COPY .jupyter      /home/opam/.jupyter

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "jupyter", "notebook", "--no-browser", "--ip=*" ]
