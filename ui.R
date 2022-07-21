fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  fluidRow(
    headerPanel("Poland Biodiversity Observations")
  ),
  br(),
  sidebarLayout(
  # Sidebar -----------------------------------------------------------------
    sidebarPanel(
      radioButtons(
        "input_occ",
        "View occurence by:",
        choices = c("vernacularName","scientificName")
      ),
      selectInput(
        "selectName",
        label = "",
        choices = character(0)
      ),
      uiOutput("summary_ui")
    ),
  # Main --------------------------------------------------------------------
    mainPanel(
      class = "box",
      verticalLayout(
        uiOutput("count_preset_ui"),
        map_occ_ui("map_occ"),
        br(),
        plot_timeline_ui("plot_timeline")
      ) 
    )
  )
)


