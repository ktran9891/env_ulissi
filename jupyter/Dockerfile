FROM ktran9891/env_ulissi:cat_ssh
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


########## End user-specific configurations ##########

# Expose the Jupyter port
EXPOSE 8888

# Update the entrypoint to start Jupyter with some extra settings
COPY start-notebook.sh /usr/local/bin/start-notebook.sh
ENTRYPOINT ["/bin/bash", "-c", "runuser -l ktran /usr/local/bin/start-notebook.sh"]
