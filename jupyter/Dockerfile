FROM ktran9891/env_ulissi:baselines
ARG USERNAME=ktran


# Install new conda packages
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

# Update the entrypoint to start Jupyter with some extra settings
COPY start-notebook.sh /usr/local/bin/start-notebook.sh
ENTRYPOINT ["/bin/bash", "-c", "runuser -l ktran /usr/local/bin/start-notebook.sh"]
