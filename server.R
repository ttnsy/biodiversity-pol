function(input, output, session){
  
  # Initial input -----------------------------------------------------------
  observeEvent(input$input_occ, {
    if(input$input_occ == "vernacularName"){
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
  
  data_occ <- reactive({
    req(input$selectName)
    
    if(input$input_occ == "vernacularName"){
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

      output$count_preset_ui <- renderUI({
        radioButtons(
          "count_preset",
          label = "Total observations by:",
          choices = c("Occurence", "individualCount"),
          inline = T
        )
      })
    } else {
      output$count_preset_ui <- renderUI({
        HTML("Please select at least one species!")
      })
    }
  })
  
  count_preset_val <- reactiveVal(NULL)
  
  observeEvent(input$count_preset, {
    out <- input$count_preset
    count_preset_val(out)
  })
  
  # Module calls ------------------------------------------------------------
  observeEvent(data_occ(), {
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
  })
  
}