library(shiny)
library(shinyjs)
library(shinyBS)
library(shinydashboard)

bowtie2_tab <- fluidRow(
  column(
    width = 9,
    box(
      width = NULL,
      solidHeader = TRUE,
      fluidRow(
        column(
          width = 4,
          div(id = "indexSelect",
            selectizeInput(
              "index",
              label = NULL,
              options = list(placeholder = "Select Index"),
              choices = NULL
            ))
        ),
        column(
          width = 8,
          conditionalPanel(
            condition = "input.readsAreSequences && input.paired == 'Paired'",
            div(
              id = "pairedInputSequence",
              textAreaInput(
                "mate1_sequence",
                label = NULL,
                placeholder = "Enter mate 1 sequence",
                resize = "vertical"
              ),
              textAreaInput(
                "mate2_sequence",
                label = NULL,
                placeholder = "Enter mate 2 sequence",
                resize = "vertical"
              )
            )
          )
        ),
        column(
          width = 8,
          conditionalPanel(
            condition = "!input.readsAreSequences && input.paired == 'Paired'",
            div(id = "pairedInputFile",
              fileInput(
                "mate1",
                label = NULL,
                placeholder = "Select reads for mate 1",
                accept = c(
                  "text/plain",
                  ".fa",
                  ".fq"
                ),
                multiple = FALSE
              ),
              fileInput(
                "mate2",
                label = NULL,
                placeholder = "Select reads for mate 2",
                accept = c(
                  "text/plain",
                  ".fa",
                  ".fq"
                ),
                multiple = FALSE
              )
            )
          )
        ),
        conditionalPanel(condition = "input.readsAreSequences && input.paired == 'Unpaired'",
          column(
            width = 8,
            div(
              id = "unpairedInputSequence",
              textAreaInput(
                "unpaired_sequence",
                label = NULL,
                placeholder = "Enter sequence",
                resize = "horizontal"
              )
            )
          )),
        conditionalPanel(condition = "!input.readsAreSequences && input.paired == 'Unpaired'",
          column(
            width = 8,
            div(
              id = "unpairedInputFile",
              fileInput(
                "unpaired",
                label = NULL,
                placeholder = "Select unpaired reads",
                accept = c(
                  "text/plain",
                  ".fa",
                  ".fq"
                ),
                multiple = FALSE
              )
            )
          ))
      ),
      a(id = "toggleCommand", "Show command"),
      hidden(div(
        id = "cmd_line",
        textAreaInput(
          inputId = "bt2Options",
          label = NULL,
          resize = "vertical"
        )
      )),
      fluidRow(column(12,
        div(
          style = "display:inline-block",
          bsButton("submit",
            "Submit Query",
            style = "primary",
            icon = icon("play"))
        ),
        div(
          style = "display:inline-block",
          hidden(uiOutput("clip"))
        )
      ))
      # div(style = "display: inline-block;",
      #     actionButton("runAligner", label = "Run Alignment", icon = icon("play"), color = "green"))
    ),
    box(width = NULL,
      tabsetPanel(
        id = "bowtie2tabs",
        tabPanel(
          "Welcome",
          h4("Welcome to the Bowtie 2 UI!"),
          p(
            "This is our first attempt at a web interface for the Bowtie family
            of aligners.  Is this useful to you?  Do you see the reference
            genomes that are important to you?  Is the so-called \"CRISPR\" app
            useful to you?  Would other apps be useful?  We are eager for
            feedback.  Please click the GitHub icon toward the upper-right to
            go to the repo and request features and report feedback and issues."
          ),
          h5("What is Bowtie2?"),
          p(
            tags$b("Bowtie 2"),
            "is an ultrafast, memory-efficient short read aligner.
            It aligns short DNA sequences (reads) to the human genome
            at a rate of over 25 million 35-bp reads per hour.
            Bowtie indexes the genome with an FM index to keep its
            memory footprint small: typically about 2.2 GB for the
            human genome (2.9 GB for paired-end)."
          ),
          p("Click the tutorial button below to get started"),

          bsButton("tutorial", label = "Get Started", style = "success")
        )
      ), absolutePanel(
        id = "bowtie2panel",
        top = 0,
        right = 0,
        hidden(div(
          id = "bowtie2controls",
          style = "padding: 10px;",
          downloadButton("bt2DownloadSAM", "Download"),
          actionButton(
            "bt2ToggleHighlight",
            "Toggle Highlight",
            icon = icon("palette")
          )
        )
      ))),
    bsAlert("alert")
  ),
  column(
    width = 3,

    # Input options
    div(id = "formatOptions",
      box(
        width = NULL,
        title = "Input",
        status = "warning",
        collapsible = TRUE,
        # -c
        checkboxInput("readsAreSequences", label = "Reads are sequences, not files"),
        selectInput(
          "inputFileFormat",
          label = h5("Input File Format"),
          choices = list(
            "FASTQ" = "-q",
            "FASTA" = "-f"
            # temporarily disabled
            # "TAB5" = "--tab5",
            # "TAB6" = "--tab6",
            # "QSEQ" = "--qseq"
          ),
          selected = "-q"
        ),
        radioButtons(
          inputId = "paired",
          label = NULL,
          choices = list("Paired", "Unpaired"),
          selected = "Paired",
          inline = TRUE
        ),
        radioButtons(
          inputId = "typeOfQualityValues",
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
          inputId = "skip",
          label = h5("skip the first <int> reads/pairs in the input"),
          value = 0,
          min = 0
        ),
        numericInput(
          inputId = "upto",
          label = h5("stop after first <int> reads/pairs"),
          value = 50,
          min = 0,
          max = 500
        ),
        numericInput(
          inputId = "trim5",
          label = h5("trim <int> bases from 5'/left end of reads"),
          value = 0,
          min = 0
        ),
        numericInput(
          inputId = "trim3",
          label = h5("trim <int> bases from 3'/right end of reads"),
          value = 0,
          min = 0
        )
      )
    ),


    # Alignment options
    div(id = "alnAlgOptions",
      box(
        width = NULL,
        title = "Alignment",
        status = "success",
        collapsible = TRUE,
        radioButtons(
          inputId = "alignmentType",
          label = NULL,
          choices = list("End-to-end" = "--end-to-end", "Local" = "--local"),
          selected = "--end-to-end",
          inline = TRUE
        ),
        conditionalPanel(
          condition = "input.alignmentType == '--end-to-end'",
          radioButtons(
            inputId = "endToEndPresets",
            label = NULL,
            choices = list(
              "Very fast" = "--very-fast",
              "Fast" = "--fast",
              "Sensitive" = "--sensitive",
              "Very sensitive" = "--very-sensitive"
            ),
            selected = "--sensitive"
          )
        ),
        conditionalPanel(
          condition = "input.alignmentType == '--local'",
          radioButtons(
            inputId = "localPresets",
            label = NULL,
            choices = list(
              "Very fast" = "--very-fast-local",
              "Fast" = "--fast-local",
              "Sensitive" = "--sensitive-local",
              "Very sensitive" = "--very-sensitive-local"
            ),
            selected = "--sensitive-local"
          )
        ),
        sliderInput(
          "seedLen",
          label = h5("Seed Length"),
          min = 4,
          max = 31,
          value = 22
        ),
        textInput(
          "interval",
          label = h5("Interval between seed substrings w/r/t read length"),
          value = "S,1,1.15"
        ),
        textInput(
          "nCeil",
          label = h5("func for max # non-A/C/G/Ts permitted in aln"),
          value = "L,0,0.15"
        ),
        numericInput(
          "maxMM",
          label = h5("Max # of mismatches in seed alignment"),
          value = 0,
          min = 0,
          max = 1
        ),
        numericInput(
          "dPad",
          label = h5("Extra ref chars to include on sides of DP table"),
          value = 15
        ),
        numericInput(
          "gBar",
          label = h5("Disallow gaps within <int> nucleotides of read extremes"),
          value = 4
        ),

        checkboxInput("ignoreQuals", label = "Treat all quality values as 30 on Phred scale"),
        checkboxInput("noFw", label = "Do not align forward (original) version of read"),
        checkboxInput("noRc", label = "Do not align reverse-compliment version of read"),
        checkboxInput("no1MmUpfront", label = "Do not allow 1 mismatch alignments before attempting to scan for the optimal seeded alignments")
      )
    ),

    # Scoring options
    div(id = "scoringFuncOptions",
      box(
        width = NULL,
        title = "Scoring",
        status = "primary",
        collapsible = TRUE,
        conditionalPanel(
          condition = "input.alignmentType == '--end-to-end'",
          numericInput(
            "matchBonus",
            label = h5("Match bonus"),
            min = 0,
            value = 0
          ),
          textInput(
            "scoreMin",
            label = h5("Min acceptable alignment score w/r/t read length"),
            value = "L,-0.6,-0.6"
          )
        ),
        conditionalPanel(
          condition = "input.alignmentType == '--local'",
          numericInput(
            "matchBonus",
            label = h5("Match bonus"),
            min = 0,
            value = 2
          ),
          textInput(
            "scoreMin",
            label = h5("Min acceptable alignment score w/r/t read length"),
            value = "G,20,8"
          )
        ),
        numericInput(
          "maxPenalty",
          label = h5("Max penalty for mismatch; lower quality = lower penalty"),
          min = 0,
          value = 6
        ),
        numericInput(
          "nPenalty",
          label = h5("Penalty for non-A/C/G/Ts in read/reference"),
          value = 1
        )
      )
    ),

    # Reporting
    # box(width = NULL, title = "Reporting", collapsible = TRUE, collapsed = TRUE,
    #   radioButtons(inputId = "reporting", label = NULL,
    #                choices = list("Default" = "", "Report up to "))
    # ),

    # Effort
    box(
      width = NULL,
      title = "Effort",
      collapsible = TRUE,
      collapsed = TRUE,
      numericInput(
        "extendAttempts",
        label = h5("Give up extending after <int> failed extends in a row"),
        value = 15
      ),
      numericInput(
        "seedCount",
        label = h5("For reads w/ repetitive seeds, try <int> sets of seeds"),
        value = 2
      )
    ),
    conditionalPanel(
      condition = "input.paired == 'Paired'",
      box(
        width = NULL,
        title = "Paired-end",
        collapsible = TRUE,
        collapsed = TRUE,
        numericInput(
          "minIns",
          label = h5("Minimum fragment length"),
          value = 0
        ),
        numericInput(
          "maxIns",
          label = h5("Maximum fragment length"),
          value = 500
        ),
        radioButtons(
          "mateAlign",
          label = h5("Mate alignment"),
          choices = list(
            "fw/rev" = "--fr",
            "rev/fw" = "--rf",
            "fw/fw" = "--ff"
          ),
          selected = "--fr"
        ),
        checkboxInput("noMixed", "Suppress unpaired alignments for paired reads"),
        checkboxInput(
          "noDiscordant",
          "Suppress discordant alignments for paired reads"
        ),
        checkboxInput("doveTail", "Concordant when mates extend past each other"),
        checkboxInput(
          "noContain",
          "Not concordant when one mate alignment contains other"
        ),
        checkboxInput("noOverlap", "Not concordant when mates overlap at all")
      )
    ),

    # Output options
    div(id = "outputOptions",
      box(
        width = NULL,
        title = "Output",
        status = "info",
        collapsible = TRUE,
        checkboxInput(
          "omitSecSeq",
          "Put '*' in SEQ and QUAL fields for secondary alignments"
        ),
        checkboxInput(
          "samNoQnameTrunc",
          "Suppress standard behaviour of truncating read name at first whitespace at the expense of generating non-standard SAM"
        ),
        checkboxInput(
          "xEq",
          "Use =/X, instead of M, to specify matches/mismatches in SAM record"
        ),
        checkboxInput(
          "softClippedUnmappedTlen",
          "Exclude soft-clipped bases when reporting TLEN"
        )
      )
    )
  )
)
