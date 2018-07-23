#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(stringr)
library(shinyjs)
library(processx)
library(rclipboard)
library(reticulate)
library(magrittr)

# use_virtualenv("r-reticulate")
use_python("/usr/bin/python")

shinyServer(function(input, output, session) {
  socket <- NULL
  bowtie2_process <- NULL
  
  rclipboardSetup()
  disable("bt2Options")
  onclick("toggleCommand", toggle(id = "cmd_line", anim = TRUE))
  
  session$onSessionEnded(function() {
    if (!is.null(bowtie2_process)) {
      bowtie2_process$kill()
    }
    if (!is.null(socket)) {
      # close.socket(socket)
      close(socket)
    }
  })
  
  # if (!is_bowtie2_running()) {
  #   removeUI("submit")
  #   output$action <- renderUI({
  #     actionButton("startBowtie2", label = "Start Bowtie2", icon = icon("flash"))
  #   })
  # } else {
  #   removeUI("startBowtie2")
  #   output$action <- renderUI({
  #     actionButton("submit", label = "Run alignment", icon = icon("play"))
  #   })
  # }
  autoInvalidate <- reactiveTimer(1000)
  
  output$action <- renderUI({
    autoInvalidate()
    if (!is_bowtie2_running()) {
      removeUI("submit")
      actionButton("startBowtie2",
                   label = "Start Bowtie2",
                   icon = icon("flash"))
    } else {
      removeUI("startBowtie2")
      actionButton("submit", label = "Run alignment", icon = icon("play"))
    }
  })
  
  observeEvent(input$startBowtie2, {
    run_bowtie2()
    showNotification(
      paste("Bowtie2 is now running on port 22000"),
      duration = 2,
      type = "message"
    )
  })
  
  observeEvent(input$nCeil, {
    update_command_line(session, "--n-ceil", input$nCeil, default = 15)
  })
  
  observeEvent(input$dPad, {
    update_command_line(session, "--dpad", input$dPad, default = 15)
  })
  
  observeEvent(input$gBar, {
    update_command_line(session, "--gbar", input$gBar, default = 4)
  })
  
  observeEvent(input$interval, {
    interval <- str_remove(input$interval, "\\s")
    default <- "S,1,1.15"
    if (interval == "")
      interval <- default
    updateTextInput(session, inputId = "interval", value = interval)
    update_command_line(session, "-i", interval, default = default)
  })
  
  observeEvent(input$nCeil, {
    nCeil <- str_remove(input$nCeil, "\\s")
    default <- "L,0,0.15"
    if (nCeil == "") {
      nCeil <- default
    }
    updateTextInput(session, inputId = "nCeil", value = nCeil)
    update_command_line(session, "--n-ceil", nCeil, default = default)
  })
  
  observeEvent(input$scoreMin, {
    scoreMin <- str_remove(input$scoreMin, "\\s")
    if (input$alignmentType == "--end-to-end") {
      default <- "G,20,8"
    } else {
      default <- " L,-0.6,-0.6"
    }
    if (scoreMin == "") {
      scoreMin <- default
    }
    updateTextInput(session, inputId = scoreMin, value = scoreMin)
    update_command_line(session, "--score-min", scoreMin, default = default)
  })
  
  observeEvent(input$ignoreQuals, {
    update_command_line(session, "--ignore-quals", input$ignoreQuals, default = FALSE)
  })
  
  observeEvent(input$noFw, {
    update_command_line(session, "--nofw", input$noFw, default = FALSE)
  })
  
  observeEvent(input$noRc, {
    update_command_line(session, "--norc", input$noRc, default = FALSE)
  })
  
  observeEvent(input$no1MmUpfront, {
    update_command_line(session, "--no-1mm-upfront", input$no1MmUpfront, default = FALSE)
  })
  
  observeEvent(input$alignmentType, {
    if (input$alignmentType == "--end-to-end")
      update_command_line(
        session,
        "--end-to-end",
        input$alignmentType,
        default = "--end-to-end",
        mutually_exclusive_options = c("--local")
      )
    else
      update_command_line(
        session,
        "--local",
        input$alignmentType,
        default = "--end-to-end",
        mutually_exclusive_options = c("--end-to-end")
      )
  })
  
  observeEvent(input$matchBonus, {
    if (input$alignmentType == "--end-to-end")
      update_command_line(session, "--ma", input$maxPenalty, default = 0)
    else
      update_command_line(session, "--ma", input$maxPenalty, default = 2)
  })
  
  observeEvent(input$maxPenality, {
    update_command_line(session, "--mp", input$maxPenalty, default = 6)
  })
  
  observeEvent(input$nPenalty, {
    update_command_line(session, "--np", input$nPenalty, default = 1)
  })
  
  # observeEvent(input$inputFileFormat, {
  #   cmd_line <- isolate(input$bt2Options)
  #   update_command_line(session, input$inputFileFormat, TRUE)
  # })
  
  observeEvent(input$skip, {
    update_command_line(session, "--skip", input$skip, default = 0)
  })
  
  observeEvent(input$upto, {
    update_command_line(session, "--upto", input$upto, default = 500)
  })
  
  observeEvent(input$trim5, {
    update_command_line(session, "--trim5", input$trim5, default = 0)
  })
  
  observeEvent(input$trim3, {
    update_command_line(session, "--trim3", input$trim3, default = 0)
  })
  
  observeEvent(input$inputFileFormat, {
    mutually_exclusive_options <-
      c("-q", "-f", "--tab5", "--tab6", "--qseq", "-r", "-F")
    mutually_exclusive_options <-
      setdiff(mutually_exclusive_options, input$inputFileFormat)
    update_command_line(
      session,
      input$inputFileFormat,
      input$inputFileFormat,
      default = "-q",
      mutually_exclusive_options = mutually_exclusive_options
    )
  })
  
  observeEvent(input$typeOfQualityValues, {
    mutually_exclusive_options <-
      c("--phred33", "--phred64", "--int-quals")
    mutually_exclusive_options <-
      setdiff(mutually_exclusive_options, input$typeOfQualityValues)
    update_command_line(
      session,
      input$typeOfQualityValues,
      input$typeOfQualityValues,
      default = "--phred33",
      mutually_exclusive_options = mutually_exclusive_options
    )
  })
  
  observeEvent(input$seedLen, {
    update_command_line(session, "-L", input$seedLen, default = 22)
  })
  
  observeEvent(input$maxMM, {
    update_command_line(session, "-N", input$maxMM, default = 0)
  })
  
  observeEvent(input$localPresets, {
    mutually_exclusive_options <-
      mutually_exclusive_options <-
      c(
        "--very-fast",
        "--fast",
        "--sensitive",
        "--very-sensitive",
        "--very-fast-local",
        "--fast-local",
        "--sensitive-local",
        "--very-sensitive-local"
      )
    mutually_exclusive_options <-
      setdiff(mutually_exclusive_options, input$localPresets)
    update_command_line(
      session,
      input$localPresets,
      input$localPresets,
      default = "--sensitive-local",
      mutually_exclusive_options = mutually_exclusive_options
    )
  })
  
  observeEvent(input$endToEndPresets, {
    mutually_exclusive_options <-
      c(
        "--very-fast",
        "--fast",
        "--sensitive",
        "--very-sensitive",
        "--very-fast-local",
        "--fast-local",
        "--sensitive-local",
        "--very-sensitive-local"
      )
    mutually_exclusive_options <-
      setdiff(mutually_exclusive_options, input$endToEndPresets)
    update_command_line(
      session,
      input$endToEndPresets,
      input$endToEndPresets,
      default = "--sensitive",
      mutually_exclusive_options = mutually_exclusive_options
    )
  })
  
  observe({
    choices <- c("e_coli", "lambda_virus")
    updateSelectizeInput(
      session,
      "index",
      server = TRUE,
      choices = choices,
      selected = NULL
    )
  })
  
  observeEvent(c(input$mate1, input$mate1_sequence), {
    if (input$readsAreSequences) {
      update_command_line(
        session,
        "-1",
        input$mate1_sequence,
        default = "",
        mutually_exclusive_options = "-U"
      )
    } else {
      update_command_line(
        session,
        "-1",
        input$mate1$datapath,
        default = "",
        mutually_exclusive_options = "-U"
      )
    }
  })
  
  observeEvent(c(input$mate2, input$mate2_sequence), {
    if (input$readsAreSequences) {
      update_command_line(
        session,
        "-2",
        input$mate2_sequence,
        default = "",
        mutually_exclusive_options = "-U"
      )
    } else {
      update_command_line(
        session,
        "-2",
        input$mate2$datapath,
        default = "",
        mutually_exclusive_options = "-U"
      )
    }
  })
  
  observeEvent(c(input$unpaired, input$unpaired_sequence), {
    if (input$readsAreSequences) {
      update_command_line(
        session,
        "-U",
        input$unpaired_sequence,
        default = "",
        mutually_exclusive_options = c("-1", "-2")
      )
    } else {
      update_command_line(
        session,
        "-U",
        input$unpaired$datapath,
        default = "",
        mutually_exclusive_options = c("-1", "-2")
      )
    }
  })
  
  observeEvent(input$readsAreSequences, {
    update_command_line(session, "-c", input$readsAreSequences, default = FALSE)
  })
  
  observeEvent(input$index, {
    update_command_line(session, "-x", input$index, default = "")
  })
  
  observeEvent(input$submit, {
    query <- input$bt2Options %>%
      str_remove("^bowtie2\\s*") %>%
      paste("--no-head", "--mm")
    submit_bowtie2_query(socket, query)
    sam_output <- character(0)
    repeat {
      s <- readLines(socket, n = -1, skipNul = TRUE)
      sam_output <- paste(sam_output, s, collapse = "", sep = "\n")
      if (length(s) == 0)
        break
    }
    removeTab(inputId = "tabs", target = "SAM Output")
    insertTab(
      inputId = "tabs",
      tabPanel("SAM Output", style = "overflow-y:scroll; max-height: 600px;",
               HTML(highlight_sam(sam_output))),
      target = "Manual"
    )
  })
  
  observe({
    
    updateWidgetsFromURL(session$clientData$url_search)
  })
  
  update_command_line <-
    function(session,
             option,
             value,
             default = NULL,
             mutually_exclusive_options = NULL,
             replacement = NULL) {
      cmd_line <- input$bt2Options
      if (is.na(value))
        return(NULL)
      
      if (nchar(cmd_line) > 0) {
        cmd_line <- str_replace_all(cmd_line, "—", "--")
      }
      
      flag <- option == value || is.logical(default)
      if (flag) {
        regex <- option
      } else {
        regex <- paste0(option, "\\s+\\S+")
      }
      
      if (str_detect(cmd_line, option)) {
        if (value == default) {
          cmd_line <- str_replace(cmd_line, regex, "")
        } else {
          if (!flag) {
            cmd_line <- str_replace(cmd_line, regex, paste(option, value))
          }
        }
      } else {
        sapply(mutually_exclusive_options, function(opt) {
          cmd_line <<- str_replace(cmd_line, paste0(opt, "(\\s+\\S+)?"), "")
        })
        
        if (value != default) {
          if (flag) {
            cmd_line <- paste(cmd_line, option)
          } else {
            cmd_line <- paste(cmd_line, option, value)
          }
        }
      }
      if (str_detect(cmd_line, "^bowtie2") == FALSE) {
        cmd_line <- paste("bowtie2", cmd_line)
      }
      updateTextAreaInput(session, "bt2Options", value = str_squish(str_trim(cmd_line, side = "both")))
    }
  
  observeEvent(input$bookmark, {
    session$doBookmark()
    session$onBookmarked(function(url) {
      updateQueryString(url)
    })
  })
  
  output$clip <- renderUI({
    rclipButton("clipbtn", "Copy Command", input$bt2Options, icon("clipboard"))
  })
  
  # output$copyUrl <- renderUI({
  #   rvs <- reactiveValuesToList(input)
  #   inputIds <- names(rvs)
  #   inputIdsToExclude <- c(
  #     "readsAreSequences",
  #     "extendAttempts",
  #     "tabs",
  #     "mate2_sequence",
  #     "mate1_sequence",
  #     "index",
  #     "noContain",
  #     "bt2Options",
  #     "sidebarItemExpanded"
  #   )
  #   inputIds <- setdiff(inputIds, inputIdsToExclude)
  #   filteredRVs <- rvs[inputIds]
  #   url <- URLencode(paste(names(filteredRVs), filteredRVs, sep = "=", collapse = "&"))
  #   rclipButton("clipbtn2", "Copy URL", url, icon("clipboard"))
  # })
  
  run_bowtie2 <- function() {
    if (!is_bowtie2_running()) {
      bowtie2_binary_path <-
        paste(getwd(), "bowtie2", "bowtie2-align-s", sep = "/")
      bowtie2_process <<-
        process$new(
          "sh",
          c(
            "-c",
            "/Users/rcharles/Development/Computational_Biology/bowtie2/bowtie2-align-s --server"
          )
        )
      Sys.sleep(1)
      create_bowtie2_socket()
    }
  }
  
  is_bowtie2_running <- function() {
    !is.null(bowtie2_process) && bowtie2_process$is_alive()
  }
  
  create_bowtie2_socket <- function() {
    socket <<- socketConnection(port = 22000)
  }
  
  submit_bowtie2_query <- function(socket, query) {
    writeLines(query, socket)
    Sys.sleep(1)
  }
  
  highlight_sam <- function(sam) {
    pygments <- import("pygments")
    pygments.lexers <- import("pygments.lexers")
    pygments.formatters <- import("pygments.formatters")
    
    path_to_sam_lexer <-
      "/Users/rcharles/Documents/bowtie2-ui/sam_lexer.py"
    sam_lexer <-
      pygments.lexers$load_lexer_from_file(path_to_sam_lexer, "SamLexer")
    formatter <-
      pygments.formatters$HtmlFormatter(style = "perldoc")
    formatter$noclasses = TRUE
    pygments$highlight(sam, sam_lexer, formatter)
  }
  
  updateWidgetsFromURL <- function(url) {
    q <- parseQueryString(url)
    rvs <-reactiveValuesToList(input)
    for (inputId in names(rvs)) {
      val <- q[[inputId]]
      if (is.null(val)) {
        next
      }

      if (inputId == "typeOfQualityValues") {
        updateRadioButtons(session, inputId, selected = val)
      } else if (inputId == "skip") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "upto") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "inputFileFormat") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "trim3") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "trim5") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "alignmentType") {
        updateRadioButtons(session, inputId, selected = val)
      } else if (inputId == "seenLen") {
        updateSliderInput(session, inputId, value = val)
      } else if (inputId == "interval") {
        updateTextInput(session, inputId, value = val)
      } else if (inputId == "interval") {
        
      } else if (inputId == "nCeil") {
        updateTextInput(session, inputId, value = val)
      } else if (inputId == "maxMM") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "dPad") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "ignoreQuals") {
        updateCheckboxInput(session, inputId, value = val)  
      } else if (inputId == "noFw") {
        updateCheckboxInput(session, inputId, value = val)
      } else if (inputId == "noRc") {
        updateCheckboxInput(session, inputId, value = val)
      } else if (inputId == "no1MmUpFront") {
        updateCheckboxInput(session, inputId, value = val)
      } else if (inputId == "matchBonus") {
        updateNumericInput(session, inputId, value = val) 
      } else if (inputId == "scoreMin") {
        updateNumericInput(session, inputId, value = val) 
      } else if (inputId == "maxPenalty") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "nPenalty") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "extendAttempts") {
        updateNumericInput(session, inputId, value = val) 
      } else if (inputId == "seedCount") {
        updateNumericInput(session, inputId, value = val)
      } else if (inputId == "paired") {
        updateCheckboxInput(session, inputId, value = val) 
      } else {
        
      }
    }
  }
  
})
