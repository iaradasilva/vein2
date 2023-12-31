#' Inventory function.
#'
#' @description \code{inventory} produces an structure of directories and scripts
#' in order to run vein. It is required to know the vehicular composition of the
#' fleet.
#'
#' @param name Character, path to new main directory for running vein.
#' NO BLANK SPACES
#' @param vehcomp Vehicular composition of the fleet. It is required a named
#' numerical vector with the names "PC", "LCV", "HGV", "BUS" and "MC". In the
#' case that there are no vehicles for one category of the composition, the name
#' should be included with the number zero, for example, PC = 0. The maximum
#' number allowed is 99 per category.
#' @param show.main Logical; Do you want to see the new main.R file?
#' @param scripts Logical Do you want to generate or no R scripts?
#' @param show.dir Logical value for printing the created directories.
#' @param show.scripts Logical value for printing the created scripts.
#' @param clear Logical value for removing recursively the directory and create
#' another one.
#' @param showWarnings Logical, showWarnings?
#' @param rush.hour Logical, to create a template for morning rush hour.
#' @return Structure of directories and scripts for automating the compilation of
#' vehicular emissions inventory. The structure can be used with another type of
#' sources of emissions. The structure of the directories is: daily, ef, emi,
#' est, images, network and veh. This structure is a suggestion and the user can
#' use another.
#''
#' ef: it is for storing the emission factors data-frame, similar to data(fe2015)
#' but including one column for each of the categories of the vehicular
#' composition. For instance, if PC = 5, there should be 5 columns with emission
#' factors in this file. If LCV = 5, another 5 columns should be present, and
#' so on.
#'
#' emi: Directory for saving the estimates. It is suggested to use .rds
#' extension instead of .rda.
#'
#' est: Directory with subdirectories matching the vehicular composition for
#' storing the scripts named input.R.
#'
#' images: Directory for saving images.
#'
#' network: Directory for saving the road network with the required attributes.
#' This file will include the vehicular flow per street to be used by age*
#' functions.
#'
#' veh: Directory for storing the distribution by age of use of each category of
#' the vehicular composition. Those are data-frames with number of columns with
#' the age distribution and number of rows as the number of streets. The class
#' of these objects is "Vehicles". Future versions of vein will generate
#' Vehicles objects with the explicit spatial component.
#'
#' The name of the scripts and directories are based on the vehicular
#' composition, however, there is included a file named main.R which is just
#' an R script to estimate all the emissions. It is important to note that the
#' user must add the emission factors for other pollutants. Also, this function
#' creates the scripts input.R where the user must specify the inputs for the
#' estimation of emissions of each category. Also, there is a file called
#' traffic.R to generate objects of class "Vehicles".
#' The user can rename these scripts.
#' @export
#' @importFrom utils file.edit
#' @examples \dontrun{
#' name = file.path(tempdir(), "YourCity")
#' inventory(name = name)
#' }
#'
inventory <- function(name,
                      vehcomp = c(PC = 1, LCV = 1, HGV = 1, BUS = 1, MC = 1),
                      show.main = FALSE,
                      scripts = TRUE,
                      show.dir = FALSE,
                      show.scripts = FALSE,
                      clear = TRUE,
                      rush.hour = FALSE,
                      showWarnings = FALSE){
  if(Sys.info()[['sysname']] == "Windows") {
    name <- gsub("\\\\", "/", name)
  }
  # directorys
  dovein <- function(){
    dir.create(path = name, showWarnings = showWarnings)
    dir.create(path = paste0(name, "/profiles"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/ef"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/emi"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/post"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/post/grids"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/post/streets"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/post/df"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/est"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/images"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/network"), showWarnings = showWarnings)
    dir.create(path = paste0(name, "/veh"), showWarnings = showWarnings)

    if(vehcomp["PC"] > 0){
      for(i in 1:vehcomp[1]){
        if(i < 10) {
          dir.create(path = paste0(name, "/emi/PC_0", i), showWarnings = showWarnings)
        } else {
          dir.create(path = paste0(name, "/emi/PC_", i), showWarnings = showWarnings)
        }}
    } else {message("no PC")}

    if(vehcomp["LCV"] > 0){
      for(i in 1:vehcomp[2]){
        if(i < 10) {
          dir.create(path = paste0(name, "/emi/LCV_0", i), showWarnings = showWarnings)
        } else {
          dir.create(path = paste0(name, "/emi/LCV_", i), showWarnings = showWarnings)
        }}
    } else {message("no LCV")}

    if(vehcomp["HGV"] > 0){
      for(i in 1:vehcomp[3]){
        if(i < 10) {
          dir.create(path = paste0(name, "/emi/HGV_0", i), showWarnings = showWarnings)
        } else {
          dir.create(path = paste0(name, "/emi/HGV_", i), showWarnings = showWarnings)
        }}
    } else {message("no HGV")}

    if(vehcomp["BUS"] > 0){
      for(i in 1:vehcomp[4]){
        if(i < 10) {
          dir.create(path = paste0(name, "/emi/BUS_0", i), showWarnings = showWarnings)
        } else {
          dir.create(path = paste0(name, "/emi/BUS_", i), showWarnings = showWarnings)
        }}
    } else {message("no BUS")}

    if(vehcomp["MC"] > 0){
      for(i in 1:vehcomp[5]){
        if(i < 10) {
          dir.create(path = paste0(name, "/emi/MC_0", i), showWarnings = showWarnings)
        } else {
          dir.create(path = paste0(name, "/emi/MC_", i), showWarnings = showWarnings)
        }}
    } else {message("no MC")}
  }
  if(clear == FALSE){
    dovein()
  } else {
    unlink(name, recursive=TRUE)
    dovein()
  }
  # # files
  if(scripts == FALSE){
    message("no scripts")
  } else{
    lista <- list.dirs(path = paste0(name,"/emi"))
    lista <- lista[2:length(lista)]
    lista2 <- gsub(pattern = name, x = lista, replacement = "")
    lista3 <- gsub(pattern = "/emi/", x = lista2, replacement = "")

    dirs <- list.dirs(path = name, full.names = TRUE)

    for (i in 1:length(lista)){
      sink(paste0(dirs[1], "/est/", lista3[i],"_input.R"))
      cat("# Network \n")
      cat("net <- readRDS('network/net.rds')\n")
      cat("lkm <- net$lkm\n")
      cat("# speed <- readRDS('network/speed.rds')\n\n")
      cat("# Vehicles\n")
      cat(paste0("veh <- readRDS('veh/", lista3[[i]], ".rds')"), "\n")
      cat("# Profiles\n")
      cat("data(profiles)\n")
      if(rush.hour){
        cat("pc <- matrix(1)\n")
      } else{
        cat("pc <- profiles[[1]]\n")
      }
      cat("# pc <- read.csv('profiles/pc.csv') #Change with your data\n")
      cat("# Emission Factors data-set\n")
      cat("data(fe2015)\n")
      cat("efe <- fe2015\n")
      cat("# efe <- read.csv('ef/fe2015.csv')\n")
      cat("efeco <- 'PC_G' # Character to identify the column of the respective EF\n")
      cat("efero <- ifelse(is.data.frame(veh), ncol(veh), ncol(veh[[1]]))\n")
      cat("# efero reads the number of the vehicle distribution\n")
      cat("trips_per_day <- 5\n\n")
      cat("# Mileage, Check name of categories with names(fkm)\n")
      cat("# data(fkm)\n")
      cat("# pckm <- fkm[['KM_PC_E25']](1:efero)\n")
      cat("# pckm <- cumsum(pckm)\n\n")
      cat("# Sulphur\n")
      cat("# sulphur <- 50 # ppm\n\n\n")
      cat("# Input and Output\n\n")
      cat(paste0("directory <- ", deparse(lista3[i]), "\n"))
      cat("vfuel <- 'E_25' \n")
      cat("vsize <- '' # It can be small/big/<=1400, one word\n")
      cat("vname <- ", deparse(lista3[i]), "\n")
      cat("\n\n")
      cat("# CO \n")
      cat("pol <- 'CO' \n")
      cat("print(pol)\n")
      cat("message('This is just an example!\n You need to update this to your project!')\n")
      cat("x <- efe[efe$Pollutant == pol, 'PC_G']\n")
      cat("lefe <- EmissionFactorsList(x)\n")
      cat("array_x <- emis(veh = veh, lkm = lkm, ef = lefe, profile = pc,
          speed = Speed(34))\n")
      cat("x_DF <- emis_post(arra = array_x, veh = vname, size = vsize,\n")
      cat("                  fuel = vfuel, pollutant = pol, by = 'veh')\n")
      cat("x_STREETS <- emis_post(arra = array_x, pollutant = pol,\n")
      cat("                       by = 'streets_wide') \n")
      cat("saveRDS(x_DF, file = paste0('emi/',",
          deparse(lista3[i]),
          ",'_', pol, '_DF.rds'))\n")
      cat("saveRDS(x_STREETS, file = paste0('emi/',",
          deparse(lista3[i]),
          ",'_', pol, '_STREETS.rds'))\n")
      cat("rm(array_x, x_DF, x_STREETS, pol, lefe)\n\n")
      cat("# Other Pollutants...")
      sink()
    }
    dirs <- list.dirs(path = name, full.names = TRUE, recursive = TRUE)

    message(paste0("Project directory at ", dirs[1]))
    # message(paste0("main file ", name, "/main.R"))
    sink(paste0(name, "/main.R"))
    cat(paste0("prev <- getwd()\n"))
    cat("#Changing working directory\n")
    cat(paste0("print(setwd('", dirs[1], "'))\n"))
    cat("library(vein)\n")
    cat("sessionInfo()\n\n")
    cat("# 0 Delete previous emissions? ####\n")
    cat("# borrar <- list.files('emi',\n")
    cat("#                      pattern = '.rds', recursive = TRUE,\n")
    cat("#                      full.names = TRUE)\n\n")
    cat("# 1) Network ####\n")
    cat("# Edit your net information and save net.rds it in network directory\n")
    cat("# Your net must contain traffic per street at morning rush hour\n")
    cat("# Below an example using the data in VEIN\n")
    cat("data(net)\n")
    cat("net <- sf::st_as_sf(net)\n")
    cat("net <- sf::st_transform(net, 31983)\n")
    cat("saveRDS(net, 'network/net.rds')\n\n")
    cat("## Are you going to need Speed?\n")
    cat("data(pc_profile)\n")

    if(rush.hour){
      cat("speed <- data.frame(S8 = net$ps)\n")
      cat("saveRDS(speed, 'network/speed.rds')\n\n")
    } else{
      cat("pc_week <- temp_fact(net$ldv+net$hdv, pc_profile)\n")
      cat("speed <- netspeed(pc_week, net$ps, net$ffs, net$capacity, net$lkm, alpha = 1)\n")
      cat("saveRDS(speed, 'network/speed.rds')\n\n")
    }

    cat("# 2) Traffic ####\n")
    cat("# Edit your file traffic.R\n\n")
    cat("source('traffic.R') # Edit traffic.R\n\n")
    cat("# 3) Estimation #### \n")
    cat("# Edit each input.R\n")
    cat("# You must have all the information required in each input.R\n")
    cat("inputs <- list.files(path = 'est', pattern = 'input.R',\n")
    cat("                     recursive = TRUE, full.names = TRUE)\n")
    cat("for (i in 1:length(inputs)){\n")
    cat( "  print(inputs[i])\n" )
    cat( "  source(inputs[i])\n" )
    cat("}\n")
    cat("# 4) Post-estimation #### \n")
    cat("g <- make_grid(net, 1000)\n")
    cat("source('post.R')\n")
    cat("#Changing to original working directory\n")
    cat("print(setwd(prev))\n")
    sink()

    sink(paste0(name, "/traffic.R"))
    cat("net <- readRDS('network/net.rds')\n")
    cat("PC_01 <- age_ldv(x = net$ldv, name = 'PC', k = 3/4)\n")
    cat("saveRDS(PC_01, file = 'veh/PC_01.rds')\n")
    cat("LCV_01 <- age_ldv(x = net$ldv, name = 'LCV', k = 1/4/2)\n")
    cat("saveRDS(PC_01, file = 'veh/LCV_01.rds')\n")
    cat("HGV_01 <- age_ldv(x = net$hdv, name = 'HGV', k = 3/4)\n")
    cat("saveRDS(PC_01, file = 'veh/HGV_01.rds')\n")
    cat("BUS_01 <- age_ldv(x = net$hdv, name = 'BUS', k = 1/4)\n")
    cat("# BUS only for example  purposes\n")
    cat("# BUS a traffic simulation only for BUS, or other source of information\n")
    cat("saveRDS(BUS_01, file = 'veh/BUS_01.rds')\n")
    cat("MC_01 <- age_ldv(x = net$ldv, name = 'MC', k = 1/4/2)\n")
    cat("saveRDS(MC_01, file = 'veh/MC_01.rds')\n")
    cat(" # Add more\n")
    sink()

    sink(paste0(name, "/post.R"))
    cat("# streets ####\n")
    cat("CO <- emis_merge('CO', net = net)\n")
    cat("saveRDS(CO, 'post/streets/CO.rds')\n\n")
    cat("# grids ####\n")
    cat("gCO <- emis_grid(CO, g)\n")
    cat("print(plot(gCO['V1'], axes = TRUE)) # only an example\n\n")
    cat("saveRDS(gCO, 'post/grids/gCO.rds')\n\n")
    cat("# df ####\n")
    cat("dfCO <- emis_merge('CO', what = 'DF.rds', FALSE)\n")
    cat("saveRDS(dfCO, 'post/df/dfCO.rds')\n")
    cat("aggregate(dfCO$g, by = list(dfCO$veh), sum, na.rm = TRUE) # Only an example\n\n")
    cat(" # Add more\n")
    sink()
  }

  if(show.dir){
    dirs <- list.dirs(path = name, full.names = TRUE, recursive = TRUE)
    cat("Directories:\n")
    print(dirs)
  }
  if(show.scripts){
    sc <- list.files(path = name, pattern = ".R", recursive = TRUE)
    cat("Scripts:\n")
    print(sc)
  }
if(show.main)  utils::file.edit(paste0(name, "/main.R"))
}
