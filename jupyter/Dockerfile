FROM ktran9891/env_ulissi:latest
ARG USERNAME=ktran


# Install Jupyter
RUN conda install jupyter

########## Begin user-specific configurations ##########

# Jupyter extension manager
RUN conda install jupyter_nbextensions_configurator
RUN su - $USERNAME bash -c "source /home/ktran/miniconda3/bin/activate && jupyter nbextensions_configurator enable"

# Vim bindings for Jupyter
ARG JUPYTER_DIR=/home/$USERNAME/.local/share/jupyter
RUN mkdir -p $JUPYTER_DIR/nbextensions
RUN git clone https://github.com/lambdalisue/jupyter-vim-binding $JUPYTER_DIR/nbextensions/vim_binding

# Jupyter theme
RUN pip install jupyterthemes

# Only the development version of ipycache works right now
RUN pip install git+https://github.com/rossant/ipycache.git

# Let user modify files for configuration during runtime
RUN chown -R $USERNAME $JUPYTER_DIR

# Install dependencies for "baselines" repo
RUN conda config --prepend channels pytorch
RUN conda install \
    cudatoolkit=10.0 \
    ase=3.19.* \
    pymatgen=2020.4.2 \
    pre-commit=2.2.* \
    pytorch=1.5.* \
    tensorboard=1.15.* \
    pyyaml=5.3.* \
    gpytorch \
    pytest
RUN conda clean -ity
RUN pip install --upgrade pip
RUN pip install \
    demjson \
    Pillow \
    ray[tune] \
    torch-geometric==1.5.* \
    wandb \
    lmdb==0.98
RUN pip install -f https://pytorch-geometric.com/whl/torch-1.5.0.html \
    torch-cluster==latest+cu101 \
    torch-scatter==latest+cu101 \
    torch-sparse==latest+cu101 \
    torch-spline-conv==latest+cu101

# Install baselines
RUN pip install git+https://github.com/Open-Catalyst-Project/baselines.git

########## End user-specific configurations ##########

# Expose the Jupyter port
EXPOSE 8888

# Change the entrypoint to start Jupyter instead
COPY start-notebook.sh /usr/local/bin/start-notebook.sh
ENTRYPOINT ["/bin/bash", "-c", "runuser -l ktran /usr/local/bin/start-notebook.sh"]
