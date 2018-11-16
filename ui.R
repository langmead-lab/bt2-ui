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
library(rintrojs)
library(parallel)
library(markdown)
library(rclipboard)
library(shinydashboard)

cores <- detectCores()

customDashboardHeader <-
  function(...) {
    items <- list(...)

    tags$header(
      class = "main-header",
      tags$nav(
        class = "navbar navbar-default",
        role = "navigation",
        tags$div(class = "navbar-header",
          tags$button(type="button", class="navbar-toggle", `data-toggle`="collapse", `data-target`="#navbar", `aria-expanded`="true", tags$span(class="icon-bar"), tags$span(class="icon-bar"), tags$span(class="icon-bar")),
          tags$a(
            class = "navbar-brand",
            href = "http://bowtie-bio.sourceforge.net/bowtie2/index.shtml",
            tags$img(
              src = "bowtie_logo.png",
              height = "50px",
              title = "Bowtie 2"
            )
          )
          ),
        tags$div(
          class = "navbar-collapse collapse",
          id = "navbar",
          tags$ul(class = "nav navbar-nav",
            items),
          tags$ul(class = "nav navbar-nav navbar-right",
            tags$li(
              class = "dropdown",
              style = "font-size: 20px",
              tags$a(
                `data-value` =" More",
                `aria-expanded` = "false",
                `data-toggle` = "dropdown",
                class = "dropdown-toggle",
                href = "#",
                icon("github"),
                tags$b(class = "caret")
              ),
              tags$ul(
                class = "dropdown-menu",
                tags$li(
                  tags$a(
                    href = "https://github.com/langmead-lab/bt2-ui/issues",
                    target = "_blank",
                    "UI repo"
                  )
                ),
                tags$li(
                  tags$a(
                    href = "https://github.com/langmead-lab/bt2-ui/issues",
                    target = "_blank",
                    "UI issues"
                  )
                ),
                tags$li(
                  tags$a(
                    href = "https://github.com/BenLangmead/bowtie2",
                    target = "_blank",
                    "Bowtie2 repo"
                  )
                )
              )
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
        )
      )
    )
  }


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
  rclipboardSetup(),
  tags$head(tags$script(src = "init.js")),
  includeCSS("www/style.css"),
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
  menuItem("Bowtie 2", tabName = "bowtie2", selected = TRUE),
  menuItem("CRISPR", tabName = "crispr"),
  menuItem("Manual", tabName = "manual")
)
# 
# customDashboardPage <- function(header, sidebar, body, title) {
#   addDeps <- getFromNamespace("addDeps", "shinydashboard")
#   content <- div(class = "wrapper", header, sidebar, body)
#   addDeps(
#     tags$body(class = "skin-blue sidebar-collapse",
#     style = "min-height: 611px;",
#     shiny::bootstrapPage(content, title = title)))
# }

function(request) {
  
  dashboardPage(header, sidebar, body, title = "bowtie2 UI")
}
