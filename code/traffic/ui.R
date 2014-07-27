library(shiny)
library(xlsx)

shinyUI(fluidPage(theme = "bootstrap.css",
    fluidRow(headerPanel("Traffic Accidents in Germany")),
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
            tabPanel("Data", dataTableOutput("table")),
            tabPanel("Help", 
                     h4("Project"), 
                     p("This project has been developed as part of ", 
                       a(href="https://www.coursera.org/course/devdataprod","Developing Data Products"), "class. ",
                     "More information about the project can be found at:",  
                       a(href="http://rpubs.com/MarcoRPubs/23938","http://rpubs.com/MarcoRPubs/23938")
                     ),
                     h4("Data Source"), p(
                "Download the traffic accident data 'Unfallbeteiligte: Deutschland, Jahre, Art der Verkehrsbeteiligung, 
Fehlverhalten der Fahrzeugführer und Fußgänger' (only available in German) from the 
GENESIS-Online database."),
                p(a(href="https://www-genesis.destatis.de/genesis/online/link/tabellen/46241*",
                    "https://www-genesis.destatis.de/genesis/online/link/tabellen/46241*")),
            p("(C)opyright ",a(href="https://www.destatis.de/EN/Homepage.html","Statistisches Bundesamt"),
              ", Wiesbaden 2014"), 
            p("Data downloaded: Jul. 20th, 2014")
        )
    )
)))
