## Dummy Service "Filter Data"
## Last Updated: 2022_10_13

# Install latest version of rocker image
FROM rocker/tidyverse:4.2.1

# Install general use packages
RUN apt-get update && apt-get install -y \
    sudo \
    libssl-dev \
    libcurl4-openssl-dev \
    libhiredis-dev \
    libzmq3-dev \
    libxt-dev \
    vim python3-venv 

# Install RWorker
RUN Rscript -e "install.packages(c('devtools', 'stringr', 'rzmq', 'redux', 'R6', 'processx', 'jsonlite', 'glue', 'futile.logger', 'crayon', 'base64enc'), repos =  'https://cran.rstudio.com')"
RUN Rscript -e "devtools::install_github('amwhite/rworker', repos = 'https://cran.rstudio.com')"

# Set up python virtual env and install dependencies
COPY requirements.txt .
RUN python3 -m venv venv
RUN venv/bin/pip install --upgrade pip --trusted-host=pypi.org --trusted-host=files.pythonhosted.org 
RUN venv/bin/pip install -r requirements.txt --trusted-host=pypi.org --trusted-host=files.pythonhosted.org  

# install mapDataAccess R package from gitlab
RUN Rscript -e "install.packages(c('reticulate', 'yaml'), repos =  'https://cran.rstudio.com')"

# Add redis 
RUN Rscript -e "reticulate::use_virtualenv('/venv'); reticulate::py_install('Redis')"

# Copy over required folders
COPY rworker.R /
COPY cfg /cfg/ 

# Add the config files (these are dummy files in the repo, still need to mount actual config files)
COPY minio_config.yml /minio_config.yml
COPY redis_config.yml /redis_config.yml

CMD ["Rscript", "rworker.R", "&"]
