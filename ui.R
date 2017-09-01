#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Personal Savings Data"),
  
  # Sidebar with input boxes for each predictor variable
  sidebarLayout(
    sidebarPanel(
       selectInput("pop15",
                   "% Population Under 15:",
                   seq(10, 65, 1)),
                  
       selectInput("pop75",
                    "% Population Over 75:",
                    seq(0, 10, .5)),
                   
       selectInput("ddpi",
                    "Per Captia Disposable Income Growth",
                    seq(0, 25, .5)),
                   
       actionButton("button","Calculate" )
    ),
    
    # Show estimated 
    mainPanel(
        tabsetPanel(
            tabPanel("Application",
               h3("Predicted Savings Ratio"),
               textOutput("PredSr"),
               h3("Countries with Similar Profile"),
               tableOutput("countries"),
               plotOutput("map")
            ),
            tabPanel("Documentation",
                includeHTML("./shiny_doc.html")
            )
        )
    )
  )
))
