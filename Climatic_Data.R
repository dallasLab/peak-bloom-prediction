###getting historic data
#loading required packages
library(rnoaa)

#####Function needed to get historic data
get_historic <- function (stationid, location, var) {
  res<-vector(mode = 'list', length=length(stationid))
  for(i in 1:length(stationid)){
    aa<-as.data.frame(ghcnd_search(stationid = stationid[i], var = var, 
                                   date_min = "1950-01-01", date_max = "2022-02-15")[[1]])
    aa['year']<-substr(x=aa$date, start = 1, stop = 4)
    aa['month']<-as.numeric(substr(x=aa$date, start = 6, stop = 7))
    aa['day']<-substr(x=aa$date, start = 9, stop = 10)
    aa[which(aa$month==12),'month']<-0
    aa['season']<-cut(as.numeric(aa$month), breaks = c(0, 2, 5, 8, 11),
                      include.lowest = TRUE,
                      labels = c("Winter", "Spring", "Summer", "Fall"))
    aa[which(aa$month==0),'month']<-12
    aa['C_day']<-strftime(aa$date, format = '%j')
    aa['location']<-location[i]
    res[[i]]<-aa
  }
  res<-do.call(rbind,res)
  res<-res[,-c(4:6)]
}

##Station ids associated with the locations
stationid<-c('USC00186350','GME00127786', 'JA000047759', 'CA001108395')
location<-c('washingtondc','liestal','kyoto', 'vancouver')

historic_tmax<-get_historic(stationid, location, var='tmax')
historic_tmin<-get_historic(stationid, location, var='tmin')
historic_prcp<-get_historic(stationid, location, var='prcp')

##putting all historic climatic data together
historic_climate<-historic_tmax
historic_climate['tmin']<-historic_tmin[match(paste(historic_climate$location, historic_climate$date), 
                                              paste(historic_tmin$location, historic_tmin$date)),'tmin']
historic_climate['prcp']<-historic_prcp[match(paste(historic_climate$location, historic_climate$date), 
                                              paste(historic_prcp$location, historic_prcp$date)),'prcp']
historic_climate<-historic_climate[,-c(1,3)]

##transforming historic climate to degrees
historic_climate$tmax<-historic_climate$tmax/10
historic_climate$tmin<-historic_climate$tmin/10
historic_climate$prcp<-historic_climate$prcp/10



#####Getting the future data##############
library(raster)
setwd('/home/cleber/Downloads/T_min')
Arquivos<-list.files(path = "/home/cleber/Downloads/T_min", pattern = "_CNRM")
T_Min<-lapply(Arquivos, brick)
T_Min<-stack(T_Min)
T_Min_180<-vector(mode = 'list', length = nlayers(T_Min))
for(i in 1:nlayers(T_Min)){
  T_Min_180[[i]]<-raster::rotate(T_Min[[i]])
  print(i)
}
T_Min<-stack(T_Min_180)


##T_max
setwd('/home/cleber/Downloads/T_Max')

Arquivos.max<-list.files(path = "/home/cleber/Downloads/T_Max", pattern = "_CNRM")
T_Max<-lapply(Arquivos.max, brick)
T_Max<-stack(T_Max)

T_Max_180<-vector(mode = 'list', length = nlayers(T_Max))
for(i in 1:nlayers(T_Max)){
  T_Max_180[[i]]<-raster::rotate(T_Max[[i]])
  print(i)
}
T_Max<-stack(T_Max_180)

#Prec.
setwd('/home/cleber/Downloads/PrecD')

Arquivos.prec<-list.files(path = "/home/cleber/Downloads/PrecD", pattern = "_CNRM")
Preci<-lapply(Arquivos.prec, brick)
Preci<-stack(Preci)

Preci_180<-vector(mode = 'list', length = nlayers(Preci))
for(i in 1:nlayers(Preci)){
  Preci_180[[i]]<-raster::rotate(Preci[[i]])
  print(i)
}
Preci<-stack(Preci_180)


##extracting values
washingtondc<-c(-77.0,38.9)
kyoto<-c(135.7, 35.0)
liestal<-c(7.7,47.4)
vancouver<-c(-123.1, 49.2)
coords<-rbind.data.frame(washingtondc, kyoto, liestal, vancouver)


climat.min<-as.data.frame(t(extract(x = T_Min, 
                                    y=coords)))
colnames(climat.min)<-c('washingtondc', 'kyoto','liestal','vancouver')
climat.min['year']<-substr(x=rownames(climat.min), start = 2, stop = 5)
climat.min['month']<-substr(x=rownames(climat.min), start = 7, stop = 8)
climat.min[which(climat.min$month==12),'month']<-0
climat.min['day']<-substr(x=rownames(climat.min), start = 10, stop = 11)
climat.min['season']<-cut(as.numeric(climat.min$month), breaks = c(0, 2, 5, 8, 11),
                          include.lowest = TRUE,
                          labels = c("Winter", "Spring", "Summer", "Fall"))
climat.min[which(climat.min$month==0),'month']<-12

