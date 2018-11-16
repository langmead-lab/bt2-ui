library(shinydashboard)
library(shinyjs)

crispr_tab <- fluidRow(column(
  width = 12,
  box(
    width = NULL,
    solidHeader = TRUE,
    fluidRow(column(
      width = 6,
      div(id = "selectCrisprIndex",
        selectizeInput(
          "index2",
          label = NULL,
          options = list(placeholder = "Select Index"),
          choices = NULL
        ))
    )),
    div(id = "fastaContinuousOptions",
      fluidRow(
        column(width = 6, numericInput(
          "kmer",
          h5("Select kmer size"),
          min = 10,
          value = 20
        )),
        column(width = 6, numericInput(
          "offset",
          h5("Interval between k-mers"),
          min = 1,
          value = 1
        )))
    ),
    hidden(
      radioButtons(
        inputId = "crisprInput",
        label = NULL,
        choices = list("Sequence" = "sequence", "FASTA File" = "fasta_file"),
        selected = "sequence",
        inline = TRUE
      )
    ),
    conditionalPanel(
      condition = "input.crisprInput == 'sequence'",
      div(id = "crisprSeqenceWidget",
        textAreaInput(
          "crisprSequence",
          label = h5("Enter sequence"),
          resize = "vertical"
        ))
    ),
    conditionalPanel(
      condition = "input.crisprInput == 'fasta_file'",
      fileInput(
        "crisprFile",
        label = NULL,
        placeholder = "Select FASTA",
        multiple = FALSE
      )
    ),
    actionButton("crisprSubmit", label = "Submit")
  ),
  uiOutput("kmer_alignments"),
  box(
    width = NULL,
    tabsetPanel(id = "crisprtabs",
      tabPanel(
        "Welcome",
        h4("Welcome to the CRISPR App!"),
        p(
          "This app is designed
          to help you study the substrings (k-mers) in a given \"target\"
          sequence and how they align to the overall reference genome.  k-mers
          that align fewer times (i.e. more uniquely) may be better candidates
          for CRISPR guide RNAs or primers, for example.  Is this useful to
          you?  We are eager for feedback.  Please click the GitHub icon
          toward the upper-right to go to the repo and request features and
          report feedback and issues."
        ),
        p("Click the tutorial button below to get started"),
        bsButton("crisprtutorial", label = "Get Started", style = "success")
      )),
    absolutePanel(
      id = "crisprpanel",
      top = 0,
      right = 0,
      hidden(
        div(
          id = "crisprcontrols",
          style = "padding: 10px;",
          div(
            id = "kmerFilterWidget",
            style = "display: inline-block;vertical-align:top; width: 300px;",
            selectizeInput(
              "kmer_filter",
              label = NULL,
              choices = NULL,
              options = list(
                placeholder = "Filter by kmer",
                onInitialize = I('function() { this.setValue(""); }')
              )
            )
          ),
          downloadButton("crisprDownloadSAM", "Download"),
          actionButton("crisprToggleHighlight",
            "Toggle Highlight",
            icon = icon("palette"))
        )
      )
    )
  ),
  bsAlert("alert")
))
