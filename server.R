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
library(dplyr)

function(input, output, session) {
  crispr_sam_tab_exists <- FALSE
  bowtie2_sam_tab_exists <- FALSE
  
  simpleFuncRegex <- "^(L|G|S)(,-?(\\d+(\\.\\d+)?)?){0,2}$"

  rvs <- reactiveValues()
  requiredFields <- c()

  source("tooltips.R", local = TRUE)

  register_mouseover_events(session)
  # setBookmarkExclude(setdiff(names(isolate(reactiveValuesToList(input))), c("typeOfQualityValues")))

  disable("bt2Options")
  output$clip <- renderUI({
    rclipButton("clipbtn",
      "Copy Command",
      input$bt2Options,
      icon("clipboard"))
  })
  clicks <- 0
  onclick("toggleCommand", function() {
    toggle(id = "cmd_line", anim = TRUE)
    if (clicks %% 2 == 0) {
      shinyjs::html("toggleCommand", "Hide command")
      shinyjs::show("clip", anim = TRUE, animType = "fade", time = 0.25)
    } else {
      shinyjs::html("toggleCommand", "Show command")
      shinyjs::hide("clip", anim = TRUE, animType = "fade", time = 0.25)
    }
    clicks <<- clicks + 1
  }, TRUE)
  shinyjs::runjs("$('#mate1_sequence').attr('maxlength', 500)")
  shinyjs::runjs("$('#mate2_sequence').attr('maxlength', 500)")
  shinyjs::runjs("$('#unpaired_sequence').attr('maxlength', 500)")

  # updateCheckboxInput(session, "readsAreSequences", value = FALSE)

  # observeEvent(input$tabs, {
  #   addClass(selector = "body", class = "sidebar-collapse")
  # })

  observeEvent(input$dPad, {
    update_command_line(session, "--dpad", input$dPad, default = 15)
  })

  observeEvent(input$gBar, {
    update_command_line(session, "--gbar", input$gBar, default = 4)
  })

  observeEvent(input$interval, {
    interval <- str_remove(input$interval, "\\s")
    feedbackDanger(
      inputId = "interval",
      condition = !str_detect(input$interval, simpleFuncRegex),
      text = "Invalid function"
    )
    default <- "S,1,1.15"
    if (interval == "")
      interval <- default
    updateTextInput(session, inputId = "interval", value = interval)
    update_command_line(session, "-i", interval, default = default)
  })

  observeEvent(input$nCeil, {
    nCeil <- str_remove(input$nCeil, "\\s")
    feedbackDanger(
      inputId = "nCeil",
      condition = !str_detect(input$nCeil, simpleFuncRegex),
      text = "Invalid function"
    )
    default <- "L,0,0.15"
    if (nCeil == "") {
      nCeil <- default
    }
    updateTextInput(session, inputId = "nCeil", value = nCeil)
    update_command_line(session, "--n-ceil", nCeil, default = default)
  })

  observeEvent(input$scoreMin, {
    scoreMin <- str_remove(input$scoreMin, "\\s")
    feedbackDanger(
      inputId = "scoreMin",
      condition = !str_detect(input$scoreMin, simpleFuncRegex),
      text = "Invalid function"
    )
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
      selected = "GRCh38",
      choices = choices
    )
    updateSelectizeInput(
      session,
      "index2",
      server = TRUE,
      selected = "GRCh38",
      choices = choices
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
  }, ignoreInit = TRUE)

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
  }, ignoreInit = TRUE)

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
  }, ignoreInit = TRUE)

  observeEvent(input$paired, {
    cmd_line <- input$bt2Options
    if (input$paired == "Paired") {
      cmd_line <- str_replace(cmd_line, paste0("-U", "\\s+\\S+"), "")

      if (!is.null(input$mate1) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1$name)
      }

      if (input$mate1_sequence != "" &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1_sequence)
      }

      if (!is.null(input$mate2) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-2", input$mate2$name)
      }

      if (input$mate2_sequence != "" &&
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

      if (input$unpaired_sequence != "" &&
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
    if (input$readsAreSequences) {
      shinyjs::hide("inputFileFormat")
      shinyjs::hide("typeOfQualityValues")
      if (input$typeOfQualityValues != "--phred33") {
        cmd_line <- str_replace(cmd_line, input$typeOfQualityValues, "")
      }
      if (input$inputFileFormat != "-q") {
        cmd_line <- str_replace(cmd_line, input$inputFileFormat, "")
      }
    } else {
      shinyjs::show("inputFileFormat")
      shinyjs::show("typeOfQualityValues")
      if (input$typeOfQualityValues != "--phred33") {
        cmd_line <- paste(cmd_line, input$typeOfQualityValues)
      }
      if (input$inputFileFormat != "-q") {
        cmd_line <- paste(cmd_line, input$inputFileFormat)
      }
    }
    if (input$paired == "Paired") {
      cmd_line <- str_replace(cmd_line, paste0("-1", "\\s+\\S+"), "")
      cmd_line <-
        str_replace(cmd_line, paste0("-2", "\\s+\\S+"), "")


      if (!is.null(input$mate1) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1$name)
      }

      if (input$mate1_sequence != "" &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-1", input$mate1_sequence)
      }

      if (!is.null(input$mate2) &&
          input$readsAreSequences == FALSE) {
        # cmd_line <- str_remove(cmd_line, "-c")
        cmd_line <- paste(cmd_line, "-2", input$mate2$name)
      }

      if (input$mate2_sequence != "" &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-2", input$mate2_sequence)
      }
    } else {
      cmd_line <- str_replace(cmd_line, paste0("-U", "\\s+\\S+"), "")

      if (!is.null(input$unpaired) &&
          input$readsAreSequences == FALSE) {
        cmd_line <- paste(cmd_line, "-U", input$unpaired$name)
      }

      if (input$unpaired_sequence != "" &&
          input$readsAreSequences == TRUE) {
        cmd_line <- paste(cmd_line, "-U", input$unpaired_sequence)
      }
    }
    # updateTextAreaInput(session, "bt2Options", value = str_squish(str_trim(cmd_line, side = "both")))
    update_command_line(session, "-c", input$readsAreSequences, cmd_line = cmd_line, default = FALSE)
  })

  observeEvent(input$index, {
    update_command_line(session, "-x", input$index, default = "")
  })

  observeEvent(input$submit, {
    msgs <- list()

    if (input$index == "") {
      msgs <- append(msgs, "Index")
    }

    if (input$paired == "Paired") {
      if (input$readsAreSequences) {
        if (input$mate1_sequence == "") {
          msgs <- append(msgs, "Mate one sequence")
        }

        if (input$mate2_sequence == "") {
          msgs <- append(msgs, "Mate two sequence")
        }
      } else {
        if (is.null(input$mate1)) {
          msgs <- append(msgs, "File with mate one reads")
        }

        if (is.null(input$mate2)) {
          msgs <- append(msgs, "File with mate two reads")
        }
      }
    } else {
      if (input$readsAreSequences) {
        if (input$unpaired_sequence == "") {
          msgs <- append(msgs, "Unpaired sequence")
        }
      } else {
        if (is.null(input$unpaired)) {
          msgs <- append(msgs, "Unpaired read file")
        }
      }
    }

    msgs <- lapply(msgs, tags$li)

    if (length(msgs) != 0) {
      showModal(modalDialog(
          title = "Missing required inputs:",
          tagAppendChildren(tags$ul(), tagList(msgs)),
          easyClose = TRUE
      ))

      return(NULL)
    }

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
      submit_query(input$bt2Options, input$upto, file_inputs, input$index)

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

    rvs$bt2_sam <- out$stdout

    if (!bowtie2_sam_tab_exists) {
      insertTab(
        inputId = "bowtie2tabs",
        tabPanel("SAM Output", style = "overflow-y:scroll; max-height: 600px;",
          uiOutput("bt2_output")),
        target = "Welcome",
        select = TRUE
      )
      bowtie2_sam_tab_exists <<- TRUE
    }
  })

  observeEvent(c(rvs$bt2_sam, input$bt2ToggleHighlight), {
    output$bt2_output <- renderUI({
      if (input$bt2ToggleHighlight %% 2 == 0) {
        HTML(highlight_sam(rvs$bt2_sam))
      } else {
        HTML(highlight_sam(rvs$bt2_sam, "bw"))
      }
    })
  })

  output$bt2DownloadSAM <- downloadHandler(
    filename = function() {
      paste("bowtie2-",
        format(Sys.time(), "%m%d%Y%H%M%S"),
        ".sam",
        sep = "")
    },
    content = function(file) {
      write_file(rvs$bt2_sam, file)
    }
  )

  output$bt2Copy <- renderUI({
    rclipButton("bt2ClipBtn",
      "Copy Command",
      rvs$bt2_sam,
      icon("clipboard"))
  })

  observe({
    invalidateLater(5000, session)
    closeAlert(session, "bowtie2Alert")
  })

  observeEvent(input$bowtie2tabs, {
    if (input$bowtie2tabs != "SAM Output") {
      shinyjs::hide("bowtie2controls")
    } else {
      shinyjs::show("bowtie2controls")
    }
  })


  #### CRISPR
  observeEvent(input$crisprSubmit, {
    shinyjs::disable("crisprSubmit")
    on.exit(shinyjs::enable("crisprSubmit"))
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
    progress <- shiny::Progress$new(style = "notification")
    progress$set(message = "Running Bowtie query", value = 0)
    on.exit(progress$close(), add = TRUE)
    query <-
      paste(input$index2,
        "-F",
        paste0(input$kmer + 1, ",", input$offset),
        filepath,
        "-a",
        "-v3",
        "-S")
    out <- submit_query(query, aligner = "bowtie", index = input$index2, upto = 0)

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
    progress$set(value = 0.40, message = "Highlighting output")

    rvs$crispr_sam <- out$stdout

    if (!crispr_sam_tab_exists) {
      insertTab(
        inputId = "crisprtabs",
        tabPanel("SAM Output", style = "overflow-y:scroll; max-height: 600px;",
          uiOutput("crispr_output")),
        target = "Welcome",
        select = TRUE
      )
      crispr_sam_tab_exists <<- TRUE
    }

    progress$set(value = 0.50, message = "Rendering k-mer diagram")
    fig <- kmer_diagram(rvs$crispr_sam)
    updateSelectizeInput(
      session,
      "kmer_filter",
      choices = c("", crispr_data[[2]]),
      selected = "",
      server = TRUE
    )

    output$kmer_alignments <- renderUI({
      div(id = "kmerDiagram",
        box(
          width = NULL,
          tags$p(
            id = "kmer_diagram",
            style = "font-family: monospace;",
            span(id = "sequence_", input$crisprSequence),
            tags$br(),
            HTML(fig),
            absolutePanel(
              style = "padding: 5px;",
              actionButton("font_size_increase", NULL, icon = icon("plus")),
              actionButton("font_size_decrease", NULL, icon = icon("minus")),
              bottom = 0,
              right = 0
            ),
            tags$script(src = "script.js")
          )
        ))
    })
    progress$set(value = 1, message = "Done")
  })

  observeEvent(rvs$crispr_sam, {
    output$crispr_output <- renderUI({
      HTML(highlight_sam(rvs$crispr_sam))
    })
  })

  observeEvent(c(
    rvs$crispr_sam,
    input$kmer_filter,
    input$crisprToggleHighlight
  ),
    {
      out <- rvs$crispr_sam

      if (input$kmer_filter != "") {
        pat <-
          paste(input$kmer_filter,
            reverse_complement(input$kmer_filter),
            sep = "|")
        out <- str_split(rvs$crispr_sam, "\n") %>% {
          str_subset(.[[1]], pat)
        } %>% str_flatten(collapse = "\n")
      }

      updateSelectizeInput(session, "kmer_filter", selected = input$kmer_filter)

      output$crispr_output <- renderUI({
        if (input$crisprToggleHighlight %% 2 == 0) {
          HTML(highlight_sam(out))
        } else {
          HTML(highlight_sam(out, "bw"))
        }
      })
    })

  output$crisprDownloadSAM <- downloadHandler(
    filename = function() {
      paste("crispr-", format(Sys.time(), "%m%d%Y%H%M%S"), ".sam", sep = "")
    },
    content = function(file) {
      write_file(rvs$crispr_sam, file)
    }
  )

  # output$crisprSAMCopy <- renderUI({
  #   out <- rvs$crispr_sam
  #   
  #   if (input$kmer_filter != "") {
  #     pat <-
  #       paste(input$kmer_filter,
  #         reverse_complement(input$kmer_filter),
  #         sep = "|")
  #     out <- str_split(rvs$crispr_sam, "\n") %>% {
  #       str_subset(.[[1]], pat)
  #     } %>% str_flatten(collapse = "\n")
  #   }
  #     
  #   rclipButton("crisprClipBtn",
  #     "Copy",
  #     out,
  #     icon("clipboard"))
  # })

  observeEvent(input$crisprtabs, {
    if (input$crisprtabs != "SAM Output") {
      shinyjs::hide("crisprcontrols")
    } else {
      shinyjs::show("crisprcontrols")
    }
  })

  reverse_complement <- function(kmer) {
    chartr("ACTG", "TGAC", kmer) %>% stringi::stri_reverse()
  }

  kmer_diagram <- function(sam) {
    df <- read_tsv(sam, col_names = FALSE)
    read_names_and_count <-
      df %>% group_by(X1) %>% summarize(count = n())
    read_names_and_kmers <-
      df %>% filter(bitwAnd(X2, 16) == 0) %>% select(X1, X10) %>% unique

    crispr_data <<-
      inner_join(read_names_and_kmers, read_names_and_count)
    format_kmers(crispr_data, input$crisprSequence, input$kmer)
  }

  format_kmers <- function(data, sequence, kmer_length) {
    field_widths <- str_locate(sequence, data[[2]])[, 2]
    padded_kmer_counts <-
      str_pad(data[[3]],
        width = kmer_length,
        side = "both",
        pad = "-")
    padded_kmer_counts <-
      str_replace_all(padded_kmer_counts, "^-|-$", "^")
    # padded_kmer_counts <- sapply(padded_kmer_counts, function(s) { format(span(s, class = "kmer")) }, USE.NAMES = FALSE)
    start <- kmer_length
    if (max(field_widths) %% kmer_length == 0) {
      end <- ceiling((max(field_widths) + 1) / kmer_length) * kmer_length
    } else {
      end <- ceiling((max(field_widths)) / kmer_length) * kmer_length
    }
    field_widths <-
      split(field_widths,
        cut(
          field_widths,
          breaks = seq(start, end, by = kmer_length),
          include.lowest = TRUE,
          right = FALSE
        ))

    kmer_index <- 1
    off <- 0
    r <- 1:kmer_length
    out <- vector("character", kmer_length)
    add_span_tag <- function(s) {
      s <-
        span(s, id = data[[2]][kmer_index], class = "kmer") %>% format()
      kmer_index <<- kmer_index + 1
      s
    }
    for (i in 1:length(field_widths)) {
      # index <- (i-1) * kmer_length + seq_along(field_widths[[i]])
      index <- seq_along(field_widths[[i]]) + off
      present_rows <- field_widths[[i]] %% kmer_length + 1
      missing_rows <-
        setdiff(r, field_widths[[i]] %% kmer_length + 1)
      if (i == 1) {
        out[present_rows] <-
          str_pad(padded_kmer_counts[index],
            width = field_widths[[i]],
            pad = "~") %>% sapply(add_span_tag, USE.NAMES = FALSE)
        out[missing_rows] <-
          str_dup("~", missing_rows + kmer_length)
      } else {
        out[present_rows] <-
          paste0(out[present_rows],
            padded_kmer_counts[index] %>% sapply(add_span_tag, USE.NAMES = FALSE))
        out[missing_rows] <-
          paste0(out[missing_rows], str_dup("~", kmer_length))
      }
      off <- off + length(index)
    }

    paste(str_replace_all(out, "~", "&nbsp;"), collapse = "<br/>")
  }

  observeEvent(input$tutorial, {
    id <- if (input$paired == "Unpaired") {
      if (input$readsAreSequences) {
        "#unpairedInputSequence"
      } else {
        "#unpairedInputFIle"
      }
    } else {
      if (input$readsAreSequences) {
        "#pairedInputSequence"
      } else {
        "#pairedInputFile"
      }
    }
    introjs(
      session,
      options = list(
        "nextLabel" = "Next",
        "prevLabel" = "Back",
        "skipLabel" = "Skip",
        steps = data.frame(
          element = c(
            "#indexSelect",
            id,
            "#readsAreSequences",
            "#formatOptions",
            "#alnAlgOptions",
            "#scoringFuncOptions",
            "#outputOptions",
            "#toggleCommand",
            "#submit"
          ),
          intro = c(
            "Select a pre-built genome index",
            "Provide reads, either as sequences or as files.",
            "Check this if you entered the sequences themselves rather than file names",
            "Configure how your reads are formatted",
            "Configure the alignment algorithm",
            "Configure the scoring function",
            "Configure SAM output",
            "Click here to view the command that will be used to run Bowtie 2",
            "Click this button to submit your command"
          )
        )
      )
    )
  })
  observeEvent(input$crisprtutorial, {
    oldIndex <- input$index2
    oldSequence <- input$crisprSequence
    oldKmer <- input$kmer
    oldOffset <- input$offset
    update_funcs <- c(
      sprintf("Shiny.setInputValue('showModal', %d)", input$crisprtutorial),
      sprintf("Shiny.setInputValue('index2', '%s')", oldIndex),
      sprintf("Shiny.setInputValue('crisprSequence', '%s')", oldSequence),
      sprintf("Shiny.setInputValue('kmer', %d)", oldKmer),
      sprintf("Shiny.setInputValue('offset', %d)", oldOffset)
    )
    updateNumericInput(session, "kmer", value = 20)
    updateNumericInput(session, "offset", value = 1)
    updateSelectizeInput(session, "index2", selected = "C_elegans_WS195")
    updateTextAreaInput(session, "crisprSequence", value = "GCCGGGCGCTGGTTATGGTCAGTTCGAGCATAAGGCTGAC")
    delay(100, click("crisprSubmit"))
    introjs(
      session,
      events = list("onexit" = I(paste0(update_funcs, collapse = ";"))),
      # events = list("oncomplete" = I('Shiny.setInputValue("kmer", "12");')),
      options = list(
        "nextLabel" = "Next",
        "prevLabel" = "Back",
        "skipLabel" = "Skip",
        steps = data.frame(
          element = c(
            "#selectCrisprIndex",
            "#crisprSequence",
            "#fastaContinuousOptions",
            "#kmer_alignments",
            "#kmerFilterWidget"
          ),
          intro = c(
            "Select a pre-built genome index",
            "Specify \"target\" sequence; Bowtie 2 will align substrings of this sequence.",
            "Specify k-mer length k and interval i.  Bowtie 2 will align every ith k-mer from the target sequence.  Interval of 1 means all k-mers, interval of 2 means every other k-mer, etc.",
            "View the k-mers that were aligned and the number of times they aligned to the reference.  Hover over the numbers to highlight the k-mer and click to focus on its alignments.",
            "View SAM alignments for all k-mers (default) or a specific k-mer (after clicking on one)"
          )
        )
      )
    )
  })
  observeEvent(input$showModal, {
    showModal(
      modalDialog(
        title = NULL,
        size = "s",
        "Do you want to restore the state of the UI",
        easyClose = TRUE,
        footer = tagList(actionButton("restore", "Yes"),
          modalButton("No"))
      )
    )
  })
  observeEvent(input$restore, {
    removeModal()
    updateNumericInput(session, "kmer", value = input$kmer)
    updateNumericInput(session, "offset", value = input$offset)
    updateTextAreaInput(session, "crisprSequence", value = input$crisprSequence)
    updateSelectizeInput(session, "index2", selected = input$index2)
    output$kmer_alignments <- renderUI({
    })
    removeTab("crisprtabs", "SAM Output")
    crispr_sam_tab_exists <<- FALSE
  })

  update_command_line <-
    function(session,
      option,
      value,
      cmd_line = input$bt2Options,
      default = NULL,
      mutually_exclusive_options = NULL,
      replacement = NULL) {
      # cmd_line <- input$bt2Options
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

      regex <- paste0("\\B", regex)

      if (str_detect(cmd_line, paste0("\\B", option))) {
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
            str_replace(cmd_line, paste0("\\B", opt), "")
          } else {
            str_replace(cmd_line, paste0("\\B", opt, "(\\s+\\S+)?"), "")
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

  submit_query <-
    function(query,
      upto = 1000,
      file_inputs = NULL,
      index = NULL,
      aligner = "bowtie2") {
      query <- query %>%
        str_remove(paste0("^", aligner, "\\s*")) %>%
        paste("--shmem", if (aligner == "bowtie") "--sam-nohead" else "--no-head")
      bin_path <- paste("/software", paste0(aligner, "/", aligner), sep = "/")

      if (str_detect(query, "--upto") == FALSE && upto != 0) {
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
        bin_path,
        argv,
        env = c(Sys.getenv(), BOWTIE2_INDEXES = BOWTIE2_INDEXES, BOWTIE_INDEXES = BOWTIE2_INDEXES),
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
    sapply(1:length(tags) - 1, function(i) {
      as.character(tags[i])
    })
  }

  show_help_text <- function(opts, session) {
    if (isolate(session$input$width[[1]]) < 768) {
      return(NULL)
    }
    text <- ""
    sapply(opts, function(opt) {
      t <- paste(get_help_text(opt), collapse = "\n")
      text <<- paste(text, t, sep = "\n")
    })
    # text <- get_help_text(opt)
    # text <- paste(text, collapse = "\n")

    observe({
      insertTab(
        inputId = "bowtie2tabs",
        tabPanel("Help", HTML(text)),
        target = "Welcome",
        select = TRUE,
        session = session
      )
    })
  }

  remove_help_text <- function(session) {
    if (isolate(session$input$width[[1]]) < 768) {
      return(NULL)
    }
    observe({
      removeTab("bowtie2tabs", "Help", session = session)
    })
  }
}
