FROM akabe/ocaml:centos7_ocaml4.04.1

ENV PATH $PATH:/home/opam/.local/bin

RUN sudo yum install -y epel-release && \
    sudo yum install -y --enablerepo=epel \
      which gcc m4 zeromq-devel libffi-devel gmp-devel cairo-devel python34-devel python34-pip && \
    \
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
           $HOME/.opam/$OCAML_VERSION/build && \
    \
    sudo yum clean all

RUN mkdir -p /home/opam/.jupyter

COPY entrypoint.sh /
COPY .ocamlinit    /home/opam/.ocamlinit

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "jupyter", "notebook", "--no-browser", "--ip=*" ]
