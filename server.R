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