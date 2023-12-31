% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/emis_cold.R
\name{emis_cold}
\alias{emis_cold}
\title{Estimation of cold start emissions hourly for the of the week}
\usage{
emis_cold(
  veh,
  lkm,
  ef,
  efcold,
  beta,
  speed = 34,
  agemax = if (!inherits(x = veh, what = "list")) {
     ncol(veh)
 } else {
    
    ncol(veh[[1]])
 },
  profile,
  simplify = FALSE,
  hour = nrow(profile),
  day = ncol(profile),
  array = TRUE,
  verbose = FALSE
)
}
\arguments{
\item{veh}{"Vehicles" data-frame or list of "Vehicles" data-frame. Each data-frame
as number of columns matching the age distribution of that type of vehicle.
The number of rows is equal to the number of streets link}

\item{lkm}{Length of each link}

\item{ef}{List of functions of emission factors of vehicular categories}

\item{efcold}{List of functions of cold start emission factors of vehicular categories}

\item{beta}{Dataframe with the hourly cold-start distribution to each day
of the period. Number of rows are hours and columns are days}

\item{speed}{Speed data-frame with number of columns as hours}

\item{agemax}{Age of oldest vehicles for that category}

\item{profile}{Numerical or dataframe with nrows equal to 24 and ncol 7 day
of the week}

\item{simplify}{Logical; to determine if EmissionsArray should les dimensions,
being streets, vehicle categories and hours or default (streets, vehicle
categories, hours and days). Default is FALSE to avoid break old code, but
the recommendation is that new estimations use this parameter as TRUE}

\item{hour}{Number of considered hours in estimation}

\item{day}{Number of considered days in estimation}

\item{array}{Deprecated! \code{\link{emis_cold}} returns only arrays.
When TRUE and veh is not a list, expects a profile as a dataframe producing
an array with dimensions (streets x columns x hours x days)}

\item{verbose}{Logical; To show more information}
}
\value{
EmissionsArray  g/h
}
\description{
\code{emis_cold} emissions are estimated as the product of the
vehicles on a road, length of the road, emission factor evaluated at the
respective speed. The estimation considers the beta parameter, the fraction of
mileage driven
}
\examples{
\dontrun{
# Do not run
data(net)
data(pc_profile)
data(fe2015)
data(fkm)
data(pc_cold)
pcf <- as.data.frame(cbind(pc_cold,pc_cold,pc_cold,pc_cold,pc_cold,pc_cold,
pc_cold))
PC_G <- c(33491,22340,24818,31808,46458,28574,24856,28972,37818,49050,87923,
          133833,138441,142682,171029,151048,115228,98664,126444,101027,
          84771,55864,36306,21079,20138,17439, 7854,2215,656,1262,476,512,
          1181, 4991, 3711, 5653, 7039, 5839, 4257,3824, 3068)
veh <- data.frame(PC_G = PC_G)
pc1 <- my_age(x = net$ldv, y = PC_G, name = "PC")
pcw <- temp_fact(net$ldv+net$hdv, pc_profile)
speed <- netspeed(pcw, net$ps, net$ffs, net$capacity, net$lkm, alpha = 1)
pckm <- units::set_units(fkm[[1]](1:24), "km"); pckma <- cumsum(pckm)
cod1 <- emis_det(po = "CO", cc = 1000, eu = "III", km = pckma[1:11])
cod2 <- emis_det(po = "CO", cc = 1000, eu = "I", km = pckma[12:24])
#vehicles newer than pre-euro
co1 <- fe2015[fe2015$Pollutant=="CO", ] #24 obs!!!
cod <- c(co1$PC_G[1:24]*c(cod1,cod2),co1$PC_G[25:nrow(co1)])
lef <- ef_ldv_scaled(co1, cod, v = "PC", cc = "<=1400",
                     f = "G",p = "CO", eu=co1$Euro_LDV)
# Mohtly average temperature 18 Celcius degrees
lefec <- ef_ldv_cold_list(df = co1, ta = 18, cc = "<=1400", f = "G",
                          eu = co1$Euro_LDV, p = "CO" )
lefec <- c(lefec,lefec[length(lefec)], lefec[length(lefec)],
           lefec[length(lefec)], lefec[length(lefec)],
           lefec[length(lefec)])
length(lefec) == ncol(pc1)
#emis change length of 'ef' to match ncol of 'veh'
class(lefec)
PC_CO_COLD <- emis_cold(veh = pc1,
                        lkm = net$lkm,
                        ef = lef,
                        efcold = lefec,
                        beta = pcf,
                        speed = speed,
                        profile = pc_profile)
class(PC_CO_COLD)
plot(PC_CO_COLD)
lpc <- list(pc1, pc1)
PC_CO_COLDv2 <- emis_cold(veh = pc1,
                          lkm = net$lkm,
                          ef = lef,
                          efcold = lefec,
                          beta = pcf,
                          speed = speed,
                          profile = pc_profile,
                          hour = 2,
                          day = 1)
}
}
