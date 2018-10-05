#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(shinyBS)
library(parallel)
library(rintrojs)
library(markdown)
library(rclipboard)
library(shinydashboard)

source("bowtie2_ui.R", local = TRUE)
source("crispr_ui.R", local = TRUE)
source("tooltips.R")

cores <- detectCores()

header <- dashboardHeader(
  title = tags$a(
    href = "http://bowtie-bio.sourceforge.net/bowtie2/index.shtml",
    tags$img(
      src = "bowtie_logo.png",
      height = "40px",
      width = "75%",
      title = "Bowtie 2"
    ),
    style = "padding-left:1px;"
  ),
  tags$li(
    a(
      href = 'http://www.jhu.edu/',
      img(
        src = 'university.small.horizontal.white.png',
        title = "Johns Hopkins University",
        height = "30px"
      ),
      style = "padding-top:10px; padding-bottom:10px;"
    ),
    class = "dropdown"
  )
)

sidebar <- dashboardSidebar(collapsed = TRUE,
  sidebarMenu(
    id = "tabs",
    menuItem(h5("Bowtie 2"), tabName = "bowtie2"),
    menuItem(h5("CRISPR"), tabName = "crispr"),
    menuItem(h5("Help"), tabName = "manual")
  ))


body <- dashboardBody(
  includeCSS("www/style.css"),
  useShinyjs(),
  introjsUI(),
  rclipboardSetup(),

  tabItems(
    tabItem("bowtie2", bowtie2_tab),
    tabItem("crispr", crispr_tab),
    tabItem(
      "manual",
      tags$iframe(style = "position: absolute; height: 100%; border: none", width =
          "100%", src = "MANUAL.html")
    )
  )
)

function(request) {
  dashboardPage(header, sidebar, body)
}
