#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readr)
library(stringr)
library(shinyjs)
library(processx)
library(markdown)
library(rclipboard)
library(reticulate)
library(rintrojs)
library(magrittr)
library(digest)
library(shinyBS)

sam_output <- ""

shinyServer(function(input, output, session) {
  source("tooltips.R", local = TRUE)
  
  register_mouseover_events(session)
  
  rclipboardSetup()
  disable("bt2Options")
  onclick("toggleCommand", toggle(id = "cmd_line", anim = TRUE))
  
  shinyjs::runjs("$('#mate1_sequence').attr('maxlength', 500)")
  shinyjs::runjs("$('#mate2_sequence').attr('maxlength', 500)")
  shinyjs::runjs("$('#unpaired_sequence').attr('maxlength', 500)")
  
  render_controls <- function() {
    output$moreControls <- renderUI({
      absolutePanel(
        id = "controls",
        bottom = 0,
        left = 0,
        div(
          style = "padding: 20px;",
          downloadButton("downloadData", "Download"),
          actionButton("copy", "Copy", icon = icon("copy")),
          actionButton(
            "highlight",
            "Toggle Highlight",
            icon = icon("highlighter", "fas")
          )
        )
      )
    })
  }
  
  remove_controls <- function(session) {
    removeUI(selector = "div#moreControls", session = session)
  }
  
  onevent("mouseenter", "sam_output", render_controls())
  onevent("mouseleave", "sam_output", remove_controls(session))

  updateCheckboxInput(session, "readsAreSequences", value = FALSE)
  
  observeEvent(input$tabs, {
    addClass(selector = "body", class = "sidebar-collapse")
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
      default <- "L,-0.6,-0.6"
    } else {
      default <- "G,20,8"
    }
    if (scoreMin == "") {
      scoreMin <- default
    }
    updateTextInput(session, inputId = "scoreMin", value = scoreMin)
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
    if (input$alignmentType == "--end-to-end") {
      cmd_line <- update_command_line(
        session,
        "--end-to-end",
        input$alignmentType,
        default = "--end-to-end",
        mutually_exclusive_options = c("--local")
      )
      if (str_detect(input$bt2Options, input$localPresets)) {
        cmd_line <-
          str_replace(cmd_line, input$localPresets, input$endToEndPresets)
        updateTextInput(session, "bt2Options", value = cmd_line)
      }
    }
    else {
      cmd_line <- update_command_line(
        session,
        "--local",
        input$alignmentType,
        default = "--end-to-end",
        mutually_exclusive_options = c("--end-to-end")
      )
      if (str_detect(input$bt2Options, input$endToEndPresets)) {
        cmd_line <-
          str_replace(cmd_line, input$endToEndPresets, input$localPresets)
        updateTextInput(session, "bt2Options", value = cmd_line)
      }
    }
  })
  
  observeEvent(input$matchBonus, {
    if (input$alignmentType == "--end-to-end")
      update_command_line(session, "--ma", input$matchBonus, default = 0)
    else
      update_command_line(session, "--ma", input$matchBonus, default = 2)
  })
  
  observeEvent(input$maxPenalty, {
    update_command_line(session, "--mp", input$maxPenalty, default = 6)
  })
  
  observeEvent(input$nPenalty, {
    update_command_line(session, "--np", input$nPenalty, default = 1)
  })
  
  observeEvent(input$minIns, {
    update_command_line(session, "--minins", input$minIns, default = 0)
  })
  
  observeEvent(input$maxIns, {
    update_command_line(session, "--maxins", input$maxIns, default = 500)
  })
  
  observeEvent(input$noMixed, {
    update_command_line(session, "--no-mixed", input$noMixed, default = FALSE)
  })
  
  observeEvent(input$noDiscordant, {
    update_command_line(session, "--no-discordant", input$noDiscordant, default = FALSE)
  })
  
  observeEvent(input$doveTail, {
    update_command_line(session, "--dovetail", input$doveTail, default = FALSE)
  })
  
  observeEvent(input$noContain, {
    update_command_line(session, "--no-contain", input$noContain, default = FALSE)
  })
  
  observeEvent(input$noOverlap, {
    update_command_line(session, "--no-overlap", input$noOverlap, default = FALSE)
  })
  
  observeEvent(input$mateAlign, {
    mutually_exclusive_options <-
      c("--fr",
        "--rf",
        "--ff")
    mutually_exclusive_options <-
      setdiff(mutually_exclusive_options, input$mateAlign)
    update_command_line(
      session,
      input$mateAlign,
      input$mateAlign,
      default = "--fr",
      mutually_exclusive_options = mutually_exclusive_options
    )
  })
  
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
  
  observeEvent(input$extendAttempts, {
    update_command_line(session, "-D", input$extendAttempts, default = 15)
  })
  
  observeEvent(input$seedCount, {
    update_command_line(session, "-R", input$seedCount, default = 2)
  })
  
  observeEvent(input$noSq, {
    update_command_line(session, "--no-sq", input$noSq, default = FALSE)
  })
  
  observeEvent(input$noHead, {
    update_command_line(session, "--no-head", input$noHead, default = FALSE)
  })
  
  observeEvent(input$omitSecSeq, {
    update_command_line(session, "--omit-sec-seq", input$omitSecSeq, default = FALSE)
  })
  
  observeEvent(input$samNoQnameTrunc, {
    update_command_line(session,
      "--sam-no-qname-trunc",
      input$samNoQnameTrunc,
      default = FALSE)
  })
  
  observeEvent(input$xEq, {
    update_command_line(session, "--xeq", input$xEq, default = FALSE)
  })
  
  observeEvent(input$softClippedUnmappedTlen, {
    update_command_line(
      session,
      "--soft-clipped-unmapped-tlen",
      input$softClippedUnmappedTlen,
      default = FALSE
    )
  })
  
  observeEvent(input$localPresets, {
    mutually_exclusive_options <-
      mutually_exclusive_options <-
      c(
        "--very-fast-local",
        "--fast-local",
        "--sensitive-local",
        "--very-sensitive-local",
        "--very-fast",
        "--fast",
        "--sensitive",
        "--very-sensitive"
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
        "--very-fast-local",
        "--fast-local",
        "--sensitive-local",
        "--very-sensitive-local",
        "--very-fast",
        "--fast",
        "--sensitive",
        "--very-sensitive"
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
    choices <- list.files("/indexes")
    updateSelectizeInput(
      session,
      "index",
      server = TRUE,
      choices = choices,
      selected = NULL
    )
    updateSelectizeInput(
      session,
      "index2",
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
        basename(input$mate1$name),
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
        basename(input$mate2$name),
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
        basename(input$unpaired$name),
        default = "",
        mutually_exclusive_options = c("-1", "-2")
      )
    }
  })
  
  observeEvent(input$paired, {
    cmd_line <- input$bt2Options
    if (input$paired == "Paired") {
      cmd_line <- str_replace(cmd_line, paste0("-U", "\\s+\\S+"), "")
      
      if (!is.null(input$mate1) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1$name)
      }
      
      if (!is.null(input$mate1_sequence) &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1_sequence)
      }
      
      if (!is.null(input$mate2) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-2", input$mate2$name)
      }
      
      if (!is.null(input$mate2_sequence) &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-2", input$mate2_sequence)
      }
    } else{
      mutually_exclusive_options <-
        c(
          "--fr",
          "--rf",
          "--ff",
          "--no-mixed",
          "--no-discordant",
          "--dovetail",
          "--no-contain",
          "--no-overlap"
        )
      sapply(mutually_exclusive_options, function(opt) {
        cmd_line <<- str_replace(cmd_line, opt, "")
      })
      
      cmd_line <-
        str_replace(cmd_line, paste0("-1", "\\s+\\S+"), "")
      cmd_line <-
        str_replace(cmd_line, paste0("-2", "\\s+\\S+"), "")
      cmd_line <-
        str_replace(cmd_line, paste0("--minins", "\\s+\\S+"), "")
      cmd_line <-
        str_replace(cmd_line, paste0("--maxins", "\\s+\\S+"), "")
      
      if (!is.null(input$unpaired) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-U", input$unpaired$name)
      }
      
      if (!is.null(input$unpaired_sequence) &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-U", input$unpaired_sequence)
      }
      
      updateCheckboxInput(session, "noMixed", value = FALSE)
      updateCheckboxInput(session, "noDiscordant", value = FALSE)
      updateCheckboxInput(session, "doveTail", value = FALSE)
      updateCheckboxInput(session, "noContain", value = FALSE)
      updateCheckboxInput(session, "noOverlap", value = FALSE)
      updateRadioButtons(session, "mateAlign", selected = "--fr")
      
      updateNumericInput(session, "minIns", value = 0)
      updateNumericInput(session, "maxIns", value = 500)
      
    }
    updateTextAreaInput(session, "bt2Options", value = str_squish(str_trim(cmd_line, side = "both")))
  })
  
  observeEvent(input$readsAreSequences, {
    cmd_line <- input$bt2Options
    if (input$paired == "Paired") {
      cmd_line <- str_replace(cmd_line, paste0("-1", "\\s+\\S+"), "")
      cmd_line <-
        str_replace(cmd_line, paste0("-2", "\\s+\\S+"), "")
      
      
      if (!is.null(input$mate1) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1$name)
      }
      
      if (!is.null(input$mate1_sequence) &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1_sequence)
      }
      
      if (!is.null(input$mate2) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-2", input$mate2$name)
      }
      
      if (!is.null(input$mate2_sequence) &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-2", input$mate2_sequence)
      }
    } else {
      cmd_line <- str_replace(cmd_line, paste0("-U", "\\s+\\S+"), "")
      
      if (!is.null(input$unpaired) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-U", input$unpaired$name)
      }
      
      if (!is.null(input$unpaired_sequence) &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-U", input$unpaired_sequence)
      }
    }
    update_command_line(session, "-c", input$readsAreSequences, default = FALSE)
    updateTextAreaInput(session, "bt2Options", value = str_squish(str_trim(cmd_line, side = "both")))
  })
  
  observeEvent(input$index, {
    update_command_line(session, "-x", input$index, default = "")
  })
  
  observeEvent(input$submit, {
    file_inputs <- list()
    if (input$readsAreSequences == FALSE) {
      if (input$paired == "Unpaired") {
        file_inputs[[1]] <- input$unpaired
      } else {
        file_inputs[[1]] <- input$mate1
        file_inputs[[2]] <- input$mate2
      }
    }
    
    out <-
      submit_bowtie2_query(input$bt2Options, input$upto, file_inputs, input$index)
    
    if (out$stdout == "") {
      usage_lines <- str_split(bt2_usage, "\n")[[1]]
      error_lines <- str_split(out$stderr, "\n")[[1]]
      
      err <- setdiff(error_lines, usage_lines) %>%
        Filter(function(x)
          str_detect(x, "^([A-Z]|--)"), .)
      
      createAlert(
        session,
        "alert",
        "bowtie2Alert",
        title = "Bowtie2 Error",
        content = paste(err, collapse = "\n"),
        append = FALSE,
        style = "error"
      )
      
      updateTabsetPanel(session, "bowtie2tabs", selected = "Welcome")
      return(NULL)
    }
    
    sam_output <<- out$stdout
    
    removeTab(inputId = "bowtie2tabs", target = "SAM Output")
    insertTab(
      inputId = "bowtie2tabs",
      tabPanel("SAM Output", style = "overflow-y:scroll; max-height: 600px;",
        uiOutput("moreControls"),
        div(id = "sam_output", div(id = "highlighted_output", HTML(highlight_sam(out$stdout))))),
      target = "Welcome",
      select = TRUE
    )
  })
  
  observeEvent(input$highlight, {
    sam <- if (input$highlight %% 2 == 0) {
      highlight_sam(sam_output)
    } else {
      highlight_sam(sam_output, "bw")
    }
    
    removeUI(selector = "div#highlighted_output", immediate = TRUE)
    insertUI(selector = "div#sam_output", where = "afterBegin", div(id = "highlighted_output", HTML(sam)))
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("bowtie2-", format(Sys.time(), "%m%d%Y%H%M%S"), ".sam", sep = "")
    },
    content = function(file) {
      write_file(sam_output, file)
    }
  )
  
  observe({
    invalidateLater(5000, session)
    closeAlert(session, "bowtie2Alert")
  })
  
  observeEvent(input$crisprSubmit, {
    if (input$crisprInput == "sequence") {
      data <- paste(">r1", input$crisprSequence, sep = "\n")
      hash <- digest(data, algo = "sha256")
      
      filepath <-
        paste(tempdir(), paste0(substr(hash, 0, 7), ".fa"), sep = "/")
      if (!file.exists(filepath)) {
        cat(data, file = filepath)
      }
    } else {
      filepath <- input$crisprFile$datapath
    }
    query <-
      paste("-x",
        input$index2,
        "-F",
        paste0(input$kmer+1, ",", input$offset),
        filepath)
    out <- submit_bowtie2_query(query, index = input$index2)
    
    if (out$stdout == "") {
      usage_lines <- str_split(bt2_usage, "\n")[[1]]
      error_lines <- str_split(out$stderr, "\n")[[1]]
      
      err <- setdiff(error_lines, usage_lines) %>%
        Filter(function(x)
          str_detect(x, "^Error:"), .)
      
      createAlert(
        session,
        "alert",
        "bowtie2Alert",
        title = "Bowtie2 Error",
        content = paste(err, collapse = "\n"),
        append = FALSE,
        style = "error"
      )
      
      updateTabsetPanel(session, "crisprtabs", selected = "Welcome")
      return(NULL)
    }
    
    removeTab(inputId = "crisprtabs", target = "SAM Output")
    insertTab(
      inputId = "crisprtabs",
      tabPanel("SAM Output", style = "overflow-y:scroll; max-height: 600px;",
        HTML(highlight_sam(out$stdout))),
      target = "Welcome",
      select = TRUE
    )
  })
  
  observeEvent(input$tutorial, {
    introjs(
      session,
      options = list(
        "nextLabel" = "Next",
        "prevLabel" = "Back",
        "skipLabel" = "Skip"
      )
    )
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
          cmd_line <<- if (flag) {
            str_replace(cmd_line, opt, "")
          } else {
            str_replace(cmd_line, paste0(opt, "(\\s+\\S+)?"), "")
          }
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
      cmd_line <- str_squish(str_trim(cmd_line, side = "both"))
      updateTextAreaInput(session, "bt2Options", value = cmd_line)
      
      cmd_line
    }
  
  observeEvent(input$bookmark, {
    session$doBookmark()
    session$onBookmarked(function(url) {
      updateQueryString(url)
    })
  })
  
  output$clip <- renderUI({
    rclipButton("clipbtn",
      "Copy Command",
      input$bt2Options,
      icon("clipboard"))
  })
  
  submit_bowtie2_query <-
    function(query,
      upto = 1000,
      file_inputs = NULL,
      index = NULL) {
      query <- query %>%
        str_remove("^bowtie2\\s*") %>%
        paste("--mm", "--no-head")
      bt2 <- paste("/software", "bowtie2/bowtie2", sep = "/")
      
      if (str_detect(query, "--upto") == FALSE) {
        query <- paste(query, "--upto", upto)
      }
      
      if (!is.null(file_inputs)) {
        sapply(file_inputs, function(i) {
          query <<- str_replace(query, i$name, i$datapath)
        })
      }
      
      if (index != "") {
        query <- str_replace(query, index, "genome")
      }
      
      argv <- str_split(query, "\\s+")[[1]]
      BOWTIE2_INDEXES <- paste("/indexes", index, sep = "/")
      
      run(
        bt2,
        argv,
        env = c(Sys.getenv(), BOWTIE2_INDEXES = BOWTIE2_INDEXES),
        error_on_status = FALSE
      )
    }
  
  highlight_sam <- function(sam, style = "perldoc") {
    pygments <- import("pygments")
    pygments.lexers <- import("pygments.lexers")
    pygments.formatters <- import("pygments.formatters")
    
    path_to_sam_lexer <- "sam_lexer.py"
    sam_lexer <-
      pygments.lexers$load_lexer_from_file(path_to_sam_lexer, "SamLexer")
    formatter <-
      pygments.formatters$HtmlFormatter(style = style)
    formatter$noclasses = TRUE
    pygments$highlight(sam, sam_lexer, formatter)
  }
  
  get_help_text <- function(opt) {
    id <- paste("bowtie2-options", opt, sep = "-")
    tags <- soup$find(id = id)$parent$find_all("p")
    sapply(1:length(tags) - 1, function(i) { as.character(tags[i]) })
  }
  
  show_help_text <- function(opts, session) {
    text <- ""
    sapply(opts, function(opt) {
      t <- paste(get_help_text(opt), collapse = "\n")
      text <<- paste(text, t, sep = "\n")
    })
    # text <- get_help_text(opt)
    # text <- paste(text, collapse = "\n")
    
    observe({
      insertTab(inputId = "bowtie2tabs",
        tabPanel("Help", HTML(text)),
        target = "Welcome",
        select = TRUE, session = session)
    })
  }
  
  remove_help_text <- function(session) {
    observe({
      removeTab("bowtie2tabs", "Help", session = session)
    })
  }
})
