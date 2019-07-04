library(shinydashboard)
library(shinyjs)
library(plotly)

visuals_tab <- fluidRow(column(
  width = 12,
  box(
    width = NULL,
    solidHeader = TRUE,
    fluidRow(column(
      width = 6,
      div(id = "selectVisualIndex",
        selectizeInput(
          "index3",
          label = NULL,
          options = list(placeholder = "Select Index"),
          choices = NULL
        ))
    ),
    column(
      width = 6,
      div(id = "visualSamFile",
      fileInput(
        "samFile",
        label = NULL,
        placeholder = "Select sam File",
        accept = c(
          ".sam"
        ),
        multiple = FALSE
      )
      )
    )
  ),
  actionButton("visualSubmit", label = "Submit")
),
box(
  width = NULL,
  solidHeader = TRUE,
  fluidRow(column(
    width = 6,
    div(id = "selectSequenceReadArchive",
      selectizeInput(
        "index4",
        label = NULL,
        options = list(placeholder = "Select Run Accession"),
        choices = NULL
      ))
  ),
  column(
    width = 6,
    div(id = "runAccession",
    textInput(
      "runAccession",
      label = NULL,
      placeholder = "Select Run Accession ID"
    ))
  ),
actionButton("visualAccession", label = "Kowalski Analysis")
),
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
  textOutput("noFile"),
  plotlyOutput("histogram"),
  br(),
  plotlyOutput("boxplot"),
  br(),
  plotlyOutput("pieplot")
)
)))
