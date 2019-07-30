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
    actionButton("visualSubmit", label = "Submit"),
    conditionalPanel(condition = "output.visual_update",
      actionButton("visualUpdate", label = paste0("Next ", read_count," reads")))
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
      plotlyOutput("histogram"),
      br(),
      plotlyOutput("boxplot"),
      br(),
      plotlyOutput("pieplot"),
      downloadButton("bt2DownloadSAM2", "Download Sam File")
    )
  )))
