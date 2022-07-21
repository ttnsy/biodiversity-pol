function(input, output, session){
  
  # Initial input -----------------------------------------------------------
  observeEvent(input$input_occ, {
    if(input$input_occ == "vernacularName"){
      updateSelectizeInput(
        session,
        "selectName",
        label = "Select vernacularName:",
        choices = c("",list_vernacularName),
        selected = "",
        server = TRUE
      )
    } else {
      updateSelectizeInput(
        session,
        "selectName",
        label = "Select scientificName:",
        choices = c("",list_scientificName),
        selected = "",
        server = TRUE
      )
    }
  })
  
  observeEvent(input$selectName, {
    output$count_preset_ui <- renderUI({
      if(input$selectName != ""){
        radioButtons(
          "count_preset",
          label = "Total observations by:",
          choices = c("Occurence", "individualCount"),
          inline = T
        )
      } else {
        HTML("Please select at least one species!")
      }
    })
    
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
    
    out <- occurence_clean %>% 
      filter(!!col == input$selectName)
    
    return(out)
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