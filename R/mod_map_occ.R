# UI ----------------------------------------------------------------------
map_occ_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns("map_message")),
    leafletOutput(ns("map_occ_out"))
  )
}

# Server ------------------------------------------------------------------
map_occ <- function(input, output, session, count_preset_val, data_occ){
  
  observeEvent(data_occ(), {
    output$map_message <- renderUI({
      HTML("<i>*Click on the area to view the observation's points!</i>")
    })
  })
  
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
  
  output$map_occ_out <- renderLeaflet({
    req(count_preset_val())
    
    count_preset <- count_preset_val()
    
    data <- data_occ_summary() %>% 
      mutate(NAME_2_ID = row_number())
    
    data <- data %>% 
      left_join(shapefile) %>% 
      st_as_sf()
    
    pal <- colorNumeric(palette = "YlOrRd", domain =  if(count_preset == "Occurence") data$total_occurence else data$total_individualCount)
    
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
        fillColor = if(count_preset == "Occurence") ~pal(total_occurence) else ~pal(total_individualCount) ,
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
        values =  if(count_preset == "Occurence") ~total_occurence else ~total_individualCount,
        opacity = 1,
        title = glue("Total {count_preset}s"),
        position = "bottomright"
      )
  })
  
  
  observeEvent(input$map_occ_out_shape_click, {
    click <- input$map_occ_out_shape_click
    
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