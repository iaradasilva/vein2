% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cold_mileage.R
\name{cold_mileage}
\alias{cold_mileage}
\title{Fraction of mileage driven with a cold engine or catalizer below normal temperature}
\usage{
cold_mileage(ltrip, ta)
}
\arguments{
\item{ltrip}{Numeric; Length of trip. It must be in 'units' km.}

\item{ta}{Numeric or data.frame; average monthly temperature Celsius. It if is a
data.frame, it is convenient that each column is each month.}
}
\description{
This function depends length of trip and on ambient temperature.
From the guidelines  EMEP/EEA air pollutant emission inventory guidebook
http://www.eea.europa.eu/themes/air/emep-eea-air-pollutant-emission-inventory-guidebook
}
\note{
This function is set so that values varies between 0 and 1.
}
\examples{
\dontrun{
lkm <- units::set_units(1:10, km)
ta <- celsius(matrix(0:9, ncol = 12, nrow = 10))
a <- cold_mileage(lkm, ta)
colplot(a)
}
}
\keyword{cold}
\keyword{mileage}
