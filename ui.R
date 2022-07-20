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
        "input_occ",
        "View occurence by:",
        choices = c("vernacularName","scientificName")
      ),
      uiOutput("input_name")
    ),
    mainPanel(
      class = "box",
      verticalLayout(
        conditionalPanel(
          condition = "input.selectName != ''",
          radioButtons(
            "count_preset",
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


