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
library(shinydashboard)

source("bowtie2_ui.R", local = TRUE)
source("crispr_ui.R", local = TRUE)
source("tooltips.R")

cores <- detectCores()

customDashboardHeader <-
  function(...,
    title = NULL,
    disable = FALSE,
    .list = NULL) {
    items <- c(list(...), .list)
    custom_css <- NULL

    tags$header(
      class = "main-header",
      custom_css,
      style = if (disable)
        "display: none;",
      span(class = "logo", title),
      tags$nav(
        class = "navbar navbar-static-top",
        role = "navigation",
        tags$ul(class = "nav navbar-nav",
          items)
      )
    )
  }


# header <- dashboardHeader(
#   title = tags$a(
#     href = "http://bowtie-bio.sourceforge.net/bowtie2/index.shtml",
#     tags$img(
#       src = "bowtie_logo.png",
#       height = "40px",
#       width = "75%",
#       title = "Bowtie 2"
#     ),
#     style = "padding-left:1px;"
#   ),
#   tags$li(
#     a(
#       href = 'http://www.jhu.edu/',
#       img(
#         src = 'university.small.horizontal.white.png',
#         title = "Johns Hopkins University",
#         height = "30px"
#       ),
#       style = "padding-top:10px; padding-bottom:10px;"
#     ),
#     class = "dropdown"
#   )
# )

sidebar <- dashboardSidebar(collapsed = TRUE,
  sidebarMenu(
    id = "tabs",
    menuItem(h5("Bowtie 2"), tabName = "bowtie2"),
    menuItem(h5("CRISPR"), tabName = "crispr"),
    menuItem(h5("Help"), tabName = "manual")
  ))


body <- dashboardBody(
  tags$head(tags$script(src = "init.js")),
  includeCSS("www/style.css"),
  # includeScript("www/script.js"),
  useShinyjs(),
  introjsUI(),

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

header <- customDashboardHeader(
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
  menuItem("Bowtie 2", tabName = "bowtie2", selected = TRUE),
  menuItem("CRISPR", tabName = "crispr"),
  menuItem("Manual", tabName = "manual"),
  tags$li(
    style = "position: absolute; right: 0px;",
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
  ),
  tags$li(
    style = "position: absolute; right: 180px; font-size: 20px",
    tags$a(
      href = "https://github.com/langmead-lab/bt2-ui",
      target = "_blank",
      icon("github"),
      tags$span()
    )
  )
)

function(request) {
  dashboardPage(header, sidebar, body)
}
