FROM akabe/ocaml:centos7_ocaml4.04.2

ENV PATH               $PATH:/home/opam/.local/bin
ENV TENSORFLOW_VERSION 1.1.0
ENV LD_LIBRARY_PATH    /usr/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH       /usr/lib:$LIBRARY_PATH

ADD MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN sudo yum install -y epel-release && \
    sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm && \
    sudo yum install -y --enablerepo=epel,nux-dextop \
      rsync \
      which \
      gcc \
      m4 \
      time \
      zeromq-devel \
      python34-devel \
      python34-pip \
      libffi-devel \
      gmp-devel \
      cairo-devel \
      gfortran \
      openssh-clients \
      blas-devel \
      lapack-devel \
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
    && \
    sudo ln -sf /usr/lib64/libmysqlclient.so.18.0.0 /usr/lib/libmysqlclient.so && \
    \
    sudo pip3 install --upgrade pip && \
    sudo pip3 install --no-cache-dir 'setuptools>=18.5' 'six>=1.9.0' jupyter jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --user && \
    mkdir -p /home/opam/.jupyter && \
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
           $HOME/.opam/$OCAML_VERSION/build && \
    \
    sudo yum remove -y rsync gfortran python34-devel && \
    sudo yum clean all

COPY entrypoint.sh /
COPY .ocamlinit    /home/opam/.ocamlinit
COPY notebook.json /home/opam/.jupyter/nbconfig/notebook.json

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "jupyter", "notebook", "--no-browser", "--ip=*" ]
