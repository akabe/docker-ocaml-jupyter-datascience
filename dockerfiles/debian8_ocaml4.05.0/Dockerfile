FROM akabe/ocaml:debian8_ocaml4.05.0

ENV PATH               $PATH:/home/opam/.local/bin
ENV TENSORFLOW_VERSION 1.1.0
ENV LD_LIBRARY_PATH    /usr/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH       /usr/lib:$LIBRARY_PATH
# For phantomjs:
ENV QT_QPA_PLATFORM    offscreen

ADD ocaml-jupyter-datascience-extra.list /etc/apt/sources.list.d/ocaml-jupyter-datascience-extra.list

RUN sudo apt-get install -y python3-dev python3-pip && \
    sudo pip3 install --upgrade pip && \
    pip3 install --user --no-cache-dir 'setuptools>=18.5' 'six>=1.9.0' jupyter jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --user && \
    mkdir -p /home/opam/.jupyter && \
    sudo apt-get purge -y python3-dev && \
    sudo apt-get autoremove -y && \
    sudo apt-get autoclean

RUN sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db && \
    sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y \
      m4 \
      rsync \
      gcc \
      gfortran \
      aspcud \
      pkg-config \
      ssh \
      libzmq3-dev \
      libffi-dev \
      libgmp-dev \
      libcairo2-dev \
      libplplot-dev plplot12-driver-cairo \
      libffi-dev \
      libgsl0-dev \
      libfftw3-dev \
      libsvm-dev \
      libcairo2-dev \
      libmariadb-dev \
      libpq-dev \
      libsqlite3-dev \
      libgmp-dev \
      imagemagick \
      ffmpeg \
    && \
    sudo apt-get install -t jessie-backports -y \
      libblas3 libblas-dev \
      liblapack3 liblapack-dev \
      libopenblas-dev \
      liblapacke liblapacke-dev \
      phantomjs \
    && \
    sudo ln -sf /usr/lib/x86_64-linux-gnu/libmysqlclient.so.20 /usr/lib/libmysqlclient.so && \
    sudo ln -sf /usr/lib/x86_64-linux-gnu/libshp.so.2 /usr/lib/libshp.so && \
    sudo ln -sf /etc/fonts /usr/lib/x86_64-linux-gnu/fonts && \
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
      camomile && \
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
    sudo apt-get purge -y m4 rsync gcc gfortran aspcud pkg-config && \
    sudo apt-get autoremove -y && \
    sudo apt-get autoclean

VOLUME /notebooks
VOLUME /home/opam/.jupyter
WORKDIR /notebooks

COPY entrypoint.sh /
COPY .ocamlinit    /home/opam/.ocamlinit
COPY .jupyter      /home/opam/.jupyter

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "jupyter", "notebook", "--no-browser", "--ip=*" ]
