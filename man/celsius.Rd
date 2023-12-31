% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/celsius.R
\name{celsius}
\alias{celsius}
\title{Construction function for Celsius temperature}
\usage{
celsius(x)
}
\arguments{
\item{x}{Object with class "data.frame", "matrix",  "numeric" or "integer"}
}
\value{
Objects of class "data.frame" or "units"
}
\description{
\code{celsius} just  add unit celsius to different R objects
}
\examples{
{
a <- celsius(rnorm(100)*10)
plot(a)
b <- celsius(matrix(rnorm(100)*10, ncol = 10))
print(head(b))
}
}
