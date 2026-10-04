# =============================================================
# Student Grade Analyzer using R Vectors  (Interactive Web App)
# File: app.R
#
# FEATURES:
#  - Loads sample_upload.csv automatically on startup (falls back to a
#    small built-in sample list if that file isn't found)
#  - Add students manually (name + score form)
#  - Upload a CSV file (columns: Name, Score) to bulk-add/replace students
#  - Remove any student from the list
#  - Clear all students
#  - Adjustable pass mark (default 40)
#  - Download the full report as a CSV
#  - Live stats, bar chart, pie chart, tables
#  - NOTE: nothing is saved to disk between sessions -- every restart
#    reloads fresh from sample_upload.csv
#
# HOW TO RUN:
# 1. Open this file in RStudio
# 2. If needed, run once:  install.packages("shiny")
# 3. Click "Run App" (top-right of the script editor) or Ctrl+Shift+Enter
# =============================================================

library(shiny)

# ---------------------------------------------------------------
# STARTUP DATA
# No auto-save/auto-reload between sessions anymore. Every time the
# app starts, it loads fresh from sample_upload.csv (if present in
# the same folder). Falls back to a small built-in sample list if
# that file is missing or unreadable.
# ---------------------------------------------------------------
SAMPLE_FILE <- "sample_upload.csv"

fallback_data <- data.frame(
  ID    = 1:10,
  Name  = c("Alex", "Sam", "Jordan", "Taylor", "Morgan",
            "Casey", "Riley", "Drew", "Jamie", "Avery"),
  Score = c(85, 92, 67, 78, 55, 95, 48, 73, 88, 61),
  stringsAsFactors = FALSE
)

starting_data <- if (file.exists(SAMPLE_FILE)) {
  sample_csv <- tryCatch(read.csv(SAMPLE_FILE, stringsAsFactors = FALSE),
                         error = function(e) NULL)
  if (!is.null(sample_csv) && all(c("Name", "Score") %in% names(sample_csv)) && nrow(sample_csv) > 0) {
    data.frame(
      ID    = seq_len(nrow(sample_csv)),
      Name  = as.character(sample_csv$Name),
      Score = as.numeric(sample_csv$Score),
      stringsAsFactors = FALSE
    )
  } else {
    fallback_data
  }
} else {
  fallback_data
}

