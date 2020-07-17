#!/bin/bash


# The mounting location (so we don't save to ephemeral container space)
cd /home/volume

# Load environment
source /home/ktran/miniconda3/bin/activate

########## Begin user-specific configurations ##########

# Configure environment
jt -t oceans16 -vim
jupyter nbextension enable vim_binding/vim_binding

# Set wandb parameters
export WANDB_CONFIG_DIR="$HOME/.config/wandb"
export WANDB_API_KEY=$REDACTED

# Finish installing GASpy
export PYTHONPATH="$HOME/GASpy/GASpy_regressions:${PYTHONPATH}"
export PYTHONPATH="$HOME/GASpy:${PYTHONPATH}"

########## End user-specific configurations ##########

# Launch Jupyter
jupyter notebook --config=$(jupyter --config-dir)/jupyter_notebook_config.json --no-browser --ip=0.0.0.0
