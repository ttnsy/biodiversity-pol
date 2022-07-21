function(input, output, session){
  
  # Initial input -----------------------------------------------------------
  observeEvent(input$input_occ, {
    if(input$input_occ == "vernacularName"){
      updateSelectizeInput(
        session,
        "selectName",
        label = "Select vernacularName:",
        choices = list_vernacularName,
        selected = "",
        server = TRUE
      )
    } else {
      updateSelectizeInput(
        session,
        "selectName",
        label = "Select scientificName:",
        choices = list_scientificName,
        selected = "",
        server = TRUE
      )
    }
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
    if(input$selectName != ""){
      output$summary_ui <- renderUI({
        req(data_occ())
        
        summ <- data_occ() %>% 
          left_join(multimedia_clean) 
        
        
        summ_img <- summ[!is.na(summ$accessURI),c("accessURI")][1]
        print(summ)
        print(summ_img)
        
        
        summ_text <- summ %>%
          distinct(taxonRank, kingdom, family, scientificName, vernacularName) %>%
          mutate(across(.fns = ~ifelse(is.na(.) | . == '', "-", .)))

        summ_text <- paste0("<b>",colnames(summ_text), "</b>",": ", summ_text, collapse = "<br>")

        HTML(
          glue(
            '<hr>
            <img src="{summ_img}" class="responsive">
            <br>
            <br>
            {summ_text}'
          )
        )
      })
      
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