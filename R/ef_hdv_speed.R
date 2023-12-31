#' Emissions factors for Heavy Duty Vehicles based on average speed
#'
#' This function returns speed dependent emission factors. The emission factors
#' comes from the guidelines  EMEP/EEA air pollutant emission inventory guidebook
#' http://www.eea.europa.eu/themes/air/emep-eea-air-pollutant-emission-inventory-guidebook
#'
#' @param v Category vehicle: "Coach", "Trucks" or "Ubus"
#' @param t Sub-category of of vehicle: "3Axes", "Artic", "Midi", "RT, "Std" and "TT"
#' @param g Gross weight of each category: "<=18", ">18", "<=15", ">15 & <=18", "<=7.5",
#' ">7.5 & <=12", ">12 & <=14", ">14 & <=20", ">20 & <=26", ">26 & <=28", ">28 & <=32",
#' ">32", ">20 & <=28", ">28 & <=34", ">34 & <=40", ">40 & <=50" or ">50 & <=60"
#' @param eu Euro emission standard: "PRE", "I", "II", "III", "IV", "V". Also "II+CRDPF",
#' "III+CRDPF", "IV+CRDPF", "II+SCR", "III+SCR" and "V+SCR" for pollutants
#' Number of particles and Active Surface.
#' @param gr Gradient or slope of road: -0.06, -0.04, -0.02, 0.00, 0.02. 0.04 or 0.06
#' @param l Load of the vehicle: 0.0, 0.5 or 1.0
#' @param p Character; pollutant: "CO", "FC", "NOx", "NO", "NO2", "HC", "PM", "NMHC", "CH4",
#' "CO2",  "SO2" or "Pb". Only when p is "SO2" pr "Pb" x is needed. See notes.
#' @param x Numeric; if pollutant is "SO2", it is sulfur in fuel in ppm, if is
#' "Pb", Lead in fuel in ppm.
#' @param k Multiplication factor
#' @param show.equation Option to see or not the equation parameters
#' @param speed Numeric; Speed to return Number of emission factor and not a function.
#' It needs units in km/h
#' @param fcorr Numeric; Correction by fuel properties by euro technology.
#' See \code{\link{fuel_corr}}. The order from first to last is
#' "PRE", "I", "II", "III", "IV", "V", VI, "VIc". Default is 1
#' @return an emission factor function which depends of the average speed V  g/km
#' @keywords speed emission factors
#' @note
#' \strong{Pollutants (g/km)}: "CO", "NOx", "HC", "PM", "CH4", "NMHC", "CO2", "SO2",
#' "Pb".
#'
#' \strong{Black Carbon and Organic Matter (g/km)}: "BC", "OM"
#'
#' \strong{PAH and POP (g/km)}:  See  \code{\link{speciate}}
#' \strong{Dioxins and furans (g equivalent toxicity / km)}: See  \code{\link{speciate}}
#'
#' \strong{Metals (g/km)}: See  \code{\link{speciate}}
#'
#' \emph{Active Surface (cm2/km)} See  \code{\link{speciate}}
#'
#' \emph{Total Number of particles (N/km)}: See  \code{\link{speciate}}
#'
#' The available standards for Active Surface or number of particles are:
#' Euro II and III
#' Euro II and III + CRDPF
#' Euro II and III + SCR
#' Euro IV + CRDPF
#' Euro V + SCR
#'
#' The categories Pre Euro and Euro I were assigned with the factors of Euro II and Euro III
#' The categories euro IV and euro V were assigned with euro III + SCR
#'
#' Fuel consumption for heavy VI comes from V
#'
#' @seealso \code{\link{fuel_corr}} \code{\link{emis}} \code{\link{ef_ldv_cold}}  \code{\link{speciate}}
#' @importFrom units as_units
#' @export
#' @examples \dontrun{
#' # Quick view
#' pol <- c("CO", "NOx", "HC", "NMHC", "CH4", "FC", "PM", "CO2", "SO2")
#' f <- sapply(1:length(pol), function(i){
#' print(pol[i])
#' ef_hdv_speed(v = "Trucks",t = "RT", g = "<=7.5", e = "II", gr = 0,
#' l = 0.5, p = pol[i], x = 10)(30)
#' })
#' f
#'
#' V <- 0:130
#' ef1 <- ef_hdv_speed(v = "Trucks",t = "RT", g = "<=7.5", e = "II", gr = 0,
#' l = 0.5, p = "HC")
#' plot(1:130, ef1(1:130), pch = 16, type = "b")
#' euro <- c(rep("V", 5), rep("IV", 5), rep("III", 5), rep("II", 5),
#'           rep("I", 5), rep("PRE", 15))
#' lef <- lapply(1:30, function(i) {
#' ef_hdv_speed(v = "Trucks", t = "RT", g = ">32", gr = 0,
#' eu = euro[i], l = 0.5, p = "NOx",
#' show.equation = FALSE)(25) })
#' efs <- EmissionFactors(unlist(lef)) #returns 'units'
#' plot(efs, xlab = "age")
#' lines(efs, type = "l")
#' a <- ef_hdv_speed(v = "Trucks", t = "RT", g = ">32", gr = 0,
#' eu = euro, l = 0.5, p = "NOx", speed = Speed(0:125))
#' a$speed <- NULL
#' filled.contour(as.matrix(a), col = cptcity::lucky(n = 24),
#' xlab = "Speed", ylab = "Age")
#' persp(x = as.matrix(a), theta = 35, xlab = "Speed", ylab = "Age",
#' zlab = "NOx [g/km]", col = cptcity::lucky(), phi = 25)
#' aa <- ef_hdv_speed(v = "Trucks", t = "RT", g = ">32", gr = 0,
#' eu = rbind(euro, euro), l = 0.5, p = "NOx", speed = Speed(0:125))
#' }
ef_hdv_speed <- function(v, t, g, eu, x, gr = 0, l = 0.5 ,p, k=1,
                         show.equation = FALSE, speed, fcorr = rep(1, 8)){
  p_cri <- as.character(unique(sysdata$hdv_criteria$POLLUTANT))
  p_ghg <- as.character(unique(sysdata$hdv_ghg$POLLUTANT))

  #Check eu
  if(is.matrix(eu) | is.data.frame(eu)){
    eu <- as.data.frame(eu)
    for(i in 1:ncol(eu)) eu[, i] <- as.character(eu[, i])
  } else {
    eu = as.character(eu)
  }

  if(p %in% p_cri){
    ef_hdv <- sysdata$hdv_criteria
  } else if(p %in% p_ghg){
    ef_hdv <- sysdata$hdv_ghg
  }
  # Check speed
  if(!missing(speed)){
    if(!inherits(speed, "units")){
      stop("speed neeeds to has class 'units' in 'km/h'. Please, check package '?units::set_units'")
    }
    if(units(speed) != units(units::as_units("km/h"))){
      stop("Units of speed must be 'km/h' ")
    }
    if(units(speed) == units(units::as_units("km/h"))){
      speed <- as.numeric(speed)
    }
  }
  #Function to case when
  lala <- function(x) {
    ifelse(x == "PRE", fcorr[1],
           ifelse(
             x == "I", fcorr[2],
             ifelse(
               x == "II", fcorr[3],
               ifelse(
                 x == "III", fcorr[4],
                 ifelse(
                   x == "IV", fcorr[5],
                   ifelse(
                     x == "V", fcorr[6],
                     ifelse(
                       x == "VI", fcorr[7],
                       fcorr[8])))))))
  }

  # fun starts
  if(!is.data.frame(eu)){
    if(length(eu) == 1){
      df <- ef_hdv[ef_hdv$VEH == v &
                     ef_hdv$TYPE == t &
                     ef_hdv$GW == g &
                     ef_hdv$EURO == eu &
                     ef_hdv$GRA == gr &
                     ef_hdv$LOAD == l &
                     ef_hdv$POLLUTANT == p, ]
      k2 <- lala(eu)

      if (show.equation == TRUE) {
        cat(paste0("a = ", df$a, ", b = ", df$b, ", c = ", df$c, ", d = ", df$d,
                   ", e = ", df$e, ", f = ", df$f, "\n"))
        cat(paste0("Equation = ", "(",as.character(df$Y), ")", "*", k, "*", k2, "\n"))
      }
      if(p %in% c("SO2","Pb")){
        f1 <- function(V){
          a <- df$a; b <- df$b; c <- df$c; d <- df$d; e <- df$e; f <- df$f; x <- x
          V <- ifelse(V < df$MINV, df$MINV,
                      ifelse(V > df$MAXV, df$MAXV, V))
          eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2)))
        }
      } else {
        f1 <- function(V){
          a <- df$a; b <- df$b; c <- df$c; d <- df$d; e <- df$e; f <- df$f
          V <- ifelse(V<df$MINV,df$MINV,ifelse(V>df$MAXV,df$MAXV,V))
          eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2)))
        }
      }
      if(!missing(speed)){
          f1 <- EmissionFactors(f1(speed))
        return(f1)
      } else {
        return(f1)
      }

    } else if(length(eu) > 1) {
      if(missing(speed)) stop("if length(eu) > 1, 'speed' is needed")
      dff <- do.call("cbind", lapply(1:length(eu), function(i){
        df <- ef_hdv[ef_hdv$VEH == v &
                       ef_hdv$TYPE == t &
                       ef_hdv$GW == g &
                       ef_hdv$EURO == eu[i] &
                       ef_hdv$GRA == gr &
                       ef_hdv$LOAD == l &
                       ef_hdv$POLLUTANT == p, ]
        k2 <- lala(eu[i])

        if(p %in% c("SO2","Pb")){
          f1 <- function(V){
            a <- df$a; b <- df$b; c <- df$c; d <- df$d; e <- df$e; f <- df$f; x <- x
            V <- ifelse(V < df$MINV, df$MINV,
                        ifelse(V > df$MAXV, df$MAXV, V))
            ifelse(eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))) < 0,
                   0,
                   eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))) )
          }
        } else {
          f1 <- function(V){
            a <- df$a; b <- df$b; c <- df$c; d <- df$d; e <- df$e; f <- df$f
            V <- ifelse(V<df$MINV,df$MINV,ifelse(V>df$MAXV,df$MAXV,V))
            ifelse(eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))) < 0,
                   0,
                   eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))))
          }
        }
        f1(speed)
      }))
      dff <- EmissionFactors(dff)
      names(dff) <- paste0(eu, "_", 1:length(eu))
      dff$speed <- speed
      return(dff)
    }

  } else if (is.data.frame(eu)){
    if(missing(speed)) stop("Add 'speed' please for each row")
    dff <- do.call("rbind", lapply(1:nrow(eu), function(j){
      do.call("cbind", lapply(1:ncol(eu), function(i){

        df <- ef_hdv[ef_hdv$VEH == v &
                       ef_hdv$TYPE == t &
                       ef_hdv$GW == g &
                       ef_hdv$EURO == eu[j,i][[1]] &
                       ef_hdv$GRA == gr &
                       ef_hdv$LOAD == l &
                       ef_hdv$POLLUTANT == p, ]
        k2 <- lala(eu[j,i][[1]])

        if(p %in% c("SO2","Pb")){
          f1 <- function(V){
            a <- df$a; b <- df$b; c <- df$c; d <- df$d; e <- df$e; f <- df$f; x <- x
            V <- ifelse(V < df$MINV, df$MINV,
                        ifelse(V > df$MAXV, df$MAXV, V))
            ifelse(eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))) < 0,
                   0,
                   eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))) )
          }
        } else {
          f1 <- function(V){
            a <- df$a; b <- df$b; c <- df$c; d <- df$d; e <- df$e; f <- df$f
            V <- ifelse(V<df$MINV,df$MINV,ifelse(V>df$MAXV,df$MAXV,V))
            ifelse(eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))) < 0,
                   0,
                   eval(parse(text = paste0("(",as.character(df$Y), ")", "*", k, "*", k2))))
          }
        }
        f1(speed)
      }))
    }))
    dff <- EmissionFactors(dff)
    dff$speed <- speed
    dff$row_eu <- rep(1:nrow(eu), each = length(speed))
    return(dff)
  }



}

