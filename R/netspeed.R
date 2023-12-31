#' Calculate speeds of traffic network
#'
#' @description \code{netspeed} Creates a dataframe of speeds for different hours
#' and each link based on morning rush traffic data
#'
#' @param q Data-frame of traffic flow to each hour (veh/h)
#' @param ps Peak speed (km/h)
#' @param ffs Free flow speed (km/h)
#' @param cap Capacity of link (veh/h)
#' @param lkm Distance of link (km)
#' @param alpha Parameter of BPR curves
#' @param beta Parameter of BPR curves
#' @param net SpatialLinesDataFrame or Spatial Feature of "LINESTRING"
#' @param scheme Logical to create a Speed data-frame with 24 hours and a
#' default  profile. It needs ffs and ps:
#' @param dist String indicating the units of the resulting distance in speed.
#' Default is units from peak speed `ps`
#' \tabular{rl}{
#'   00:00-06:00 \tab ffs\cr
#'   06:00-07:00 \tab average between ffs and ps\cr
#'   07:00-10:00 \tab ps\cr
#'   10:00-17:00 \tab average between ffs and ps\cr
#'   17:00-20:00 \tab ps\cr
#'   20:00-22:00 \tab average between ffs and ps\cr
#'   22:00-00:00 \tab ffs\cr
#' }
#' @return dataframe speeds with units or sf.
#' @importFrom sf st_sf st_as_sf
#' @export
#' @examples {
#' data(net)
#' data(pc_profile)
#' pc_week <- temp_fact(net$ldv+net$hdv, pc_profile)
#' df <- netspeed(pc_week, net$ps, net$ffs, net$capacity, net$lkm, alpha = 1)
#' class(df)
#' plot(df) #plot of the average speed at each hour, +- sd
#' # net$ps <- units::set_units(net$ps, "miles/h")
#' # net$ffs <- units::set_units(net$ffs, "miles/h")
#' # df <- netspeed(pc_week, net$ps, net$ffs, net$capacity, net$lkm, alpha = 1)
#' # class(df)
#' # plot(df) #plot of the average speed at each hour, +- sd
#' # df <- netspeed(ps = net$ps, ffs = net$ffs, scheme = TRUE)
#' # class(df)
#' # plot(df) #plot of the average speed at each hour, +- sd
#' # dfsf <- netspeed(ps = net$ps, ffs = net$ffs, scheme = TRUE, net = net)
#' # class(dfsf)
#' # head(dfsf)
#' # plot(dfsf, pal = cptcity::lucky(colorRampPalette = TRUE, rev = TRUE),
#' # key.pos = 1, max.plot = 9)
#' }
netspeed <- function (q = 1,
                      ps,
                      ffs,
                      cap,
                      lkm,
                      alpha = 0.15,
                      beta = 4,
                      net,
                      scheme = FALSE,
                      dist = "km"){
  if (scheme == FALSE & missing(q)){
    stop("No vehicles on 'q'")
  } else if (scheme == FALSE){
    qq <- as.data.frame(q)
    for (i  in 1:ncol(qq) ) {
      qq[,i] <- as.numeric(qq[,i])
    }
    ps <- as.numeric(ps)
    ffs <- as.numeric(ffs)
    cap <- as.numeric(cap)
    lkm <- as.numeric(lkm)
    dfv <- as.data.frame(do.call("cbind",(lapply(1:ncol(qq), function(i) {
      lkm/(lkm/ffs*(1 + alpha*(qq[,i]/cap)^beta))
    }))))
    names(dfv) <- unlist(lapply(1:ncol(q), function(i) paste0("S",i)))

    df_speed <- Speed(dfv, dist = dist)

    } else {
      ps <- as.numeric(ps)
      ffs <- as.numeric(ffs)

      dfv <- cbind(replicate(5, ffs),
                   replicate(1, 0.5*(ps + ffs) ),
                   replicate(3, ps),
                   replicate(7, 0.5*(ps + ffs)),
                   replicate(3, ps),
                   replicate(2, 0.5*(ps + ffs)),
                   replicate(3, ffs))

      names(dfv) <- c(rep("FSS",5),
                      "AS",
                      rep("PS", 3),
                      rep("AS", 7),
                      rep("PS", 3),
                      rep("AS", 2),
                      rep("FSS",3))

      df_speed <- Speed(as.data.frame(dfv),
                        dist = dist)

    }
    if(!missing(net)){
      netsf <- sf::st_as_sf(net)
      df_speedsf <- sf::st_sf(df_speed,
                              geometry = sf::st_geometry(netsf))
      return(df_speedsf)
    } else {
      return(df_speed)
    }
  }
