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
            label = NULL,
            options = list(placeholder = "Select Index"),
            choices = NULL
          ))
    ),
    column(
      width = 4,
      div(id = "selectSequenceReadArchive",
          # selectizeInput(
          #   "index4",
          #   label = NULL,
          #   options = list(placeholder = "Select Run Accession"),
          #   choices = NULL)
          textInput("index4", "Sequence Read Archive", "")
          )
    ),
    column(
      width = 4,
      div(id = "enterNumberOfReads",
          numericInput(
            "readNumber",
            label = NULL,
            value = 10000
          )
      ))
    ),
    actionButton("visualSubmit", label = "Submit")
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
      width = NULL,
      textOutput("try"),
      textOutput("try2"),
      textOutput("try3"),
      withSpinner(plotlyOutput("histogram")),
      br(),
      withSpinner(plotlyOutput("boxplot")),
      br(),
      downloadButton("bt2DownloadSAM2", "Download"),
      withSpinner(plotlyOutput("pieplot"))
    )
  )))