#!su ktran /bin/bash


if [ ! -d "~/.ssh/" ] 
then 
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
    cp /usr/local/etc/default_authorized_keys ~/.ssh/authorized_keys
fi
