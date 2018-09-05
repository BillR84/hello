# Fit different distributions on the operational data

.libPaths(c("/home/bill/R/x86_64-pc-linux-gnu-library/3.3", .libPaths())) #Show where the included libraries are located

library(RMySQL) #Include library for connecting to MySQL Database
library(fitdistrplus) #Include library for fitting the different distributions
library(logspline)
library(MASS)
library(ggplot2)
library(scales)
#library(rgdal)
#library(sp)
library(chron)


setwd("/var/www/html/ProRail/")
WD <- getwd()

query <- "SELECT * FROM" #The 1st part of the query

tableOper <- "tt2017_realization_3500" #The operational data database table

whereOper <- "WHERE AnTijd<>'AnTijd'" #The WHERE clause for the operational data

Oquery <- paste(query, tableOper, whereOper, sep = " ") #concatenate the 1st part of the query with the operational data table and the WHERE clause

mydb <- dbConnect(MySQL(), user='root', password='root', dbname='prorail', host='127.0.0.1') #Connect to database
queryOper <- dbSendQuery(mydb, Oquery) #Query the operational data table
dataOper <- fetch(queryOper, n=-1) #Fetch results from query
dbDisconnect(mydb) #Close connection

#print(dataOper)

#dataOper$station <- factor(dataOper$station, levels=dataOper$station[order(dataOper$actual)])

timeOper <- chron(times=dataOper$AnTijd)
distanceOper <- dataOper$DistAbsolute

#print(timeOper)
xmax <- max(timeOper, na.rm=TRUE)
xmin <- min(timeOper, na.rm=TRUE)
ymax <- max(distanceOper, na.rm=TRUE)
ymin <- min(distanceOper, na.rm=TRUE)


print(xmin)
class(xmax)
xmax <- format(xmax, format="%H:%M:%S")
print(xmax)
#bins <- seq(c(from=xmin,to=xmax,by="10 mins"))
average <- (xmin+xmax)/2
print(average)
ggplot(dataOper, aes(x=AnTijd, y=DistAbsolute, group = AnTreinID)) + 
  geom_line() + 
  scale_y_discrete(limit = c(ymin, ymax), labels = c("Ht","Ehv")) + 
  scale_x_discrete(breaks = c(xmin, xmax), labels = c("11:00", "12:00"), expand = c(0, 0)) + 
  theme(axis.ticks.x=element_blank()) +
  labs(x="Time",y="Stations")
#ggplot(dataOper, aes(x=	AnTijd, y=DistAccum, color=trein_serie, group=trein_serie)) + geom_line() + scale_x_discrete(name="x-axis", breaks=bins)
#graphics.off() #Close the connection so the results can be finalized on the .csv