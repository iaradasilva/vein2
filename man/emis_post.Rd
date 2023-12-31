% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/emis_post.R
\name{emis_post}
\alias{emis_post}
\title{Post emissions}
\usage{
emis_post(arra, veh, size, fuel, pollutant, by = "veh", net, type_emi, k = 1)
}
\arguments{
\item{arra}{Array of emissions 4d: streets x category of vehicles x hours x days or
3d: streets x category of vehicles x hours}

\item{veh}{Character, type of vehicle}

\item{size}{Character, size or weight}

\item{fuel}{Character, fuel}

\item{pollutant}{Pollutant}

\item{by}{Type of output, "veh" for total vehicular category ,
"streets_narrow" or "streets". "streets" returns  a dataframe with
 rows as number of streets and columns the hours as days*hours considered, e.g.
168 columns as the hours of a whole week and "streets repeats the
row number of streets by hour and day of the week}

\item{net}{SpatialLinesDataFrame or Spatial Feature of "LINESTRING". Only
when by = 'streets_wide'}

\item{type_emi}{Character, type of emissions(exhaust, evaporative, etc)}

\item{k}{Numeric, factor}
}
\description{
\code{emis_post} simplify emissions estimated as total per type category of
vehicle or by street. It reads EmissionsArray and Emissions classes. It can return a dataframe
with hourly emissions at each street, or a database with emissions by vehicular
category, hour, including size, fuel and other characteristics.
}
\note{
This function depends on EmissionsArray objests which currently has
4 dimensions. However, a future version of VEIN will produce EmissionsArray
with 3 dimensiones and his fungeorge soros drugsction also will change. This change will be
made in order to not produce inconsistencies with previous versions, therefore,
if the user count with an EmissionsArry with 4 dimension, it will be able
to use this function.
}
\examples{
\dontrun{
# Do not run
data(net)
data(pc_profile)
data(fe2015)
data(fkm)
PC_G <- c(33491,22340,24818,31808,46458,28574,24856,28972,37818,49050,87923,
          133833,138441,142682,171029,151048,115228,98664,126444,101027,
          84771,55864,36306,21079,20138,17439, 7854,2215,656,1262,476,512,
          1181, 4991, 3711, 5653, 7039, 5839, 4257,3824, 3068)
pc1 <- my_age(x = net$ldv, y = PC_G, name = "PC")
# Estimation for morning rush hour and local emission factors
speed <- data.frame(S8 = net$ps)
p1h <- matrix(1)
lef <- EmissionFactorsList(fe2015[fe2015$Pollutant=="CO", "PC_G"])
E_CO <- emis(veh = pc1,lkm = net$lkm, ef = lef, speed = speed,
             profile = p1h)
E_CO_STREETS <- emis_post(arra = E_CO, pollutant = "CO", by = "streets_wide")
summary(E_CO_STREETS)
E_CO_STREETSsf <- emis_post(arra = E_CO, pollutant = "CO",
                           by = "streets", net = net)
summary(E_CO_STREETSsf)
plot(E_CO_STREETSsf, main = "CO emissions (g/h)")
# arguments required: arra, veh, size, fuel, pollutant ad by
E_CO_DF <- emis_post(arra = E_CO,  veh = "PC", size = "<1400", fuel = "G",
pollutant = "CO", by = "veh")
# Estimation 168 hours
pc1 <- my_age(x = net$ldv, y = PC_G, name = "PC")
pcw <- temp_fact(net$ldv+net$hdv, pc_profile)
speed <- netspeed(pcw, net$ps, net$ffs, net$capacity, net$lkm, alpha = 1)
pckm <- units::set_units(fkm[[1]](1:24),"km"); pckma <- cumsum(pckm)
cod1 <- emis_det(po = "CO", cc = 1000, eu = "III", km = pckma[1:11])
cod2 <- emis_det(po = "CO", cc = 1000, eu = "I", km = pckma[12:24])
#vehicles newer than pre-euro
co1 <- fe2015[fe2015$Pollutant=="CO", ] #24 obs!!!
cod <- c(co1$PC_G[1:24]*c(cod1,cod2),co1$PC_G[25:nrow(co1)])
lef <- ef_ldv_scaled(dfcol = cod, v = "PC",  cc = "<=1400",
                     f = "G",p = "CO", eu=co1$Euro_LDV)
E_CO <- emis(veh = pc1,lkm = net$lkm, ef = lef, speed = speed, agemax = 41,
             profile = pc_profile)
# arguments required: arra, pollutant ad by
E_CO_STREETS <- emis_post(arra = E_CO, pollutant = "CO", by = "streets")
summary(E_CO_STREETS)
# arguments required: arra, veh, size, fuel, pollutant ad by
E_CO_DF <- emis_post(arra = E_CO,  veh = "PC", size = "<1400", fuel = "G",
pollutant = "CO", by = "veh")
head(E_CO_DF)
# recreating 24 profile
lpc <-list(pc1*0.2, pc1*0.1, pc1*0.1, pc1*0.2, pc1*0.5, pc1*0.8,
           pc1, pc1*1.1, pc1,
           pc1*0.8, pc1*0.5, pc1*0.5,
           pc1*0.5, pc1*0.5, pc1*0.5, pc1*0.8,
           pc1, pc1*1.1, pc1,
           pc1*0.8, pc1*0.5, pc1*0.3, pc1*0.2, pc1*0.1)
E_COv2 <- emis(veh = lpc,  lkm = net$lkm, ef = lef, speed = speed[, 1:24],
            agemax = 41, hour = 24, day = 1)
plot(E_COv2)
E_CO_DFv2 <- emis_post(arra = E_COv2,
                       veh = "PC",
                       size = "<1400",
                       fuel = "G",
                       type_emi = "Exhaust",
                       pollutant = "CO", by = "veh")
head(E_CO_DFv2)
}
}
