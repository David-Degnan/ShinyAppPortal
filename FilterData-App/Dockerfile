## Dummy App "FilterData" dockerfile
## Last Updated: 2020_11_16

# Install latest version of rocker image
FROM rocker/shiny:4.0.3

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
    xdg-utils 

# Install necessary packages
RUN Rscript -e 'install.packages(c("shiny", "dataset", "plumber", "shinyWidgets", "uuid"))'

# Copy app.R into the shiny-server directory
COPY app.R /srv/shiny-server/
COPY data /data

# Make the ShinyApp available at port 4200
EXPOSE 4200

# Allow permission
RUN sudo chown -R shiny:shiny  /data

# Launch App
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', host = '0.0.0.0', port = 4200)"]