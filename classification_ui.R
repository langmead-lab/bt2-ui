library(shinydashboard)
library(shinyjs)
library(plotly)

classification_tab <- fluidPage(
  titlePanel("Welcome to the Classification App!"),
  sidebarLayout(
    sidebarPanel(
      p("This app is designed to help you help classify your accessions. We are using data for GRCh38, please us an accession that matches in order to get useful information."),
      fluidRow(
        id = "sraAccessionClassification",
        textInput("index5", "Sequence Read Archive", "")
      ),
      fluidRow(
        p("Compare your accession to our dataset"),
        selectInput(
          "index6",
          "Feature you want on the x axis",
          c("Gene Annotation Percent", "Average Read Length", "Read Frequency", "Possition Differece STD", "Possition Difference Mean", "Number of Chromosomes", "Largest Position Difference", "Smallest Position Difference", "Percent A", "Percent C", "Percent G", "Percent T"),
          selected = "Gene Annotation Percent"
        ),
        selectInput(
          "index7",
          "Feature you want on the y axis",
          c("Gene Annotation Percent", "Average Read Length", "Read Frequency", "Possition Differece STD", "Possition Difference Mean", "Number of Chromosomes", "Largest Position Difference", "Smallest Position Difference", "Percent A", "Percent C", "Percent G", "Percent T"),
          selected = "Average Read Length"
        )
      ),
      fluidRow(
        bsButton(
          "comparisonSubmit",
          "Classify and Compare",
          stype = "primary",
          icon = icon("play")
        )
      )
    ),
    mainPanel(
      textOutput("classificationPrediction"),
      textOutput("classificationError"),
      conditionalPanel(
        condition = "output.classification_update === true",
        p("This is our confidence rating for your accesssion")
      ),
      conditionalPanel(
        condition = "output.comparison_update",
        plotlyOutput("classifcation_data_scatter")
      )
    )
  )
)
