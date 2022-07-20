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
    req(input$selectName)
    
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
    req(data_occ())
    
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
    req(data_occ_summary())
    
    data <- data_occ_summary() %>% 
      mutate(NAME_2_ID = row_number())
    
    data <- data %>% 
      left_join(shapefile) %>% 
      st_as_sf()
    
    pal <- colorNumeric(palette = "YlOrRd", domain =  if(input$count_preset == "Occurence") data$total_occurence else data$total_individualCount)
    
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
        fillColor = if(input$count_preset == "Occurence") ~pal(total_occurence) else ~pal(total_individualCount) ,
        fillOpacity = .8,
        weight = 2,
        color = "darkgray",
        highlight = highlightOptions(
          color = "black",
          bringToFront = TRUE,
          opacity = 0.8
        ), 
        layerId = ~NAME_2
      ) %>% 
      addLegend(
        pal = pal,
        values =  if(input$count_preset == "Occurence") ~total_occurence else ~total_individualCount,
        opacity = 1,
        title = glue("Total {input$count_preset}s"),
        position = "bottomright"
      )
  })
  
  ## Timeline
  output$plot_timeline <- renderPlotly({
    plot_df <- data_occ() %>% 
      mutate(
        year = year(eventDate)
      ) 
    
    if(input$count_preset == "Occurence"){
      lab <- "Occurence"
      
      plot_df <- plot_df %>% 
        group_by(year) %>%
        summarise(
          values = n()
        ) %>% 
        ungroup()
      
    } else {
      lab <- "individualCount"
      
      plot_df <- plot_df %>%
        group_by(year)  %>%
        summarise(
          values = sum(individualCount)
        ) %>% 
        ungroup()
    }
    
    plot_df <- plot_df %>%
      mutate(
        text = glue("<b>{year}:</b> {values} {ifelse(values == 1, lab, paste0(lab,'s'))}")
      )
    
    p <- ggplot(plot_df, aes(x = year, y = values))+
      geom_col(fill = "#dcd7ce", alpha = .5)+
      geom_line(color = "tomato4", alpha = .8)+
      geom_point(color = "#282e2a", aes(text = text))+
      labs(x = NULL, y = paste0('Total ', lab,'s')) +
      theme_minimal()
    
    p %>% 
      ggplotly(tooltip = "text") %>%
      layout(
        hovermode = 'x'
      ) %>%
      plotly::config(displayModeBar = F)
  })

  observeEvent(input$map_occ_shape_click, {
    click <- input$map_occ_shape_click
    
    data <- data_occ() %>%
      filter(NAME_2 == click$id) %>% 
      mutate(
        eventTime = ifelse(
          is.na(eventTime) | eventTime == '',
          'Unknown',
          eventTime
        )
      )
    
    labels <- glue::glue(
      "<b>Observation Date:</b> {data$eventDate}<br>
      <b>Observation Time:</b> {data$eventTime}<br>
      <b>individualCount:</b> {data$individualCount}"
    ) %>% 
      lapply(htmltools::HTML)
    
    showModal(
      modalDialog(
        title = "Observation points:",
        renderLeaflet({
          leaflet(data) %>% 
            addTiles() %>% 
            addMarkers(
              label = labels
            )
        }),
        footer = tagList(
          modalButton("Close")
        )
      )
    )
})
  
  
}