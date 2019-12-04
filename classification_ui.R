library(shinydashboard)
library(shinyjs)
library(plotly)

classification_tab <- fluidPage(
  titlePanel("Welcome to the Classification App!"),
  sidebarLayout(
    sidebarPanel(
      p("This app is designed to help you help classify your accessions"),
      fluidRow(
        id = "selectClassificationIndex",
        selectizeInput(
          #This needs to be changed so its only human chromosomes
          "index3",
          label = "Bowtie2 Index to be used",
          options = list(placeholder = "Select Index"),
          choices = NULL
        )
      ),
      fluidRow(
        id = "sraAccessionClassification",
        textInput("index5", "Sequence Read Archive", "")
      ),
      fluidRow(
        bsButton(
          "classificationSubmit",
          "Submit",
          stype = "primary",
          icon = icon("play")
        )
      )
    ),
    mainPanel(
      textOutput("This is where the graphs will go")
    )
  )
)
