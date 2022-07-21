function(input, output, session){
  
  # Initial input -----------------------------------------------------------
  observeEvent(input$preset_col_name, {
    output$preset_name_ui <- renderUI({
      selectInput(
        "preset_name",
        label = "",
        choices = character(0)
      )
    })
    
    if(input$preset_col_name == "vernacularName"){
      label <- "Select vernacularName:"
      choices <- list_vernacularName
    } else {
      label <-  "Select scientificName:"
      choices <-  list_scientificName
    }
    
    updateSelectizeInput(
      session,
      "preset_name",
      label = label,
      choices = choices,
      selected = "",
      server = TRUE
    )
  })
  
  # Data output -------------------------------------------------------------
  preset_count_val <- reactiveVal(NULL)
  observeEvent(input$preset_count, {
    out <- input$preset_count
    preset_count_val(out)
  })
  
  data_occ <- reactive({
    req(input$preset_name)
    
    if(input$preset_col_name == "vernacularName"){
      col <- sym("vernacularName")
    } else {
      col <- sym("scientificName")
    }
    
    out <- occurence_clean %>% 
      filter(!!col == input$preset_name)
    
    return(out)
  })
  
  observeEvent(input$preset_name, {
    req(data_occ())
    
    if(input$preset_name != ""){
      callModule(info_species, "info_species", data_occ)
      
    }
  })
  
  # Module calls ------------------------------------------------------------
  callModule(
    map_occ,
    "map_occ",
    preset_count_val,
    data_occ
  )
  
  callModule(
    plot_timeline,
    "plot_timeline",
    preset_count_val,
    data_occ
  )
  
}