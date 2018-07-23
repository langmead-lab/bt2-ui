#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(parallel)
library(markdown)
library(rclipboard)
library(shinydashboard)

cores <- detectCores()
function(request) {
  dashboardPage(
    dashboardHeader(
      title = tags$a(
        href = "http://bowtie-bio.sourceforge.net/bowtie2/index.shtml",
        tags$img(
          src = "bowtie_logo.png",
          height = "40px",
          width = "75%",
          title = "Bowtie 2"
        ),
        style = "padding-left:1px;"
      ),
      tags$li(
        a(
          href = 'http://www.jhu.edu/',
          img(
            src = 'university.small.horizontal.white.png',
            title = "Johns Hopkins University",
            height = "30px"
          ),
          style = "padding-top:10px; padding-bottom:10px;"
        ),
        class = "dropdown"
      )
    ),
    dashboardSidebar(disable = TRUE),
    dashboardBody(
      useShinyjs(),
      rclipboardSetup(),
      tags$head(
        tags$style(HTML(
          "#markdown { height: auto; overflow-y: scroll; }"
        )),
        tags$head(tags$style(
          "#bt2Options { font-family: courier, consolas; }"
        )),
        tags$style(
          HTML(
            '
            .skin-blue .main-header .logo {
            background-color: #3c8dbc;
            }
            .skin-blue .main-header .logo:hover {
            background-color: #3c8dbc;
            }
            '
          )
          )
          ),
      fluidRow(
        column(
          width = 9,
          box(
            width = NULL,
            solidHeader = TRUE,
            fluidRow(
              column(
                width = 3,
                selectizeInput(
                  "index",
                  label = NULL,
                  options = list(placeholder = "Select Index"),
                  choices = NULL
                )
              ),
              column(
                width = 9,
                conditionalPanel(
                  condition = "input.readsAreSequences && input.paired == 'Paired'",
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
              ),
              column(
                width = 9,
                conditionalPanel(
                  condition = "!input.readsAreSequences && input.paired == 'Paired'",
                  fileInput(
                    "mate1",
                    label = NULL,
                    placeholder = "Select reads for mate 1",
                    multiple = FALSE
                  ),
                  fileInput(
                    "mate2",
                    label = NULL,
                    placeholder = "Select reads for mate 2",
                    multiple = FALSE
                  )
                )
              ),
              conditionalPanel(condition = "input.readsAreSequences && input.paired == 'Unpaired'",
                               column(
                                 width = 9,
                                 textAreaInput(
                                   "unpaired_sequence",
                                   label = NULL,
                                   placeholder = "Enter sequence",
                                   resize = "horizontal"
                                 )
                               )),
              conditionalPanel(condition = "!input.readsAreSequences && input.paired == 'Unpaired'",
                               column(
                                 width = 9,
                                 fileInput(
                                   "unpaired",
                                   label = NULL,
                                   placeholder = "Select unpaired reads",
                                   multiple = FALSE
                                 )
                               ))
            ),
            a(id = "toggleCommand", "Show/hide command"),
            hidden(div(
              id = "cmd_line",
              textAreaInput(
                inputId = "bt2Options",
                label = NULL,
                resize = "vertical"
              ),
              tags$p(uiOutput("clip"))
            )),
            fluidRow(column(width = 6,
              div(style = "display:inline-block", uiOutput("action")),
              div(style = "display:inline-block", bookmarkButton("Bookmark Settings"))
            ))
            # div(style = "display: inline-block;",
            #     actionButton("runAligner", label = "Run Alignment", icon = icon("play"), color = "green"))
          ),
          box(width = NULL,
              tabsetPanel(
                id = "tabs",
                tabPanel("Manual",
                         style = "overflow-y:scroll; max-height: 3000px;",
                         
                         includeMarkdown("MANUAL.markdown"))
              ))
        ),
        column(
          width = 3,
          
          # Input options
          box(
            width = NULL,
            title = "Input",
            status = "warning",
            collapsible = TRUE,
            # -c
            checkboxInput("readsAreSequences", label = "Reads are sequences, not files", value = TRUE),
            selectInput(
              "inputFileFormat",
              label = h5("Input File Format"),
              choices = list(
                "FASTQ" = "-q",
                "FASTA" = "-f",
                "TAB5" = "--tab5",
                "TAB6" = "--tab6",
                "QSEQ" = "--qseq",
                "Raw Input" = "-r",
                "FASTA Continuous" = "-F"
              ),
              selected = "-q"
            ),
            conditionalPanel(
              condition = "input.inputFileFormat == '-F'",
              
              div(style = "display: inline-block;vertical-align:top; width:75px", numericInput(
                inputId = "kmer",
                label = h6("k"),
                value = 0
              )),
              div(style = "display: inline-block;vertical-align:top; width:75px", numericInput(
                inputId = "offset",
                label = h6("i"),
                value = 0
              ))
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
          ),
          
          
          # Alignment options
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
            checkboxInput("noFw", label = "Do not align reverse-compliment version of read"),
            checkboxInput("noRc", label = "Do not align reverse-compliment version of read"),
            checkboxInput("no1MmUpfront", label = "Do not allow 1 mismatch alignments before attempting to scan for the optimal seeded alignments")
          ),
          
          # Scoring options
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
              value = 6
            ),
            numericInput(
              "nPenalty",
              label = h5("Penalty for non-A/C/G/Ts in read/reference"),
              value = 1
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
                label = "Mate alignment",
                choices = list(
                  "fw/rev" = "--fr",
                  "rev/fw" = "--rf",
                  "fw/fw" = "--fr"
                )
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
          box(
            width = NULL,
            title = "Output",
            status = "info",
            collapsible = TRUE,
            checkboxInput("noSq", "Suppress @SQ header lines"),
            checkboxInput("noHead", "suppress header lines, i.e. lines starting with @"),
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
      )
  
  
  # dashboardPage(header,
  #               dashboardSidebar(disable = TRUE),
  #               body)
  }