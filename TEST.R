setwd("~/DataScience/coursera/data_products/prj/slidify")

library(knitr)
library(slidify)

author("Unf??lle_in_HH")
slidify('index.Rmd')
browseURL('index.html')


#start with sudo!

setwd("~/DataScience/coursera/data_products/prj")

# install.packages("XLConnect")
# library("XLConnect")
# install.packages("xlsx")
library(xlsx)
help(read.xls)

fileSrc <- "data/46241-0009.xlsx"

getData <- function(startRow, endRow, name) {
    # read from Excel
    myData <- read.xlsx(fileSrc, 1, stringsAsFactors=F, startRow = startRow, endRow = endRow, colIndex=columnsToRead)
    
    # clean data
    myData$Type <- name
    myData <- myData[,c(8,1:7)]
    myData[3:8][myData[3:8]=="-"] <- 0
    names(myData) <- header
    
    #fix types
    myData$"2008" <-as.numeric(myData$"2008")
    myData$"2009" <-as.numeric(myData$"2009")
    myData$"2010" <-as.numeric(myData$"2010")
    myData$"2011" <-as.numeric(myData$"2011")
    myData$"2012" <-as.numeric(myData$"2012")
    myData$"2013" <-as.numeric(myData$"2013")
    
    return(myData)
}

header <- c("Type", "EventType", 2008, 2009, 2010, 2011, 2012, 2013)
years <- c(2008, 2009, 2010, 2011, 2012, 2013)
columnsToRead <- c(2:8)

#Cause
startRow <- 7
endRow <- 26
cause.Data <- read.xlsx(fileSrc, 1, stringsAsFactors=F, startRow = startRow, endRow = endRow, colIndex=2)
names(cause.Data) <- "EventType"

mofa.Data <- getData(7,26,"Mopeds")                         # Mofa
motorcycle.Data <- getData(26,45, "Motorcycles")            # Motorrad
pkw.Data <- getData(45,64, "Passenger cars")                # PKW
lpkw.Data <- getData(64,83, "Buses")                        # Kraftomnibus
lkw.Data <- getData(83,102, "Trucks")                       # Güterkraftfahrzeug
land.Data <- getData(102, 121, "Agricultural tractors")     # Landwirtschaftliche Zugmaschine
otherCars.Data <- getData(121, 140, "Other cars")           # Übrige Kraftfahrzeuge
bicycle.Data <- getData(140, 159, "Bicycles")                # Fahrrad
other.Data <- getData(159, 178, "Other/Unknown")            # Andere Fahrzeuge
pedestrian.Data <- getData(178, 197, "Pedestrians")         # Fußgänger
people.Data <- getData(197, 217, "Other people")            # Andere Personen

#full data set
data <- rbind(
    mofa.Data, motorcycle.Data, pkw.Data, lpkw.Data, lkw.Data, land.Data, 
    otherCars.Data, bicycle.Data, other.Data, pedestrian.Data, people.Data)

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

summary(data)

type <- sort(unique(data$Type))
type

test <- data[which.max(data$"2013"),]
test$Type
test$EventType

graph.data
graph.data<-data.frame(c(test$"2008",test$"2009",test$"2010",test$"2011",test$"2012",test$"2013"))
graph.data$Year <- years
names(graph.data) <- c("Accidents","Year")
summary(graph.data)
str(graph.data)
barplot(graph.data$Accidents)

test <- subset(data, Type=="Bicycle")
summary <- colSums(bicycle.Data[,c(3:8)])

test <- subset(test, EventType=="Alkoholeinfluss")
graphdata<-data.frame(c(test$"2008",test$"2009",test$"2010",test$"2011",test$"2012",test$"2013"))
graphdata$Year <- years
graphdata$Total <- summary
graphdata <- graphdata[,c(2,1,3)]
names(graphdata) <- c("Year", "Accidents", "Total")
p1 <- ggplot(graphdata, aes(x=Year, y=Accidents,Total))+ geom_point(size=3, colour="#3366FF") + geom_line(size=1, colour="#3366FF") + labs(title=paste(test$Type, "accidents caused by", test$EventType)) + ylab("Accidents") + xlab("Year")

total <- ggplot(graphdata, aes(x=Year, y=Total))+ geom_point(size=3, colour="#3366FF") + geom_line(size=1, colour="#3366FF") + labs(title=paste("All", test$Type, "accidents")) + ylab("Accidents") + xlab("Year")
grid.arrange(p1, total)

library(ggplot2)
g <- ggplot(graphdata, aes(x=graphdata$Year, y=graphdata$Accidents))
g <- g + geom_point(size=3)
g <- g + geom_line(size=1)
g <- g + labs(title="Accidents Per Year")
g <- g + ylab("Accidents")
g <- g + xlab("Year")
g
###########################################
graphdata
t <- melt(graphdata, id=c("Year"))
names(t) <- c("Year","EventType", "Accidents")
t

g <- ggplot(t, aes(x=t$Year, y=t$Accidents, colour=t$EventType, group=t$EventType))
g <- g + geom_point(size=3)
g <- g + geom_line(size=1)
g <- g + labs(title="Accidents Per Year")
g <- g + ylab("Accidents")
g <- g + xlab("Year")
g


##########################################
library(ggplot2)

test <- subset(data, Type=="Bicycles")
t <- melt(test, id=c("Type","EventType"))
names(t) <- c("Type","EventType","Year", "Accidents")

g <- ggplot(t, aes(x=t$Year, y=t$Accidents, colour=t$EventType, group=t$EventType))
g <- g + geom_point(size=3)
g <- g + geom_line(size=1)
g <- g + labs(title="Accidents Per Year")
g <- g + ylab("Accidents")
g <- g + xlab("Year")
g


graphData <- subset(data, Type=="Other cars")
graphData$Type<-NULL
graphData <- melt(graphData, id=c("EventType"))
names(graphData) <- c("EventType","Year", "Accidents")

ggplot(graphData, aes(x=graphData$Year, y=graphData$Accidents, colour=graphData$EventType, group=graphData$EventType)) + geom_point(size=3) + geom_line(size=1) + labs(title="Accidents Per Year") + ylab("Accidents") + xlab("Year")

graphDataNew <- subset(data, data$Type=="Car")
graphDataNew$Type <- NULL
graphDataNew <- melt(graphDataNew, id=c("EventType"))
names(graphDataNew) <- c("EventType","Year", "Accidents")

p1 <- ggplot(graphDataNew, aes(x=graphDataNew$Year, y=graphDataNew$Accidents, colour=graphDataNew$EventType, group=graphDataNew$EventType)) + geom_point(size=3) + geom_line(size=1) + labs(title=paste("XXX","Accidents Per Year")) + ylab("Accidents") + xlab("Year")
p1

