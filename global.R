library(reticulate)
library(readr)
library(processx)

source("bowtie2_ui.R")
source("crispr_ui.R")

virtualenv_create("r-reticulate")
use_virtualenv("r-reticulate")
virtualenv_install("r-reticulate", c("pygments", "beautifulsoup4"))

manual <- read_file("www/MANUAL.html")
bs4 <- import("bs4")
soup <- bs4$BeautifulSoup(manual, "html.parser")

bt2 <- paste("/software", "bowtie2/bowtie2", sep = "/")
bt2_usage <- run(bt2, "--help")$stdout

enableBookmarking(store = "url")
