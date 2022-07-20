header <- dashboardHeader(
  disable = TRUE
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    radioButtons(
      "input_occ",
      "View occurence by:",
      choices = c("vernacularName","scientificName")
    ),
    uiOutput("input_name")
  )
)

body <- dashboardBody(
  fluidPage(
    fluidRow(
      radioButtons(
        "count_preset",
        label = "Show observations by:",
        choices = c("Total Occurence", "Total individualCount"),
        inline = T
      )
    ),
    fluidRow(
      box(
        width = 6,
        leafletOutput("map_occ"),
        plotlyOutput("plot_timeline")
      )
    )
  )
)

dashboardPage(
  header = header,
  body = body,
  sidebar = sidebar
)
