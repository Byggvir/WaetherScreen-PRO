Wochentage <- c("Mo","Di","Mi","Do","Fr","Sa","So")
WochentageLang <- c("Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag","Sonntag")
Monatsnamen <- c('Januar', 'Februar', 'März','April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November','Dezember')

limbounds <- function (x, zeromin=TRUE) {
  
  if (zeromin == TRUE) {
    range <- c(0,max(x,na.rm = TRUE))
  } else
  { range <- c(min(x, na.rm = TRUE),max(x,na.rm = TRUE))
  }
  if (range[1] != range[2])
  {  f <- 10^(floor(log10(range[2]-range[1])))
  } else {
    f <- 1
  }
  
  return ( c(floor(range[1]/f),ceiling(range[2]/f)) * f) 
}

get_p_value <- function (modelobject) {
  if (class(modelobject) != "lm") stop("Not an object of class 'lm' ")
  f <- summary(modelobject)$fstatistic
  p <- pf(f[1],f[2],f[3],lower.tail=F)
  attributes(p) <- NULL
  return(p)
}

MagnusFormel <- function (T, ice=FALSE) {
  
  if ( ! ice ) {
    return ( 611.2 * exp( 17.6200 * ( T - 273.15 ) / ( T - 30.0300) ) )
  }
  else {
    return ( 611.2 * exp( 27.4600 * ( T - 273.15 ) / ( T - 0.5300) ) )
    
  }
}

SaettigungWasser <- function(T) {
  
  return(MagnusFormel(T)/461.52/T)
  
}

KwToDate <- function ( Jahr , Kw ) {
  
  R <- as.Date (paste(Jahr,'-01-01',sep = ''))
  
  w <- lubridate::wday(R, week_start = 1)
  
  R[ w > 4 ] <- R[ w > 4 ] + Kw[ w > 4 ] * 7 + 4  - w[ w > 4 ]
  R[ w <= 4 ] <- R[ w <= 4 ] + ( Kw[ w <= 4 ] - 1 ) * 7 + (4 - w [ w <= 4 ]) 
  return (R)
  
}

