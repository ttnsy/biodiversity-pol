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
    
    summ_img <- summ[!is.na(summ$accessURI),c("accessURI", "rightsHolder")][1]

    if(!is.na(summ_img$accessURI)){
      summ_img <- glue(
        '<figure>
          <img src="{summ_img$accessURI}" class="responsive">
          <figcaption><i>Image rights by {summ_img$rightsHolder}</i></figcaption>
        </figure>'
      )
    } else {
      summ_img <- "<i>Sorry, we don't have any image related to the selected species at the moment!</i>"
    }
    
    summ_text <- summ %>%
      distinct(taxonRank, kingdom, family, scientificName, vernacularName) %>%
      mutate(across(.fns = ~ifelse(is.na(.) | . == '', "-", .)))
    
    summ_text <- paste0("<b>",colnames(summ_text), "</b>",": ", summ_text, collapse = "<br>")
    
    HTML(
      glue(
        '<hr>
        {summ_img}
        <br>
        <br>
        {summ_text}'
      )
    )
  })
  
}