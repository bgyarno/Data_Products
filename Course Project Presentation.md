Shiny App Presentation
========================================================
author: Brian Yarno
date: 8/29/2017
autosize: true


Overview
========================================================
This application predicts a hypothetical country's Savings Ratio based the values of three variables the user defines.  Predictions are based on the Life Cycle Savings dataset in the R library.  
**Inputs**
- % of Population 15 and Younger
- % of Population 75 and Older
- Disposable Income Growth Rate  

**Outputs**
- Savings Ratio Prediction
- List of Countries with Similar Profile
- Map Highlighting Location of Similar Countries

Methods: Savings Ratio Prediction
========================================================

- Linear regression model is fit on 50 observations in dataset   
    - model uses all variables in the dataset except dpi, as it was found to be an insignificant predictor.

```r
lm(sr ~ pop15 + pop75 + ddpi, data = LifeCycleSavings)
```

```

Call:
lm(formula = sr ~ pop15 + pop75 + ddpi, data = LifeCycleSavings)

Coefficients:
(Intercept)        pop15        pop75         ddpi  
    28.1247      -0.4518      -1.8354       0.4278  
```

Methods: Determining Similar Countries
========================================================
- Matching countries are determined by using the K-Means clustering algorithm with 10 clusters
- Each country in the dataset is assigned to a cluster based on the values of variables inluced in the linear predction model.  
- A cluster is then assigned to the hypothetical country  
**Map Output Example**

![plot of chunk map](Course Project Presentation-figure/map-1.png)

Server Function Code
========================================================

```r
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
```

