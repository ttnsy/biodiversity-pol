function(input, output, session){
  
  # Initial input -----------------------------------------------------------
  observeEvent(input$preset_col_name, {
    output$preset_name_ui <- renderUI({
      selectInput(
        "selectName",
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
      "selectName",
      label = label,
      choices = choices,
      selected = "",
      server = TRUE
    )
  })
  
  # Data output -------------------------------------------------------------
  count_preset_val <- reactiveVal(NULL)
  observeEvent(input$count_preset, {
    out <- input$count_preset
    count_preset_val(out)
  })
  
  data_occ <- reactive({
    req(input$selectName)
    
    if(input$preset_col_name == "vernacularName"){
      col <- sym("vernacularName")
    } else {
      col <- sym("scientificName")
    }
    
    out <- occurence_clean %>% 
      filter(!!col == input$selectName)
    
    return(out)
  })
  
  observeEvent(input$selectName, {
    req(data_occ())
    
    if(input$selectName != ""){
      callModule(info_species, "info_species", data_occ)
      
    }
  })
  
  # Module calls ------------------------------------------------------------
  callModule(
    map_occ,
    "map_occ",
    count_preset_val,
    data_occ
  )
  
  callModule(
    plot_timeline,
    "plot_timeline",
    count_preset_val,
    data_occ
  )
  
}