FROM rocker/shiny

RUN apt-get update && apt-get install -y python python-pip virtualenv curl less

RUN Rscript -e "install.packages(c('readr', 'shinyjs', 'rclipboard', 'shinydashboard', 'processx', 'reticulate', 'shinyBS', 'digest', 'rintrojs'), repos='https://cran.rstudio.com/')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN mkdir -p /srv/shiny-server/bt2-ui
COPY www /srv/shiny-server/bt2-ui/www
COPY MANUAL.markdown /srv/shiny-server/bt2-ui/
COPY *.R /srv/shiny-server/bt2-ui/
COPY *.py /srv/shiny-server/bt2-ui/

RUN R -e "rmarkdown::render('/srv/shiny-server/bt2-ui/MANUAL.markdown',output_file='/srv/shiny-server/bt2-ui/www/MANUAL.html')"
