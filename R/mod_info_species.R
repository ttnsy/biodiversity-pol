# UI ----------------------------------------------------------------------
info_species_ui <- function(id){
  ns <- NS(id)
  
  uiOutput(ns("info_species_out"))
}

# Server ------------------------------------------------------------------
info_species <- function(input, output, session, data_occ){
  output$info_species_out <- renderUI({
    req(data_occ())
    
    summ <- data_occ() %>% 
      left_join(multimedia_clean) 
    
    summ_img <- summ[!is.na(summ$accessURI),c("accessURI")][1]
    
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
  
}