# Adapted from https://github.com/andferrari/julia_notebook/blob/master/Dockerfile
FROM jupyter/minimal-notebook

# Set notebook user
USER root

# Set julia version
ENV JULIA_VERSION=1.7.1

# Uncomment to build with GPU
# ENV GPU=1

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz

RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

USER $NB_UID

# Update package registry
RUN julia -e 'using Pkg;Pkg.update()'

# Install julia packages and precompile
RUN julia -e 'using Pkg;Pkg.add("ADCME"); using ADCME'
RUN /home/jovyan/.julia/adcme/bin/python -m pip install colorcet
RUN julia -e 'using Pkg;Pkg.add("IJulia"); using IJulia'
RUN julia -e 'using Pkg;Pkg.add("PyCall"); using PyCall'
RUN julia -e 'using Pkg; ENV["PYTHON"]="/usr/bin/python3"; Pkg.build("PyCall")'
RUN julia -e 'using Pkg;Pkg.add("PyPlot"); using PyPlot'
RUN julia -e 'using Pkg;Pkg.add("Polynomials"); using Polynomials'

# Fix user permissions for notebook user
RUN fix-permissions /home/$NB_USER

# Add SLIM Packages
RUN julia -e 'using Pkg;Pkg.add("Random")' && \
    julia -e 'using Pkg;Pkg.add("Images")' && \
    julia -e 'using Pkg;Pkg.add("JLD2")' && \
    julia -e 'using Pkg; Pkg.add(url="https://github.com/slimgroup/SlimPlotting.jl.git")'

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential ca-certificates wget openssh-client openssh-server \
        mpich libmpich-dev environment-modules

# Required application packages
RUN apt-get install -y gfortran python3-pip && \
    apt-get install -y git wget vim htop hdf5-tools

# Add Devito
RUN /home/jovyan/.julia/adcme/bin/python -m pip install devito

# Add JUDI
RUN julia -e 'ENV["PYTHON"]="/home/jovyan/.julia/adcme/bin/python"; using Pkg; Pkg.add("JUDI")'
# Change to notebook directory
WORKDIR /notebooks
RUN chmod -R 777 /notebooks

USER ${NB_UID}

ADD startup.sh /startup.sh
CMD ["/bin/bash", "/startup.sh"]
