library(shiny)
library(xlsx)
library(gridExtra)
library(reshape)
library(ggplot2)

fileSrc <- "46241-0009.xlsx"
header <- c("Type", "EventType", 2008, 2009, 2010, 2011, 2012, 2013)
years <- c(2008, 2009, 2010, 2011, 2012, 2013)
columnsToRead <- c(2:8)

getData <- function(startRow, endRow, name) {
    #read from excel file
    myData <- read.xlsx(fileSrc, 1, stringsAsFactors=F, startRow = startRow, endRow = endRow, colIndex=columnsToRead)
    #clean up
    myData$Type <- name
    myData <- myData[,c(8,1:7)]
    myData[3:8][myData[3:8]=="-"] <- 0
    names(myData) <- header
    #fix data types
    myData$"2008" <-as.numeric(myData$"2008")
    myData$"2009" <-as.numeric(myData$"2009")
    myData$"2010" <-as.numeric(myData$"2010")
    myData$"2011" <-as.numeric(myData$"2011")
    myData$"2012" <-as.numeric(myData$"2012")
    myData$"2013" <-as.numeric(myData$"2013")
    
    return(myData)
}

# Read event type information
startRow <- 7
endRow <- 26
cause.Data <- read.xlsx(fileSrc, 1, stringsAsFactors=F, startRow = startRow, endRow = endRow, colIndex=2)
names(cause.Data) <- "EventType"

# Read data
mofa.Data <- getData(7,26,"Mopeds")                         # Mofa
motorcycle.Data <- getData(26,45, "Motorcycles")            # Motorrad
pkw.Data <- getData(45,64, "Passenger cars")                # PKW
lpkw.Data <- getData(64,83, "Buses")                        # Kraftomnibus
lkw.Data <- getData(83,102, "Trucks")                       # Güterkraftfahrzeug
land.Data <- getData(102, 121, "Agricultural tractors")     # Landwirtschaftliche Zugmaschine
otherCars.Data <- getData(121, 140, "Other cars")           # Übrige Kraftfahrzeuge
bicycle.Data <- getData(140, 159, "Bicycles")               # Fahrrad
other.Data <- getData(159, 178, "Other/Unknown")            # Andere Fahrzeuge
pedestrian.Data <- getData(178, 197, "Pedestrians")         # Fußgänger
people.Data <- getData(197, 217, "Other people")            # Andere Personen

#calculate the complete data set
data <- rbind(
    mofa.Data, motorcycle.Data, pkw.Data, lpkw.Data, lkw.Data, land.Data, 
    otherCars.Data, bicycle.Data, other.Data, pedestrian.Data, people.Data)
# translate events
data$EventType[data$EventType=="Alkoholeinfluss"] <- "Drunk Driving"
data$EventType[data$EventType=="Einfluss and. berausch. Mittel (z.B. Drogen u.Ä.)"] <- "Driving under the influence of drugs"
data$EventType[data$EventType=="Übermüdung, sonstige körperliche/geistige Mängel"] <- "Fatigue / Other physical or mental impairments"
data$EventType[data$EventType=="Falsche Straßenbenutzung"] <- "Wrong use of road"
data$EventType[data$EventType=="Nicht angepasste Geschwindigkeit"] <- "High speed"
data$EventType[data$EventType=="Abstandsfehler"] <- "Distance error"
data$EventType[data$EventType=="Fehler beim Überholen/überholt werden"] <- "Overtaking error"
data$EventType[data$EventType=="Fehler beim Vorbeifahren"] <- "Passing error"
data$EventType[data$EventType=="Fehler beim Nebeneinanderfahren"] <- "Wrong side by side driving"
data$EventType[data$EventType=="Missachtung der Vorfahrt, des Vorrangs"] <- "Violate right of way"
data$EventType[data$EventType=="Fehler b.Abbiegen,Wenden,Rückwärtsf.,Ein-u.Anfahr."] <- "Wrong turn / Reversing error / Wrong start up"
data$EventType[data$EventType=="Falsches Verhalten gegenüber Fußgängern"] <- "Misconduct to pedestrians"
data$EventType[data$EventType=="Unzul. Halten/Parken, mangelnde Verkehrssicherung"] <- "Wrong parking"
data$EventType[data$EventType=="Nichtbeachten der Beleuchtungsvorschriften"] <- "Inadequate lighting"
data$EventType[data$EventType=="Überladung,-besetzung,unzureich. gesicherte Ladung"] <- "Overload"
data$EventType[data$EventType=="Andere Fehler beim Fahrzeugführer"] <- "Other faults of driver"
data$EventType[data$EventType=="Technische Mängel"] <- "Technical faults"
data$EventType[data$EventType=="Falsches Verhalten d.Fußg. b.Überschr. d.Fahrbahn"] <- "Misconduct of pedestrians passing the road"
data$EventType[data$EventType=="Sonstige Fehler der Fußgänger"] <- "Other faults of pedestrians"

shinyServer(
    function(input, output) {
        output$graphPlot <- renderPlot({
            if (input$event == "All") {
                graphDataNew <- subset(data, data$Type==input$type)
                graphDataNew$Type <- NULL
                graphDataNew <- melt(graphDataNew, id=c("EventType"))
                names(graphDataNew) <- c("EventType","Year", "Accidents")
                
                p1 <- ggplot(graphDataNew, aes(x=Year, y=Accidents, colour=EventType, group=EventType)) + geom_point(size=3) + geom_line(size=1) + labs(title=paste(input$type,"Accidents Per Year")) + ylab("Accidents") + xlab("Year")
                print(p1)
            } else {
                test <- subset(data, Type==input$type)
                summary <- colSums(test[,c(3:8)])
                test <- subset(test, EventType==input$event)
                
                graphdata<-data.frame(c(test$"2008",test$"2009",test$"2010",test$"2011",test$"2012",test$"2013"))
                graphdata$Year <- years
                graphdata$Total <- summary
                graphdata <- graphdata[,c(2,1,3)]
                names(graphdata) <- c("Year", "Accidents", "Total")
                
                p1 <- ggplot(graphdata, aes(x=Year, y=Accidents)) + geom_point(size=3,  colour="#3366FF") + geom_line(size=1,  colour="#3366FF") + labs(title=paste(test$Type, "accidents caused by", tolower(test$EventType))) + ylab("Accidents") + xlab("Year")
                if(input$showTotals) {
                    total <- ggplot(graphdata, aes(x=Year, y=Total))+ geom_point(size=3, colour="#3366FF") + geom_line(size=1, colour="#3366FF") + labs(title=paste("All", test$Type, "accidents")) + ylab("Accidents") + xlab("Year")
                    print(grid.arrange(p1, total))
                } else {
                    print(grid.arrange(p1))
                }
            }
        })
        
        output$table <- renderDataTable({
            if (input$event == "All") {
                graphData <- subset(data, data$Type==input$type)
                graphData$Type <- NULL
                graphData <- melt(graphData, id=c("EventType"))
                names(graphData) <- c("EventType","Year", "Accidents")
                
                graphData
            } else {
                test <- subset(data, Type==input$type)
                summary <- colSums(test[,c(3:8)])
                test <- subset(test, EventType==input$event)
                
                graphdata<-data.frame(c(test$"2008",test$"2009",test$"2010",test$"2011",test$"2012",test$"2013"))
                graphdata$Year <- years
                graphdata$Total <- summary
                graphdata <- graphdata[,c(2,1,3)]
                names(graphdata) <- c("Year", "Accidents", "Total")
                
                graphdata
            }
        })
    }
)
