library(dataRetrieval)

#Get sample datetimes from NWIS
getSampleTimes <- function(site, start, end) {
  #Get all qw results
  qw <- try({readNWISqw(site, "All", startDate = start, endDate = end, reshape = TRUE)}, silent=TRUE)
  if(class(qw) == "try-error")
    return(0)
  #Retain the sample time and Q/GHT if they are there
  cols <- c("startDateTime", "result_va_00061", "result_va_00065")
  keep <- names(qw)[names(qw) %in% cols]
  qw <- qw[,keep]
  if(length(keep) == 1) {
    qw <- data.frame(datetime = qw)
    return(qw)
  }
  names(qw)[names(qw) == "startDateTime"] <- "datetime"
  if("result_va_00061" %in% keep)
    names(qw)[names(qw) == "result_va_00061"] <- "QW_Q"
  if("result_va_00065" %in% keep)
    names(qw)[names(qw) == "result_va_00065"] <- "QW_GHT"
  return(qw)
}

getQGHT <- function(site, start, end) {
  Qname <- "X_00060_00000"
  QGHT <- readNWISuv(site, c("00060","00065"), start, end)
  if(nrow(QGHT) == 0) {
    return(data.frame(datetime = vector(), Q = vector(), GHT = vector()))
  }
  keep <- names(QGHT)[names(QGHT) %in% c("dateTime", "X_00060_00000", "X_00065_00000")]
  QGHT <- QGHT[,keep]
  if("X_00060_00000" %in% keep) {
    names(QGHT)[names(QGHT) == "X_00060_00000"] <- "Q"
    QGHT <- QGHT[QGHT$Q >= 0,]
  }
  if("X_00065_00000" %in% keep) {
    names(QGHT)[names(QGHT) == "X_00065_00000"] <- "GHT"
    QGHT <- QGHT[QGHT$GHT >= 0,]
  }
  names(QGHT)[names(QGHT) == "dateTime"] <- "datetime"
  return(QGHT)
}


# intData
#   Purpose: interpolate a value between two time series observations
#   Arguments:
#     t (POSIXct) the time you want to find an interpolated value for
#     datetimes (POSIXct) a vector of datetimes of continuous observations
#     data (numeric) a vector of measured values corresponding to the datetimes vector
#     maxDiff (numeric) the maximum number of hours between two points used for interpolation
#       if the two points bracketing t are more than maxDiff away from each other, NA will be returned
intData <- function(t, datetimes, data, maxDiff=4) {
  datetimes <- datetimes[!is.na(data)]
  data <- data[!is.na(data)]
  timeDiff <- difftime(t, datetimes)
  
  if(all(timeDiff > 0) | all(timeDiff < 0)) {
    out <- NA
    return(out)
  }
  
  if(any(timeDiff==0)) {
    out <- data[timeDiff==0]
  } else {
    t1 <- datetimes[timeDiff == min(timeDiff[timeDiff > 0])]
    t2 <- datetimes[timeDiff == max(timeDiff[timeDiff < 0])]
    d1 <- data[datetimes==t1]
    d2 <- data[datetimes==t2]
    tL <- as.numeric(difftime(t2, t1, units="hours"))
    tE <- as.numeric(difftime(t, t1, units="hours"))
    if(tL > maxDiff) {
      out <- NA
    } else {
      out <- (((d2 - d1) * tE) / tL) + d1
    }
  }
  return(out)
}

#intDataVector
#   Purpose: Interpolate values of a measured variable for a series of times

intDataVector <- function(lookup, datetimes, data, maxDiff=4) {
  
  out <- vector()
  
  for(i in 1:length(lookup)) {
    out[length(out) + 1] <- intData(lookup[i], datetimes, data, maxDiff=maxDiff)
  }
  
  return(out)
  
}

#Interpolate Q and GHT values for each sample time 
intQGHT <- function(sample_data, cont_data, maxDiff = 4) {
  
  #Iterate through each non-date, numeric column in the continuous data and add it to the sample frame
  c_datetimes <- cont_data$datetime
  s_datetimes <- sample_data$datetime
  
  cont_vars <- names(cont_data)[names(cont_data) != "datetime"]
  
  for(i in cont_vars) {
    
    sample_data[,i] <-
      intDataVector(lookup=s_datetimes,
                    datetimes=c_datetimes,
                    data = cont_data[,i],
                    maxDiff = maxDiff)
    
  }
  
  #Return the sample frame with continuous variables
  return(sample_data)
}

getSampleQ <- function(site, start, end, maxDiff = 4) {
  
  samples <- getSampleTimes(site, start, end)
  if(length(samples) == 0) {
    return("No samples found")
  }
  qght <- getQGHT(site, start, end)
  if(nrow(qght) == 0) {
    return("No continuous data found")
  }
  sampleQ <- intQGHT(samples, qght, maxDiff = maxDiff)
  sampleQ$datetime <- as.character(sampleQ$datetime, format="%Y-%m-%d %H:%M %Z")
  return(sampleQ)
  
}





