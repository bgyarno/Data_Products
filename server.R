#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(clue)
library(mapdata)
# Define server logic required to create prediction
data("LifeCycleSavings")

set.seed(1234)
model <- with(LifeCycleSavings, lm(sr ~ pop15 + pop75 + ddpi, data = LifeCycleSavings))
clust <- kmeans(LifeCycleSavings[names(LifeCycleSavings) %in% c("pop15", "pop75", "ddpi", "sr")], 10)

shinyServer(function(input, output) {
    
    prediction <- eventReactive(input$button,{
    
        return(predict(model, newdata = data.frame(
            pop15 = as.numeric(input$pop15), 
            pop75 = as.numeric(input$pop75), 
            ddpi = as.numeric(input$ddpi)
            )
        ))
    })
    
    similar <- eventReactive(input$button, {
        
        prediction <- predict(model, newdata = data.frame(
            pop15 = as.numeric(input$pop15), 
            pop75 = as.numeric(input$pop75), 
            ddpi = as.numeric(input$ddpi)))
        
        cluster_ids <- cl_predict(clust, newdata = data.frame(
            pop15 = as.numeric(input$pop15), 
            pop75 = as.numeric(input$pop75), 
            ddpi = as.numeric(input$ddpi), 
            sr = prediction))
        
        return(names(clust$cluster[clust$cluster == cluster_ids]))
    })
    
    country_table <- eventReactive(input$button, {
        
        filter <- data.frame(LifeCycleSavings[row.names(LifeCycleSavings) %in% similar(), names(LifeCycleSavings) %in% c("pop15", "pop75", "ddpi", "sr")])
        filter <- cbind(data.frame(country = row.names(filter)), filter)
        names(filter) <- c("Country", "Savings Ratio", "% Pop 15 & Younger", "% Pop 75 & Older", "Disposable Income Growth Rate")
        
        return(filter)
    })
    
    output$PredSr <- renderText(max(0, prediction()))
    
    output$countries <- renderTable(country_table()) 
    
    output$map <- renderPlot({
        countries <- map('world', names = TRUE, plot = FALSE)
        antarctica <- grep("^Antarctica", countries)
        countries <- countries[-antarctica]
        map('world', regions = countries)
        map('world', regions = similar(), fill = TRUE, col = "red", add = TRUE)
    })
})
