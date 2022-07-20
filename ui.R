fluidPage(
  headerPanel("Poland Biodiversity Observations"),
  
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
        plotlyOutput("plot_timeline")
      ) 
    )
  )
)


