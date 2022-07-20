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
  count_preset_val <- reactiveVal(NULL)
  observeEvent(input$count_preset, {
    out <- input$count_preset
    count_preset_val(out)
  })
  
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
  
  callModule(
    map_occ,
    "map_occ",
    count_preset_val,
    data_occ
  )
  
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