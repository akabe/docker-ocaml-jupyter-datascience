FROM akabe/ocaml:debian8_ocaml4.04.2

ENV PATH $PATH:/home/opam/.local/bin

RUN sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y gcc m4 pkg-config libzmq3-dev libffi-dev libgmp-dev libcairo2-dev python3-dev python3-pip && \
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
    sudo apt-get autoremove -y && \
    sudo apt-get autoclean

RUN mkdir -p /home/opam/.jupyter

COPY entrypoint.sh /
COPY .ocamlinit    /home/opam/.ocamlinit

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "jupyter", "notebook", "--no-browser", "--ip=*" ]
