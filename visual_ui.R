library(shinydashboard)
library(shinyjs)

visuals_tab <- fluidRow(column(
  width = 12,
  box(
    width = NULL,
    solidHeader = TRUE,
    fluidRow(column(
      width = 6,
      div(id = "selectVisualIndex",
        selectizeInput(
          "index2",
          label = NULL,
          options = list(placeholder = "Select Index"),
          choices = NULL
        ))
    ))),
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
  )
))
