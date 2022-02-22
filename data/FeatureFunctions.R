################################################################################################################################################
#' For each year-site combination, counts the number of days in data that meet a certain condition. 
#' Relies on historic coves to be loaded in environment
#' Default is to search across the entire time series, but optional @month_input param allows you to only search within a given month instead. 

#' @param condition. Counts the number of days that meet this condition (ex. tmax <0)
#' @param columnName. The name of the column of counts
#' @param month_input. Allows you to search over a particular month, encoded as an integer 1-12. Leaving this blank will search over the entire year

#' @output A three column dataframe containing the following
#' "year": The year that the covariate is relevant to (i.e. Temperatures in the winter of 1951 will be labeled as 1952, since that's the bloom they effect)
#' "location"
#' "columnName": Your output value; if left joined to "cherry" above, this will be the only added column


countDays <- function(condition, data, columnName, month_input=NA){
  if(is.na(month_input)==TRUE){
    output <- data %>% group_by(., cherry_year, location) %>% summarise(., temp=length(which({{condition}}))) #
    colnames(output) <- c("year", "location", columnName)
    return(output)
  }
  else{
    set <- dplyr::filter(data, month==month_input)
    output <- set %>% group_by(., cherry_year, location) %>% summarise(., temp=length(which({{condition}}))) #
    colnames(output) <- c("year", "location", columnName)
    return(output)
  }
}


################################################################################################################################################
#' For each year-site combination, returns the first day in data that meet a certain condition. 
#' Returned value is in terms of C_day, which is the unique day identifier for each year
#' If no day in the designated time series meets the criteria, returns NA
#' Relies on historic coves to be loaded in environment
#' Default is to search across the entire time series, but optional @month_input param allows you to only search within a given month instead. 

#' params and outputs follow same convention as @countDays

firstDay <- function(condition, data, columnName, month_input=NA){
  if(is.na(month_input)==TRUE){
    output <- data %>% group_by(., cherry_year, location) %>% summarise(., temp=C_day[min(which({{condition}}), na.rm = TRUE)]) #
    output$temp[is.infinite(output$temp)==TRUE] <- NA
    colnames(output) <- c("year", "location", columnName)
  }
  else{
    set <- dplyr::filter(data, month==month_input)
    output <- set %>% group_by(., cherry_year, location) %>% summarise(., temp=C_day[min(which({{condition}}), na.rm=TRUE)]) #
    output$temp[is.infinite(output$temp)==TRUE] <- NA
    colnames(output) <- c("year", "location", columnName)
  }
  return(output)
}
################################################################################################################################################
#' For each year-site combination, returns the number of consecutive days in data that meet a certain condition. 
#' Relies on historic coves to be loaded in environment
#' Default is to search across the entire time series, but optional @month_input param allows you to only search within a given month instead. 

#' params and outputs follow same convention as @countDays

consecDays <- function(condition, data, columnName, month_input=NA){
  if(is.na(month_input)==TRUE){
    output <- data %>% group_by(., cherry_year, location) %>% 
      summarise(., temp=max(rle({{condition}})$length[rle({{condition}})$values==TRUE], na.rm=TRUE)) #
    output$temp[is.infinite(output$temp)==TRUE] <- 0
    output$temp[is.na(output$temp)==TRUE] <- 0 #I think this is correct; let me make sure!
    colnames(output) <- c("year", "location", columnName)
  }
  else{
    set <- dplyr::filter(data, month==month_input)
    output <- set %>% group_by(., cherry_year, location) %>% 
      summarise(., temp=max(rle({{condition}})$length[rle({{condition}})$values==TRUE], na.rm=TRUE)) #
    output$temp[is.infinite(output$temp)==TRUE] <- 0
    colnames(output) <- c("year", "location", columnName)
  }
  return(output)
}
