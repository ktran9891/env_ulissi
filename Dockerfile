FROM nvcr.io/nvidia/pytorch:20.02-py3
ARG USERNAME=ktran


# Set up a cleaner install of apt-get so that we can `apt build-dep` later
RUN cp /etc/apt/sources.list /etc/apt/sources.list~
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
RUN apt-get update

# Essential, baseline installations
RUN apt-get install -y openssh-server
RUN apt-get install -y nano git vim build-essential curl wget

# SSH configuration to enable swarming
RUN mkdir /var/run/sshd
RUN sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Other configurations required for swarming
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Define username & environment
RUN useradd -rm -d /home/$USERNAME -s /bin/bash -g root -G sudo -u 1000 $USERNAME
RUN echo $USERNAME:$USERNAME | chpasswd

########## Begin user-specific configurations ##########

# Install vanilla Python packages
RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh
RUN /bin/bash Miniconda3-4.7.12-Linux-x86_64.sh -bp /home/$USERNAME/miniconda3
RUN rm Miniconda3-4.7.12-Linux-x86_64.sh
ENV PATH /home/$USERNAME/miniconda3/bin:$PATH
RUN conda config --prepend channels conda-forge
RUN conda install numpy scipy pandas seaborn tqdm flake8
RUN conda clean -ity
RUN echo "export PATH=\"/home/${USERNAME}/miniconda3/bin:$PATH\"" >> /home/$USERNAME/.bashrc

# Personal configurations
COPY bashrc_additions.sh .
RUN cat bashrc_additions.sh >> /home/$USERNAME/.bashrc
RUN rm bashrc_additions.sh
RUN chown -R $USERNAME /home/$USERNAME/.bashrc

# Configure VIM
RUN git clone https://github.com/VundleVim/Vundle.vim.git /home/$USERNAME/.vim/bundle/Vundle.vim
COPY .vimrc /home/$USERNAME/.vimrc
RUN chown -R $USERNAME /home/$USERNAME/.vimrc /home/$USERNAME/.vim
RUN su - ktran -c "vim +PluginInstall +qall"
RUN mkdir -p /home/$USERNAME/.config
COPY flake8 /home/$USERNAME/.config/
RUN chown -R $USERNAME /home/$USERNAME/.config

# Install dependencies for "baselines" repo
RUN conda config --prepend channels pytorch
RUN conda install \
    cudatoolkit=10.1 \
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
RUN pip install --no-cache-dir \
    demjson \
    Pillow \
    ray[tune] \
    torch-geometric==1.5.* \
    wandb \
    lmdb==0.98
RUN pip install --no-cache-dir \
    -f https://pytorch-geometric.com/whl/torch-1.5.0.html \
    torch-cluster==latest+cu101 \
    torch-scatter==latest+cu101 \
    torch-sparse==latest+cu101 \
    torch-spline-conv==latest+cu101

# Install baselines
RUN pip install --no-cache-dir git+https://github.com/Open-Catalyst-Project/baselines.git@cfgp_gpu

# Install catalyst-acquisitions dependencies
RUN conda config --append channels lmmentel
RUN conda config --append channels plotly
RUN conda install \
    mendeleev \
    tpot>=0.9.5 xgboost>=0.80 \
    plotly>=4.1.1 chart-studio>=1.0.0 \
    shapely \
    fireworks \
    luigi>=2.8.9 \
    statsmodels>=0.9.0 \
    multiprocess>=0.70.5 \
    pymongo=3.8.0 \
    atomicwrites
RUN conda clean -ity

# Install GASpy
RUN git clone https://github.com/ulissigroup/GASpy.git /home/$USERNAME/GASpy
RUN git clone https://github.com/ulissigroup/GASpy_regressions.git /home/$USERNAME/GASpy/GASpy_regressions
COPY gaspyrc.json /home/$USERNAME/GASpy/.gaspyrc.json

# Install profilers
RUN conda install pyinstrument line_profiler && conda clean -ity

# Fix some more environmental variables
COPY extra_bashrc.sh .
RUN cat extra_bashrc.sh >> /home/$USERNAME/.bashrc
RUN rm extra_bashrc.sh


########## End user-specific configurations ##########

# Make the folder to mount to
RUN mkdir -p /home/volume
RUN chown -R $USERNAME /home/volume
RUN echo "cd /home/volume" >> /home/$USERNAME/.bashrc

# Enable password-less ssh
EXPOSE 22
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY default_authorized_keys /usr/local/etc
ENTRYPOINT ["/bin/bash", "-c", "runuser -l ktran /usr/local/bin/entrypoint.sh; /usr/sbin/sshd -D"]