# ---------------------------------------------------------------
# UI
# ---------------------------------------------------------------
ui <- fluidPage(
  
  tags$head(
    tags$style(HTML("
      body { background-color: #f4f6f9; font-family: 'Segoe UI', Arial, sans-serif; }
      .title-banner {
        background: linear-gradient(90deg, #2c3e91, #4e73df);
        color: white; padding: 25px 30px; border-radius: 10px;
        margin-bottom: 25px;
      }
      .title-banner h1 { margin: 0; font-size: 28px; }
      .title-banner p { margin: 5px 0 0 0; opacity: 0.9; }
      .stat-box {
        background: white; border-radius: 10px; padding: 18px;
        text-align: center; box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        margin-bottom: 20px;
      }
      .stat-box h3 { margin: 0; font-size: 24px; color: #2c3e91; }
      .stat-box p { margin: 5px 0 0 0; color: #666; font-size: 13px; text-transform: uppercase; }
      .panel-card {
        background: white; border-radius: 10px; padding: 20px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.08); margin-bottom: 20px;
      }
      .panel-card h4 { margin-top: 0; color: #2c3e91; border-bottom: 2px solid #eef0fa; padding-bottom: 8px; }
      table.dataTable, table { width: 100% !important; }
      .btn-primary { background-color: #4e73df; border-color: #4e73df; }
      .btn-danger  { background-color: #d9534f; border-color: #d9534f; }
      hr { border-top: 1px solid #eef0fa; }
    "))
  ),
  
  div(class = "title-banner",
      h1("Student Grade Analyzer"),
      p("Add students manually or upload a CSV, then see live stats, charts, and grades")
  ),
  
  fluidRow(
    column(3, div(class = "stat-box", h3(textOutput("totalStudents")), p("Total Students"))),
    column(3, div(class = "stat-box", h3(textOutput("avgScore")), p("Average Score"))),
    column(3, div(class = "stat-box", h3(textOutput("highScore")), p("Highest Score"))),
    column(3, div(class = "stat-box", h3(textOutput("lowScore")), p("Lowest Score")))
  ),
  
  fluidRow(
    # ---------------- LEFT COLUMN: Controls ----------------
    column(4,
           div(class = "panel-card",
               h4("Add a Student"),
               textInput("nameInput", "Student Name", placeholder = "e.g. Priya"),
               numericInput("scoreInput", "Score (0-100)", value = 75, min = 0, max = 100),
               actionButton("addBtn", "Add Student", class = "btn-primary", width = "100%")
           ),
           div(class = "panel-card",
               h4("Upload Students (CSV)"),
               p(style = "color:#888; font-size:12px;",
                 "File must have two columns named 'Name' and 'Score'"),
               fileInput("csvUpload", NULL, accept = ".csv", buttonLabel = "Browse...", placeholder = "No file selected"),
               actionButton("uploadBtn", "Upload File", class = "btn-primary", width = "100%"),
               tags$div(style = "height: 10px;"),
               actionButton("clearAllBtn", "Clear Data", class = "btn-danger", width = "100%")
           ),
           div(class = "panel-card",
               h4("Remove a Student"),
               selectInput("removeSelect", "Select student to remove", choices = NULL),
               actionButton("removeBtn", "Remove Selected", class = "btn-danger", width = "100%")
           ),
           div(class = "panel-card",
               h4("Settings"),
               numericInput("passMark", "Pass Mark", value = 40, min = 0, max = 100),
               downloadButton("downloadReport", "Download Report (CSV)", class = "btn-primary", style = "width:100%; margin-top:5px;")
           )
    ),
    
    # ---------------- RIGHT COLUMN: Results ----------------
    column(8,
           fluidRow(
             column(6,
                    div(class = "panel-card",
                        h4("Score Distribution"),
                        div(style = "max-height: 340px; overflow-y: auto;",
                            plotOutput("barPlot"))
                    )
             ),
             column(6,
                    div(class = "panel-card",
                        h4("Grade Distribution"),
                        plotOutput("pieChart", height = "300px")
                    )
             )
           ),
           fluidRow(
             column(6,
                    div(class = "panel-card",
                        h4("Top & Bottom Performers"),
                        tableOutput("performerTable")
                    )
             ),
             column(6,
                    div(class = "panel-card",
                        h4("Pass / Fail Summary"),
                        tableOutput("passFailTable")
                    )
             )
           ),
           div(class = "panel-card",
               h4("Full Student Report"),
               tableOutput("reportTable")
           )
    )
  ),
  
  div(style = "text-align:center; color:#999; padding: 15px; font-size: 12px;",
      "Built in R using vector operations, ifelse() grading logic, and Shiny for the web interface.")
)

# ---------------------------------------------------------------
# SERVER
# ---------------------------------------------------------------
server <- function(input, output, session) {
  
  # rv$data holds the live student list (ID, Name, Score) for this session only
  rv <- reactiveValues(data = starting_data)
  
  # ---- Add a student ----
  observeEvent(input$addBtn, {
    req(input$nameInput != "", input$scoreInput != "")
    
    if (input$scoreInput < 0 || input$scoreInput > 100) {
      showNotification("Score must be between 0 and 100.", type = "error")
      return()
    }
    
    new_id <- ifelse(nrow(rv$data) == 0, 1, max(rv$data$ID) + 1)
    new_row <- data.frame(ID = new_id, Name = input$nameInput, Score = input$scoreInput,
                          stringsAsFactors = FALSE)
    rv$data <- rbind(rv$data, new_row)
    
    updateTextInput(session, "nameInput", value = "")
    updateNumericInput(session, "scoreInput", value = 75)
  })
  
  # ---- Upload CSV (only runs when "Upload File" is clicked, not just on browse) ----
  observeEvent(input$uploadBtn, {
    req(input$csvUpload)
    uploaded <- tryCatch(read.csv(input$csvUpload$datapath, stringsAsFactors = FALSE),
                         error = function(e) NULL)
    
    if (is.null(uploaded) || !all(c("Name", "Score") %in% names(uploaded))) {
      showNotification("CSV must contain 'Name' and 'Score' columns.", type = "error")
      return()
    }
    
    start_id <- ifelse(nrow(rv$data) == 0, 1, max(rv$data$ID) + 1)
    new_rows <- data.frame(
      ID    = start_id:(start_id + nrow(uploaded) - 1),
      Name  = as.character(uploaded$Name),
      Score = as.numeric(uploaded$Score),
      stringsAsFactors = FALSE
    )
    rv$data <- rbind(rv$data, new_rows)
    showNotification(paste("Added", nrow(uploaded), "students from CSV."), type = "message")
  })
  
  # ---- Clear all students ----
  observeEvent(input$clearAllBtn, {
    rv$data <- data.frame(ID = integer(0), Name = character(0), Score = numeric(0),
                          stringsAsFactors = FALSE)
  })
  
  # ---- Keep the "remove student" dropdown up to date ----
  observe({
    if (nrow(rv$data) == 0) {
      updateSelectInput(session, "removeSelect", choices = character(0))
    } else {
      choices <- setNames(rv$data$ID, paste0(rv$data$Name, " (", rv$data$Score, ")"))
      updateSelectInput(session, "removeSelect", choices = choices)
    }
  })
  
  # ---- Remove selected student ----
  observeEvent(input$removeBtn, {
    req(input$removeSelect)
    rv$data <- rv$data[rv$data$ID != as.integer(input$removeSelect), ]
  })
  
  # ---- Grades based on scores (vectorized ifelse) ----
  gradedData <- reactive({
    df <- rv$data
    if (nrow(df) == 0) return(df)
    df$Grade <- ifelse(df$Score >= 90, "A",
                       ifelse(df$Score >= 75, "B",
                              ifelse(df$Score >= 60, "C",
                                     ifelse(df$Score >= input$passMark, "D", "F"))))
    df
  })
  
  # ---- Stat boxes ----
  output$totalStudents <- renderText({ nrow(rv$data) })
  output$avgScore <- renderText({
    if (nrow(rv$data) == 0) return("-")
    round(mean(rv$data$Score), 2)
  })
  output$highScore <- renderText({
    if (nrow(rv$data) == 0) return("-")
    max(rv$data$Score)
  })
  output$lowScore <- renderText({
    if (nrow(rv$data) == 0) return("-")
    min(rv$data$Score)
  })
  
  # ---- Bar chart (horizontal, scrolls vertically when there are many students) ----
  output$barPlot <- renderPlot({
    df <- rv$data
    if (nrow(df) == 0) {
      plot.new(); text(0.5, 0.5, "No students added yet"); return()
    }
    df <- df[order(df$Score), ]  # ascending so the highest score ends up at the top
    par(mar = c(4, 9, 2, 3))     # extra left margin so long names aren't cut off
    bp <- barplot(df$Score, names.arg = df$Name, col = "#4e73df",
                  main = "", xlab = "Score", xlim = c(0, 105), border = NA,
                  horiz = TRUE, las = 1, cex.names = 0.8)
    abline(v = mean(df$Score), col = "#d9534f", lwd = 2, lty = 2)
    text(df$Score + 3, bp, labels = df$Score, cex = 0.7, adj = 0)
  }, height = function() { max(320, nrow(rv$data) * 22) })
  
  # ---- Pie chart ----
  output$pieChart <- renderPlot({
    df <- gradedData()
    if (nrow(df) == 0) {
      plot.new(); text(0.5, 0.5, "No students added yet"); return()
    }
    dist <- table(df$Grade)
    palette <- c(A = "#1e7e34", B = "#4e73df", C = "#f0ad4e", D = "#fd7e14", F = "#a71d2a")
    pie(dist, col = palette[names(dist)], main = "",
        labels = paste0(names(dist), " (", dist, ")"))
  })
  
  # ---- Top/bottom performer table ----
  output$performerTable <- renderTable({
    df <- rv$data
    if (nrow(df) == 0) return(data.frame(Message = "No students added yet"))
    data.frame(
      Type  = c("Top Performer", "Lowest Performer"),
      Name  = c(df$Name[which.max(df$Score)], df$Name[which.min(df$Score)]),
      Score = c(max(df$Score), min(df$Score))
    )
  }, striped = TRUE, bordered = TRUE)
  
  # ---- Pass/Fail table ----
  output$passFailTable <- renderTable({
    df <- rv$data
    if (nrow(df) == 0) return(data.frame(Message = "No students added yet"))
    passing <- df$Score >= input$passMark
    data.frame(
      Status = c("Passed", "Failed"),
      Count  = c(sum(passing), sum(!passing))
    )
  }, striped = TRUE, bordered = TRUE)
  
  # ---- Full report table ----
  output$reportTable <- renderTable({
    df <- gradedData()
    if (nrow(df) == 0) return(data.frame(Message = "No students added yet"))
    df <- df[order(-df$Score), c("Name", "Score", "Grade")]
    df
  }, striped = TRUE, bordered = TRUE, rownames = FALSE)
  
  # ---- Download report ----
  output$downloadReport <- downloadHandler(
    filename = function() paste0("student_report_", Sys.Date(), ".csv"),
    content = function(file) {
      df <- gradedData()
      write.csv(df[, c("Name", "Score", "Grade")], file, row.names = FALSE)
    }
  )
}

# ---------------------------------------------------------------
# RUN THE APP
# ---------------------------------------------------------------
shinyApp(ui = ui, server = server)