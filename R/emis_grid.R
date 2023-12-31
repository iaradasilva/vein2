#' Allocate emissions into a grid returning point emissions or flux
#'
#' @description \code{\link{emis_grid}} allocates emissions proportionally to each grid
#'  cell. The process is performed by the intersection between geometries and the grid.
#' It means that requires "sr" according to your location for the projection.
#' It is assumed that spobj is a Spatial*DataFrame or an "sf" with the pollutants
#' in data. This function returns an object of class "sf".
#'
#' It is
#'
#' @param spobj A spatial dataframe of class "sp" or "sf". When class is "sp"
#' it is transformed to "sf".
#' @param g A grid with class "SpatialPolygonsDataFrame" or "sf".
#' @param sr Spatial reference e.g: 31983. It is required if spobj and g are
#' not projected. Please, see http://spatialreference.org/.
#' @param type type of geometry: "lines", "points" or "polygons".
#' @param FN Character indicating the function. Default is "sum"
#' @param flux Logical, if TRUE, it return flux (mass / area / time (implicit))
#' in a polygon grid, if false,  mass / time (implicit) as points, in a similar fashion
#' as EDGAR provide data.
#' @param k Numeric to multiply emissions
#' @importFrom sf st_sf st_dimension st_transform st_length st_cast st_intersection st_area st_geometry
#' @importFrom data.table data.table .SD
#' @export
#' @note \strong{1) If flux = TRUE (default), emissions are flux = mass / area / time (implicit), as polygons.}
#' \strong{If flux = FALSE, emissions are mass / time (implicit), as points.}
#' \strong{Time untis are not displayed because each use can have different time units}
#' \strong{for instance, year, month, hour second, etc.}
#'
#' \strong{2) Therefore, it is good practice to have time units in 'spobj'. }
#' \strong{This implies that spobj MUST include units!. }
#'
#' \strong{3) In order to check the sum of the emissions, you must calculate the grid-area}
#' \strong{in km^2 and multiply by each column of the resulting emissions grid, and then sum.}
#'
#'
#' \strong{4) If FN = "sum", is mass conservative!. }
#' @examples \dontrun{
#' data(net)
#' g <- make_grid(net, 1/102.47/2) #500m in degrees
#' names(net)
#' netsf <- sf::st_as_sf(net)
#' netg <- emis_grid(spobj = netsf[, c("ldv", "hdv")], g = g, sr= 31983)
#' plot(netg["ldv"],
#'      axes = TRUE,
#'      graticule = TRUE,
#'      bg = "black",
#'      lty = 0)
#' g <- sf::st_make_grid(net, 1/102.47/2, square = FALSE) #500m in degrees
#' g <- st_sf(i  =1, geometry = g)
#' netg <- emis_grid(spobj = netsf[, c("ldv", "hdv")], g = g, sr= 31983)
#' plot(netg["ldv"],
#'      axes = TRUE,
#'      graticule = TRUE,
#'      bg = "black",
#'      lty = 0)
#' plot(netg["hdv"], axes = TRUE)
#' netg <- emis_grid(spobj = netsf[, c("ldv", "hdv")], g = g, sr= 31983, FN = "mean")
#' plot(netg["ldv"], axes = TRUE)
#' plot(netg["hdv"], axes = TRUE)
#' netg <- emis_grid(spobj = netsf[, c("ldv", "hdv")], g = g, sr= 31983, flux = FALSE)
#' plot(netg["ldv"],
#'      axes = TRUE,
#'      pch = 16,
#'      pal = cptcity::cpt(colorRampPalette= TRUE,
#'                         rev = TRUE),
#'      cex = 3)
#' }
emis_grid <- function (spobj = net,
                       g,
                       sr,
                       type = "lines",
                       FN = "sum",
                       flux = TRUE,
                       k = 1){
  net <- sf::st_as_sf(spobj)
  net$id <- NULL
  # add as.data.frame when net comes from data.table
  netdata <- as.data.frame(sf::st_set_geometry(net, NULL))

  if(!inherits(netdata[[1]], "units")) {
    message("Your data has no units")
    hasunits <- FALSE
  } else {
    message("Your units are: ")
    hasunits <- TRUE
    uninet <- units(netdata[[1]])
    message(uninet)
  }
  for (i in 1:length(netdata)) {
    netdata[, i] <- as.numeric(netdata[, i])
  }
  net <- sf::st_sf(netdata, geometry = sf::st_geometry(net))
  g <- sf::st_as_sf(g)
  g$id <- 1:nrow(g)
  if (!missing(sr)) {
    "+init=epsg:31983"
    if (inherits(sr, "character")) {
      sr <- as.numeric(substr(sr, 12, nchar(sr)))
    }
    message("Transforming spatial objects to 'sr' ")
    net <- sf::st_transform(net, sr)
    g <- sf::st_transform(g, sr)
  }
  #lines ####
  if (type %in% c("lines", "line")) {
    net <- net[, grep(pattern = TRUE, x = sapply(net, is.numeric))]

    netdf <- sf::st_set_geometry(net, NULL)
    snetdf <- sum(netdf, na.rm = TRUE)
    ncolnet <- ncol(netdf)
    namesnet <- names(netdf)

    cat(paste0("Sum of street emissions ", round(snetdf, 2), "\n"))

    net$LKM <- sf::st_length(net)

    netg <- suppressMessages(suppressWarnings(sf::st_intersection(net, g)))

    netg$LKM2 <- sf::st_length(netg)

    xgg <- data.table::data.table(netg)

    xgg[, 1:ncolnet] <- xgg[, 1:ncolnet] * as.numeric(xgg$LKM2/xgg$LKM)

    xgg[is.na(xgg)] <- 0

    dfm <- xgg[,
               lapply(.SD, eval(parse(text = FN)), na.rm = TRUE),
               by = "id",
               .SDcols = namesnet]

       id <- dfm$id

       dfm$id <- NULL

       area <- sf::st_area(g)

       area <- units::set_units(area, "km^2")

       for(i in 1:ncol(dfm)) dfm[[i]] <- dfm[[i]]*k

       if(FN == "sum") dfm <- dfm * snetdf/sum(dfm, na.rm = TRUE)

       dfm$id <- id

    gx <- data.frame(id = g$id)

    gx <- merge(gx, dfm, by = "id", all = TRUE)

    gx[is.na(gx)] <- 0


    if(flux) {
      for(i in seq_along(namesnet)) {
        if(hasunits) units(gx[[namesnet[i]]]) <- uninet
        gx[[namesnet[i]]] <- gx[[namesnet[i]]]/area  # !
      }
      cat(paste0("Sum of gridded emissions ",
                 round(sum(gx[namesnet]*remove_units(area)),2), "\n"))
      gx <- sf::st_sf(gx, geometry = g$geometry)
      return(gx)
    } else {
      for(i in seq_along(namesnet)) {
        if(hasunits) units(gx[[namesnet[i]]]) <- uninet
      }
      cat(paste0("Sum of gridded emissions ",
                 round(sum(gx[namesnet]),2), "\n"))
      gx <- sf::st_sf(gx, geometry = g$geometry)
      gx <- suppressMessages(suppressWarnings(sf::st_centroid(gx)))
      return(gx)
    }
    #points####
  } else if (type %in% c("points", "point")) {

    netdf <- sf::st_set_geometry(net, NULL)

    snetdf <- sum(netdf, na.rm = TRUE)

    cat(paste0("Sum of point emissions ", round(snetdf, 2), "\n"))

    ncolnet <- ncol(netdf)

    namesnet <- names(netdf)

    xgg <- data.table::data.table(sf::st_set_geometry(suppressMessages(suppressWarnings(sf::st_intersection(net,
                                                                                                            g))), NULL))
    xgg[is.na(xgg)] <- 0
    dfm <- xgg[, lapply(.SD, eval(parse(text = FN)), na.rm = TRUE),
               by = "id",
               .SDcols = namesnet]

    id <- dfm$id

    dfm$id <- NULL

    area <- sf::st_area(g)

    area <- units::set_units(area, "km^2")

    for(i in 1:ncol(dfm)) dfm[[i]] <- dfm[[i]]*k

    if(FN == "sum") dfm <- dfm * snetdf/sum(dfm, na.rm = TRUE)

    dfm$id <- id

    gx <- data.frame(id = g$id)

    gx <- merge(gx, dfm, by = "id", all = TRUE)

    gx[is.na(gx)] <- 0


    if(flux) {
      for(i in seq_along(namesnet)) {
        if(hasunits) units(gx[[namesnet[i]]]) <- uninet
        gx[[namesnet[i]]] <- gx[[namesnet[i]]]/area  # !
      }
      cat(paste0("Sum of gridded emissions ",
                 round(sum(gx[namesnet]*remove_units(area)),2), "\n"))
      gx <- sf::st_sf(gx, geometry = g$geometry)
      return(gx)
    } else {
      for(i in seq_along(namesnet)) {
        if(hasunits) units(gx[[namesnet[i]]]) <- uninet
      }
      cat(paste0("Sum of gridded emissions ",
                 round(sum(gx[namesnet]),2), "\n"))
      gx <- sf::st_sf(gx, geometry = g$geometry)
      gx <- suppressMessages(suppressWarnings(sf::st_centroid(gx)))
      return(gx)
    }
    #polygons ####
  } else if(type %in% c("polygons", "polygon", "area")){
    netdf <- sf::st_set_geometry(net, NULL)
    snetdf <- sum(netdf, na.rm = TRUE)
    cat(paste0("Sum of point emissions ", round(snetdf, 2), "\n"))
    ncolnet <- ncol(netdf)
    net <- net[, grep(pattern = TRUE, x = sapply(net, is.numeric))]
    namesnet <- names(netdf)
    net$area1 <- sf::st_area(net)
    netg <- suppressMessages(suppressWarnings(sf::st_intersection(net, g)))
    netg$area2 <- sf::st_area(netg)

    xgg <- data.table::data.table(netg)
    xgg[, 1:ncolnet] <- xgg[, 1:ncolnet] * as.numeric(xgg$area2/xgg$area1)
    xgg[is.na(xgg)] <- 0
    dfm <- xgg[, lapply(.SD, eval(parse(text = FN)), na.rm = TRUE), by = "id",
               .SDcols = namesnet]
    id <- dfm$id
    dfm$id <- NULL

    area <- sf::st_area(g)

    area <- units::set_units(area, "km^2")

    for(i in 1:ncol(dfm)) dfm[[i]] <- dfm[[i]]*k

    if(FN == "sum") dfm <- dfm * snetdf/sum(dfm, na.rm = TRUE)

    cat(paste0("Sum of gridded emissions ", round(sum(dfm,
                                                      na.rm = T), 2), "\n"))
    dfm$id <- id
    gx <- data.frame(id = g$id)
    gx <- merge(gx, dfm, by = "id", all = TRUE)
    gx[is.na(gx)] <- 0

    if(flux) {
      for(i in seq_along(namesnet)) {
        if(hasunits) units(gx[[namesnet[i]]]) <- uninet
        gx[[namesnet[i]]] <- gx[[namesnet[i]]]/area  # !
      }
      cat(paste0("Sum of gridded emissions ",
                 round(sum(gx[namesnet]*remove_units(area)),2), "\n"))
      gx <- sf::st_sf(gx, geometry = g$geometry)
      return(gx)
    } else {
      for(i in seq_along(namesnet)) {
        if(hasunits) units(gx[[namesnet[i]]]) <- uninet
      }
      cat(paste0("Sum of gridded emissions ",
                 round(sum(gx[namesnet]),2), "\n"))
      gx <- sf::st_sf(gx, geometry = g$geometry)
      gx <- suppressMessages(suppressWarnings(sf::st_centroid(gx)))
      return(gx)
    }

  }
}
