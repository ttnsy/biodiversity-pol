# UI ----------------------------------------------------------------------
plot_timeline_ui <- function(id){
  ns <- NS(id)
  
  plotlyOutput(ns("plot_timeline_out"))
}

# Server ------------------------------------------------------------------
plot_timeline <- function(input, output, session, preset_count_val, data_occ){

  output$plot_timeline_out <- renderPlotly({
    req(preset_count_val())
    
    preset_count <- preset_count_val()
    
    plot_df <- data_occ() %>% 
      mutate(
        year = year(eventDate)
      ) 
    
    if(preset_count == "Occurence"){
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
    
    plot <- ggplot(plot_df, aes(x = year, y = values))+
      geom_col(fill = "#c5d1bc", alpha = .5)+
      geom_line(color = "tomato4", alpha = .8)+
      geom_point(color = "#282e2a", aes(text = text))+
      labs(
        x = NULL,
        y = paste0('Total ', lab,'s'),
        title = "Yearly Observations Trend:"
      ) +
      theme_minimal(
        base_family = "Quicksand",
      )+
      theme(title = element_text(family = "Merriweather"))
    
    plot %>% 
      ggplotly(tooltip = "text") %>%
      layout(
        hovermode = 'x'
      ) %>%
      plotly::config(displayModeBar = F)
  })

}