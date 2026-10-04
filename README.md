# 📊 Student Grade Analyzer using R Vectors (Interactive Web App)

🔗 **Live App:** [Open Student Grade Analyzer](https://prathiksha-v123.shinyapps.io/Student_Grade_Analyser/)

An interactive **R Shiny web app** for analyzing student scores — add
students manually, upload a CSV, remove entries, adjust the pass mark,
and download the final report. Everything updates live.

## 📌 Features

- 📁 **Loads `sample_upload.csv` automatically on startup**, so the app
  always opens with real sample data instead of an empty screen. If
  that file is missing, it falls back to a small built-in sample list.
- 🚫 **No data is saved between sessions.** Every restart reloads
  fresh from `sample_upload.csv` — nothing is written to disk in the
  background, so there's no stale save file to worry about.
- ➕ **Add students manually** through a simple form
- 📤 **Upload a CSV** (`Name`, `Score` columns) to bulk-add students —
  browsing a file just stages it; nothing is added until you click
  **Upload File**
- 🗑️ **Clear Data** instantly empties the whole list (shows a genuine
  empty state, not a reload of anything)
- ❌ **Remove any individual student** from the list
- 🎚️ **Adjustable pass mark** (default: 40)
- 📥 **Download the final report** as a CSV
- 📊 Live **horizontal, scrollable bar chart** of scores (grows with
  the number of students, so long lists stay readable) + pie chart of
  grade distribution
- 🏆 Top/bottom performer and pass/fail summary tables
- 🧮 Built entirely on core **R vector operations** — no database needed

## 🗂️ Project Structure

```
student-grade-analyzer-v2/
├── README.md
├── app.R              # the entire app (data handling + UI + logic)
└── sample_upload.csv  # default sample data loaded on startup
```

## ▶️ How to Run

1. Open `app.R` in RStudio
2. Install Shiny once, if you haven't already:
   ```r
   install.packages("shiny")
   ```
3. Click **"Run App"** (top-right of the script editor) or press
   **Ctrl+Shift+Enter**
4. Click **"Open in Browser"** in the popup to view it as a full web page

### Try it out
- The app starts with the students listed in `sample_upload.csv`
  already loaded
- Add a new student using the form on the left
- Browse a CSV file, then click **Upload File** to bulk-add its
  students to the list
- Change the **Pass Mark** and watch the Pass/Fail table update instantly
- Scroll the Score Distribution chart to see every student when the
  list is long
- Remove a single student using the dropdown, or click **Clear Data**
  to empty the whole list
- Click **Download Report (CSV)** to save the final results

## 🧠 Key R Concepts Used

- Vector & data frame operations (`rbind()`, `data.frame()`, indexing)
- Vectorized conditional logic (`ifelse()`) for grading
- Logical vectors for filtering (`Score >= passMark`)
- Aggregate functions (`mean()`, `max()`, `min()`)
- Locating values (`which.max()`, `which.min()`)
- Frequency tables (`table()`)
- Reactive programming with Shiny (`reactiveValues`, `observeEvent`, `reactive`)
- File I/O (`read.csv()`, `downloadHandler`)

## 🚀 Future Improvements

- Edit a student's score inline instead of remove + re-add
- Add subject-wise scores and GPA calculation
- Optional persistent storage (save/load student lists to a file on demand)
- Deploy for free on [shinyapps.io](https://www.shinyapps.io/) to share a live link
