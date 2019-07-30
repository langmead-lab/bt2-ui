library(shinydashboard)
library(shinyjs)
library(plotly)
library(shinycssloaders)

visuals_tab <- fluidRow(column(
  width = 12,
  box(
    width = NULL,
    solidHeader = TRUE,
    fluidRow(column(
      width = 4,
      div(id = "selectVisualIndex",
          selectizeInput(
            "index3",
            label = "Bowtie2 Index to be used",
            options = list(placeholder = "Select Index"),
            choices = NULL
          ))
    ),
    column(
      width = 4,
      div(id = "selectSequenceReadArchive",
          textInput("index4", "Sequence Read Archive", "")
          )
    ),
    column(
      width = 4,
      div(id = "enterNumberOfReads",
          numericInput(
            "readNumber",
            label = "Number of Read to be Processed",
            value = 10000
          )
      ))
    ),
    fluidRow(column(
      width = 4,
      textOutput(""),
      actionButton("visualSubmit", label = "Submit")),
      column(
        width = 4,
        conditionalPanel(condition = "output.visual_update",
          actionButton("visualUpdate", label = "Next reads"),
          textOutput("lines_processed"))))
  ),
  box(
    width = NULL,
    solidHeader = TRUE,
    box(
      width = NULL,
      tabsetPanel(id = "visualtabs",
                  tabPanel(
                    "Welcome",
                    h4("Welcome to the Visual App!"),
                    p(
                      "This app is designed
          to help you see what your data looks like."
                    )
                  )
      )
    ),
    box(
      id = "visual_graphs",
      width = NULL,
      textOutput("displayError"),
      plotlyOutput("match_score_histogram"),
      plotlyOutput("boxplot_unpaired"),
      plotlyOutput("boxplot_first"),
      plotlyOutput("boxplot_second"),
      plotlyOutput("pieplot"),
      plotlyOutput("tlen_histogram"),
      downloadButton("bt2DownloadSAM2", "Download Sam File")
    )
  )))
