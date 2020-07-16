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
