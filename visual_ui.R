library(shinydashboard)
library(shinyjs)

visuals_tab <- fluidRow(column(
  width = 12,
  box(
    width = NULL,
    tabsetPanel(id = "visualtabs",
      tabPanel(
        "Welcome",
        h4("Welcome to the Visual App!"),
        p(
          "This app is designed
          to help you see"
        )
      )
    )
  )
))
