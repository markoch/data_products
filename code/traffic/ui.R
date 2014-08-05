library(shiny)
library(xlsx)

shinyUI(navbarPage("Traffic Accidents in Germany",
   tabPanel("Plot",
   fluidPage(theme = "bootstrap.css",
    fluidRow(
        column(3,
               selectInput("type", "Vehicle:", selected = "Passenger cars",
                    list(
                        "Agricultural tractors",
                        "Bicycles",
                        "Buses",
                        "Mopeds",
                        "Motorcycles",
                        "Other cars",
                        "Other people",
                        "Other/Unknown",
                        "Passenger cars",
                        "Pedestrians",
                        "Trucks"
                    ))),
        column(4,
            selectInput("event", "Event:",
                    list(
                        "All",
                        "Drunk Driving",
                        "Driving under the influence of drugs",
                        "Fatigue / Other physical or mental impairments",
                        "Wrong use of road",
                        "High speed",
                        "Distance error",
                        "Overtaking error",
                        "Passing error",
                        "Wrong side by side driving",
                        "Violate right of way",
                        "Wrong turn / Reversing error / Wrong start up",
                        "Misconduct to pedestrians",
                        "Wrong parking",
                        "Inadequate lighting",
                        "Overload",
                        "Other faults of driver",
                        "Technical faults",
                        "Misconduct of pedestrians passing the road",
                        "Other faults of pedestrians"
                         )),
            checkboxInput("showTotals", "Show totals", TRUE)
        )
    ),
    hr(),
    fluidRow(
        tabsetPanel(
            tabPanel("Graph", plotOutput("graphPlot")),
            tabPanel("Data", dataTableOutput("table"))
    )
    ))),
    tabPanel("About",
             mainPanel(
                 includeMarkdown("about.md")
             )
    )
    
))