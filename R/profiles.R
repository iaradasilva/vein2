#' Profile of traffic data 24 hours 7 n days of the week
#'
#' This dataset is n a list of data-frames with traffic activity normalized
#' monday 08:00-09:00. It comes from data of toll stations near Sao Paulo City.
#' The source is ARTESP (www.artesp.com.br) for months January and June and
#' years 2012, 2013 and 2014. The type of vehicles covered are PC, LCV, MC and
#' HGV.
#'
#' @format A list of data-frames with 24 rows and 7 variables:
#' \describe{
#'   \item{PC_JUNE_2012}{168 hours}
#'   \item{PC_JUNE_2013}{168 hours}
#'   \item{PC_JUNE_2014}{168 hours}
#'   \item{LCV_JUNE_2012}{168 hours}
#'   \item{LCV_JUNE_2013}{168 hours}
#'   \item{LCV_JUNE_2014}{168 hours}
#'   \item{MC_JUNE_2012}{168 hours}
#'   \item{MC_JUNE_2013}{168 hours}
#'   \item{MC_JUNE_2014}{168 hours}
#'   \item{HGV_JUNE_2012}{168 hours}
#'   \item{HGV_JUNE_2013}{168 hours}
#'   \item{HGV_JUNE_2014}{168 hours}
#'   \item{PC_JANUARY_2012}{168 hours}
#'   \item{PC_JANUARY_2013}{168 hours}
#'   \item{PC_JANUARY_2014}{168 hours}
#'   \item{LCV_JANUARY_2012}{168 hours}
#'   \item{LCV_JANUARY_2013}{168 hours}
#'   \item{LCV_JANUARY_2014}{168 hours}
#'   \item{MC_JANUARY_2012}{168 hours}
#'   \item{MC_JANUARY_2014}{168 hours}
#'   \item{HGV_JANUARY_2012}{168 hours}
#'   \item{HGV_JANUARY_2013}{168 hours}
#'   \item{HGV_JANUARY_2014}{168 hours}
#' }
#' @usage data(pc_profile)
#' @docType data
"profiles"
