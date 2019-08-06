library(shinydashboard)
library(shinyjs)
library(plotly)
library(shinycssloaders)

visuals_tab <- fluidPage(
  titlePanel(
    h4("Welcome to the Visual App!"),
    p("This app is designed to help you see what your data looks like.")
  ),
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        id = "selectVisualIndex",
        selectizeInput(
          "index3",
          label = "Bowtie2 Index to be used",
          options = list(placeholder = "Select Index"),
          choices = NULL
        )
      ),
      fluidRow(
        id = "selectSequenceReadArchive",
        textInput("index4", "Sequence Read Archive", "")
      ),
      fluidRow(
        id = "enterNumberOfReads",
        numericInput("readNumber",
                     label = "Stop after first <int> reads",
                     value = 10000)
      ),
      fluidRow(
        actionButton("visualSubmit", label = "Submit")
      ),
      fluidRow(
        conditionalPanel(
          condition = "output.visual_update",
          actionButton("visualUpdate", label = "Next reads"),
          textOutput("lines_processed")
        )
      ),
      br(),
      div(id = "visuals_formatOptions",
          box(
            width = NULL,
            title = "Input Options",
            status = "warning",
            collapsible = TRUE,
            radioButtons(
              inputId = "visuals_typeOfQualityValues",
              label = h5("Type of Quality Values"),
              choices = list(
                "Phred 33" = "--phred33",
                "Phred 64" = "--phred64",
                "Integer Qualities" = "--int-quals"
              ),
              selected = "--phred33",
              inline = FALSE
            ),
            numericInput(
              inputId = "visuals_skip",
              label = h5("skip the first <int> reads/pairs in the input"),
              value = 0,
              min = 0
            ),
            numericInput(
              inputId = "visuals_trim5",
              label = h5("trim <int> bases from 5'/left end of reads"),
              value = 0,
              min = 0
            ),
            numericInput(
              inputId = "visuals_trim3",
              label = h5("trim <int> bases from 3'/right end of reads"),
              value = 0,
              min = 0
            )
          ),
          conditionalPanel(
            condition = TRUE,
            box(
              width = NULL,
              title = "Paired-end",
              collapsible = TRUE,
              collapsed = TRUE,
              numericInput(
                "visuals_minIns",
                label = h5("Minimum fragment length"),
                value = 0
              ),
              numericInput(
                "visuals_maxIns",
                label = h5("Maximum fragment length"),
                value = 500
              ),
              radioButtons(
                "visuals_mateAlign",
                label = h5("Mate alignment"),
                choices = list(
                  "fw/rev" = "--fr",
                  "rev/fw" = "--rf",
                  "fw/fw" = "--ff"
                ),
                selected = "--fr"
              ),
              checkboxInput("visuals_noMixed", "Suppress unpaired alignments for paired reads"),
              checkboxInput(
                "visuals_noDiscordant",
                "Suppress discordant alignments for paired reads"
              ),
              checkboxInput("visuals_doveTail", "Concordant when mates extend past each other"),
              checkboxInput(
                "visuals_noContain",
                "Not concordant when one mate alignment contains other"
              ),
              checkboxInput("visuals_noOverlap", "Not concordant when mates overlap at all")
            )
          )
      )
    ),
    mainPanel(
      conditionalPanel(
        condition = "output.visual_update",
        textOutput("displayError"),
        tabsetPanel(
          tabPanel(
            "Match Scores",
            plotlyOutput("match_score_histogram")
          ),
          tabPanel(
            "Alignment Scores",
            conditionalPanel(condition = "output.display_unpaired",
                             plotlyOutput("boxplot_unpaired")),
            conditionalPanel(condition = "output.display_first",
                             plotlyOutput("boxplot_first")),
            conditionalPanel(condition = "output.display_second",
                             plotlyOutput("boxplot_second"))
          ),
          tabPanel(
            "Matched vs Unmatched Reads",
            plotlyOutput("pieplot")
          ),
          tabPanel(
            "TLEN",
            conditionalPanel(condition = "output.display_tlen",
                             plotlyOutput("tlen_histogram"))
          ),
          tabPanel(
            "Alignment Summary",
            conditionalPanel(condition = "output.display_summary",
                             plotlyOutput("alignment_pieplot"))
          ),
          tabPanel(
            "MAPQ Scores",
            conditionalPanel(condition = "output.display_mapq",
                             plotlyOutput("mapq_histogram"))
          ),
          conditionalPanel(condition = "output.visual_update",
                           downloadButton("bt2DownloadSAM2", "Download Sam File"))
        )
      )
    )
  )
)


# visuals_tab <- fluidRow(column(
#   width = 12,
#   box(
#     width = NULL,
#     solidHeader = TRUE,
#     fluidRow(
#       column(width = 4,
#              div(
#                id = "selectVisualIndex",
#                selectizeInput(
#                  "index3",
#                  label = "Bowtie2 Index to be used",
#                  options = list(placeholder = "Select Index"),
#                  choices = NULL
#                )
#              )),
#       column(width = 4,
#              div(
#                id = "selectSequenceReadArchive",
#                textInput("index4", "Sequence Read Archive", "")
#              )),
#       column(width = 4,
#              div(
#                id = "enterNumberOfReads",
#                numericInput("readNumber",
#                             label = "Number of Read to be Processed",
#                             value = 10000)
#              ))
#     ),
#     fluidRow(
#       column(
#         width = 4,
#         textOutput(""),
#         actionButton("visualSubmit", label = "Submit")
#       ),
#       column(
#         width = 4,
#         conditionalPanel(
#           condition = "output.visual_update",
#           actionButton("visualUpdate", label = "Next reads"),
#           textOutput("lines_processed")
#         )
#       )
#     )
#   ),
#   box(
#     width = NULL,
#     solidHeader = TRUE,
#     box(width = NULL,
#         tabsetPanel(id = "visualtabs",
#                     tabPanel(
#                       "Welcome",
#                       h4("Welcome to the Visual App!"),
#                       p("This app is designed
#           to help you see what your data looks like.")
#                     ))),
#     box(
#       id = "visual_graphs",
#       width = NULL,
#       textOutput("displayError"),
#       plotlyOutput("match_score_histogram"),
#       plotlyOutput("boxplot_unpaired"),
#       plotlyOutput("boxplot_first"),
#       plotlyOutput("boxplot_second"),
#       plotlyOutput("pieplot"),
#       plotlyOutput("tlen_histogram"),
#       downloadButton("bt2DownloadSAM2", "Download Sam File")
#     )
#   )
# ))
