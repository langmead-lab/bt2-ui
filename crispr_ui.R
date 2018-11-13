library(shinydashboard)
library(shinyjs)

crispr_tab <- fluidRow(column(
  width = 12,
  box(
    width = NULL,
    solidHeader = TRUE,
    fluidRow(column(
      width = 6,
      selectizeInput(
        "index2",
        label = NULL,
        options = list(placeholder = "Select Index"),
        choices = NULL
      )
    )),
    fluidRow(
      column(width = 6, numericInput(
        "kmer",
        h5("Select kmer size"),
        min = 1,
        value = 20
      )),
      column(width = 6, numericInput(
        "offset",
        h5("Interval between k-mers"),
        min = 0,
        value = 0
      ))
    ),
    radioButtons(
      inputId = "crisprInput",
      label = NULL,
      choices = list("Sequence" = "sequence", "FASTA File" = "fasta_file"),
      selected = "sequence",
      inline = TRUE
    ),
    conditionalPanel(
      condition = "input.crisprInput == 'sequence'",
      textAreaInput("crisprSequence", label = NULL, resize = "vertical")
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
  box(width = NULL,
    tabsetPanel(id = "crisprtabs",
      tabPanel(
        "Welcome",
        h4("Welcome to the CRISPR!"),
        p("To get started:", tags$li("Pick a reference genome"),
          tags$li("paste a \"target\" sequence into the box above; we will be examining the k-mers making up this sequence and how they align to the genome"),
          tags$li("choose a k-mer size and interval"))
      )),
    absolutePanel(
      id = "crisprpanel",
      top = 0,
      right = 0,
      hidden(div(
        id = "crisprcontrols",
        style = "padding: 10px;",
        div(style="display: inline-block;vertical-align:top; width: 300px;", selectizeInput("kmer_filter", label = NULL,  choices = NULL, options = list(placeholder = "Filter by kmer", onInitialize = I('function() { this.setValue(""); }')))),
        downloadButton("crisprDownloadSAM", "Download"),
        actionButton(
          "crisprToggleHighlight",
          "Toggle Highlight",
          icon = icon("palette")
        )
      )
    ))),
  bsAlert("alert")
))