climat.max<-as.data.frame(t(extract(x = T_Max, 
                                    y=coords)))
colnames(climat.max)<-c('washingtondc', 'kyoto','liestal','vancouver')
climat.max['year']<-substr(x=rownames(climat.max), start = 2, stop = 5)
climat.max['month']<-substr(x=rownames(climat.max), start = 7, stop = 8)
climat.max[which(climat.max$month==12),'month']<-0
climat.max['day']<-substr(x=rownames(climat.max), start = 10, stop = 11)
climat.max['season']<-cut(as.numeric(climat.max$month), breaks = c(0, 2, 5, 8, 11),
                          include.lowest = TRUE,
                          labels = c("Winter", "Spring", "Summer", "Fall"))
climat.max[which(climat.max$month==0),'month']<-12


climat.prec<-as.data.frame(t(extract(x = Preci, 
                                     y=coords)))
colnames(climat.prec)<-c('washingtondc', 'kyoto','liestal','vancouver')
climat.prec['year']<-substr(x=rownames(climat.prec), start = 2, stop = 5)
climat.prec['month']<-substr(x=rownames(climat.prec), start = 7, stop = 8)
climat.prec[which(climat.prec$month==12),'month']<-0
climat.prec['day']<-substr(x=rownames(climat.prec), start = 10, stop = 11)
climat.prec['season']<-cut(as.numeric(climat.prec$month), breaks = c(0, 2, 5, 8, 11),
                           include.lowest = TRUE,
                           labels = c("Winter", "Spring", "Summer", "Fall"))
climat.prec[which(climat.prec$month==0),'month']<-12


Futclim.min<-as.data.frame(unlist(climat.min[,1:4]))
Futclim.min['location']<-rep(c('washingtondc', 'kyoto','liestal','vancouver'), each = nrow(climat.min))
Futclim.min['year']<-rep(climat.min$year,4)
Futclim.min['month']<-rep(climat.min$month,4)
Futclim.min['season']<-rep(climat.min$season,4)
Futclim.min['day']<-rep(climat.min$day,4)
Futclim.min['min_temp']<-Futclim.min$`unlist(climat.min[, 1:4])`
Futclim.min['C_day']<-strftime(x = paste(Futclim.min$year,Futclim.min$month, Futclim.min$day , sep = "-"), format = '%j')
# colnames(Futclim.min)<-c("tmin", "location", "year", "month", "season", 
#                          "day", "min_temp", "C_day")

Futclim.max<-as.data.frame(unlist(climat.max[,1:4]))
Futclim.max['location']<-rep(c('washingtondc', 'kyoto','liestal','vancouver'), each = nrow(climat.max))
Futclim.max['year']<-rep(climat.max$year,4)
Futclim.max['month']<-rep(climat.max$month,4)
Futclim.max['season']<-rep(climat.max$season,4)
Futclim.max['day']<-rep(climat.max$day,4)
Futclim.max['max_temp']<-Futclim.max$`unlist(climat.max[, 1:4])`
Futclim.max['C_day']<-strftime(x = paste(Futclim.max$year,Futclim.max$month, Futclim.max$day , sep = "-"), format = '%j')

Futclim.prec<-as.data.frame(unlist(climat.prec[,1:4]))
Futclim.prec['location']<-rep(c('washingtondc', 'kyoto','liestal','vancouver'), each = nrow(climat.prec))
Futclim.prec['year']<-rep(climat.prec$year,4)
Futclim.prec['month']<-rep(climat.prec$month,4)
Futclim.prec['season']<-rep(climat.prec$season,4)
Futclim.prec['day']<-rep(climat.prec$day,4)
Futclim.prec['prec']<-Futclim.prec$`unlist(climat.prec[, 1:4])`
Futclim.prec['C_day']<-strftime(x = paste(Futclim.prec$year,Futclim.prec$month, Futclim.prec$day , sep = "-"), format = '%j')



Futclim<-Futclim.min
Futclim['tmax']<-Futclim.max[match(paste(Futclim.max$location, Futclim.max$year,Futclim.max$month, Futclim.max$day), 
                                   paste(Futclim$location, Futclim$year,Futclim$month, Futclim$day)),'max_temp']
Futclim['prec']<-Futclim.prec[match(paste(Futclim.prec$location, Futclim.prec$year,Futclim.prec$month, Futclim.prec$day), 
                                    paste(Futclim$location, Futclim$year,Futclim$month, Futclim$day)),'prec']

Futclim<-Futclim[,2:ncol(Futclim)]##Futclim temp = kelvin
colnames(Futclim)<-c("location", "year", "month", "season", "day", "tmin", "C_day", 
                     "tmax", "prcp")

Futclim$tmin<-Futclim$tmin-273.15
Futclim$tmax<-Futclim$tmax-273.15
Futclim$prcp<-Futclim$prcp*86400 ##transform to km2/m/s to mm
rownames(Futclim)<-NULL


write.table(x = Futclim, 'future_climate.txt')
write.table(x = historic_climate, 'historic_climate.txt')