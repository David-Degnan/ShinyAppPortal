## Dummy App "FilterData" dockerfile
## Last Updated: 2022_10_13

# Install latest version of rocker image
FROM rocker/shiny:4.2.1

# Load general use libraries
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    xdg-utils \
    vim python3-venv

# Install python dependencies
RUN python3 -m venv /venv
RUN /venv/bin/pip install --upgrade pip
COPY requirements.txt .
RUN /venv/bin/pip install -r requirements.txt

# Install necessary packages
RUN Rscript -e 'install.packages(c("shiny", "remotes"))'

# Install mapDataAccess
RUN Rscript -e 'remotes::install_github("EMSL-Computing/mapDataAccess")'

# Copy app.R into the shiny-server directory
COPY app.R /srv/shiny-server/
COPY cfg /srv/shiny-server/

# Make the ShinyApp available at port 4200
EXPOSE 4200

# Launch App
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', host = '0.0.0.0', port = 4200)"]