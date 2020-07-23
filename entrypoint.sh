#!su ktran /bin/bash


########## Begin user-specific configurations ##########

# Load environment
source /home/ktran/miniconda3/bin/activate

# Set wandb parameters
export WANDB_CONFIG_DIR="$HOME/.config/wandb"
export WANDB_API_KEY="577458cd7eb09405c7a88fbd43067723dae8c154"

# Finish installing GASpy
export PYTHONPATH="$HOME/GASpy/GASpy_regressions:${PYTHONPATH}"
export PYTHONPATH="$HOME/GASpy:${PYTHONPATH}"

########## End user-specific configurations ##########

if [ ! -d "~/.ssh/" ] 
then 
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
    cp /usr/local/etc/default_authorized_keys ~/.ssh/authorized_keys
fi
