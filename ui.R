fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  fluidRow(
    headerPanel("Poland Biodiversity Observations")
  ),
  br(),
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        "preset_col_name",
        "View species by:",
        choices = c("vernacularName","scientificName")
      ),
      uiOutput("preset_name_ui"),
      info_species_ui("info_species")
    ),
    mainPanel(
      class = "box",
      verticalLayout(
        conditionalPanel(
          condition = "input.preset_name == ''",
          p("Choose a species to start!")
        ),
        conditionalPanel(
          condition = "input.preset_name != ''",
          radioButtons(
            "preset_count",
            label = "Total observations by:",
            choices = c("Occurence", "individualCount"),
            inline = T
          )
        ),
        map_occ_ui("map_occ"),
        br(),
        plot_timeline_ui("plot_timeline")
      ) 
    )
  )
)


