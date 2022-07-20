function(input, output, session){
  
  # Initial input -----------------------------------------------------------
  observeEvent(input$input_occ, {
    output$input_name <- renderUI({
      selectInput(
        "selectName",
        label = "",
        choices = character(0),
        multiple = TRUE
      )
    })
    
    if(input$input_occ == "vernacularName"){
      updateSelectizeInput(
        session,
        "selectName",
        label = "Select vernacularName:",
        choices = list_vernacularName,
        server = TRUE
      )
    } else {
      updateSelectizeInput(
        session,
        "selectName",
        label = "Select scientificName:",
        choices = list_scientificName,
        server = TRUE
      )
    }
  })
  
  # Data output -------------------------------------------------------------
  data_occ <- reactive({
    if(input$input_occ == "vernacularName"){
      col <- sym("vernacularName")
    } else {
      col <- sym("scientificName")
    }
    
    out <- df_occurence %>% 
      filter(!!col == input$selectName)
    
    return(out)
  })
  
  ## Map
  data_occ_summary <- reactive({
    out <- data_occ() %>% 
      group_by(NAME_1, NAME_2) %>% 
      summarise(
        total_occurence = n(),
        total_individualCount = sum(individualCount)
      ) %>% 
      ungroup()
    
    return(out)
  })
  
  output$map_occ <- renderLeaflet({
    data <- data_occ_summary()
    
    data <- data %>% 
      left_join(shapefile) %>% 
      st_as_sf()
    
    pal <- colorNumeric(palette = "YlOrRd", domain =  if(input$count_preset == "Total Occurence") data$total_occurence else data$total_individualCount)
    
    labels <- glue::glue(
      "<b>{data$NAME_2}, {data$NAME_1}</b><br>
    Total Occurence: {data$total_occurence} <br>
    Total individualCount: {data$total_individualCount}"
    ) %>% 
      lapply(htmltools::HTML)
    
    leaflet(data) %>% # create map widget
      addTiles() %>% # add basemap
      addPolygons(
        label = labels,
        fillColor = if(input$count_preset == "Total Occurence") ~pal(total_occurence) else ~pal(total_individualCount) ,
        fillOpacity = .8,
        weight = 2,
        color = "darkgray",
        highlight = highlightOptions(
          color = "black",
          bringToFront = TRUE,
          opacity = 0.8
        ), 
        layerId = ~NAME_2
      )
  })
  
  
  ## Timeline
  output$plot_timeline <- renderPlotly({
    plot_df <- data_occ() %>% 
      mutate(
        year = year(eventDate)
      ) %>% 
      group_by(year) %>% 
      summarise(
        occurence = n()
      ) %>% 
      ungroup() %>% 
      mutate(
        text = glue("<b>{year}:</b> {occurence} {ifelse(occurence == 1, 'Observation', 'Observations')}")
      )
    
    p <- ggplot(plot_df, aes(x = year, y = occurence))+
      geom_col(fill = "#dcd7ce", alpha = .5)+
      geom_line(color = "tomato4", alpha = .8)+
      geom_point(color = "#282e2a", aes(text = text))+
      labs(x = NULL, y = NULL) +
      theme_minimal()
    
    p %>% 
      ggplotly(tooltip = "text") %>%
      layout(
        hovermode = 'x'
      ) %>%
      plotly::config(displayModeBar = F)
  })
  
#   map_click_data <- reactiveVal(NULL)
#   
#   observeEvent(input$map_occ_shape_click, {
#     #capture the info of the clicked polygon
#     click <- input$map_occ_shape_click
#     out <- data_occ() %>% 
#       filter(NAME_2 == click$id)
#     map_click_data(out)
#     
#     x <- map_click_data()
#     print(x)
# })
  
  
}