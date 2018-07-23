FROM rocker/shiny

RUN apt-get update && apt-get install -y python python-pip virtualenv curl

RUN Rscript -e "install.packages(c('shinyjs', 'rclipboard', 'shinydashboard', 'processx', 'reticulate'), repos='https://cran.rstudio.com/')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN mkdir -p /srv/shiny-server/bt2-ui
COPY bowtie2 /srv/shiny-server/bt2-ui/bowtie2
COPY www /srv/shiny-server/bt2-ui/www
COPY MANUAL.markdown /srv/shiny-server/bt2-ui/
COPY *.R /srv/shiny-server/bt2-ui/
COPY *.py /srv/shiny-server/bt2-ui/
