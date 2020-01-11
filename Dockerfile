FROM rocker/shiny

RUN apt-get update && apt-get install -y python python-pip python-virtualenv curl less git zlib1g-dev libtbb-dev libssl-dev openjdk-8-jdk

RUN git clone https://github.com/BenLangmead/bowtie2.git /tmp/bowtie2 \
        && cd /tmp/bowtie2 && git checkout bt2_cxx11 && make sra-deps \
        && make bowtie2-align-s USE_SRA=1 BOWTIE_SHARED_MEM=1 \
        && mkdir -p /software/bowtie2 \
        && cp /tmp/bowtie2/bowtie2-align-s /tmp/bowtie2/bowtie2 /software/bowtie2

RUN git clone https://github.com/BenLangmead/bowtie.git /tmp/bowtie \
        && cd /tmp/bowtie && git checkout bt2_idx_support \
        && make bowtie-align-s BOWTIE_SHARED_MEM=1 \
        && mkdir -p /software/bowtie \
        && cp /tmp/bowtie/bowtie-align-s /tmp/bowtie/bowtie /software/bowtie

RUN Rscript -e "install.packages(c('shinyFeedback', 'devtools', 'dplyr', 'readr', 'shinyjs', 'rclipboard', 'processx', 'reticulate', 'shinyBS', 'digest', 'rintrojs', 'plotly'), repos='https://cran.rstudio.com/')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
    
RUN apt-get install -y libxml2-dev

RUN Rscript -e "install.packages('devtools'); devtools::install_github('rstudio/shinydashboard'); devtools::install_github('andrewsali/shinycssloaders')"

RUN mkdir -p /srv/shiny-server/bt2-ui
COPY www /srv/shiny-server/bt2-ui/www
COPY MANUAL.markdown /srv/shiny-server/bt2-ui/
COPY *.R /srv/shiny-server/bt2-ui/
COPY *.py /srv/shiny-server/bt2-ui/
COPY python_requirments.txt /srv/shiny-server/bt2-ui/
RUN apt-get install -y python3-pip
RUN pip3 install -r /srv/shiny-server/bt2-ui/python_requirments.txt

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

RUN R -e "rmarkdown::render('/srv/shiny-server/bt2-ui/MANUAL.markdown',output_file='/srv/shiny-server/bt2-ui/www/MANUAL.html')"

