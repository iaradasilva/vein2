suppressWarnings(file.remove("emi/EVAP_DF.csv"))
suppressWarnings(file.remove("emi/EVAP_STREETS.csv"))



# temperature
te <- met$Temperature
bb <- (0 + 15) / 2
cc <- (10 + 25) / 2
dd <- (20 + 35) / 2

tem <- ifelse(
  te <= bb, "0_15",
  ifelse(
    te > bb & te <= cc, "10_25",
    "20_35"))

# filtrando veiculos otto
meta_ev <- metadata[metadata$fuel != "D", ]
veh_ev <- meta_ev$vehicles

# checks name
type_emis <- c("Diurnal", "Running Losses", "Hot Soak")
name_file_evap <- c("/DIURNAL_", "/RUNNING_LOSSES_", "/HOT_SOAK_")

ef_d <- paste0("D_", tem)
ef_rl <- paste0("R_", tem)
ef_hs <- paste0("S_", tem)

# plot
n_PC <- metadata[metadata$family == "PC", ]$vehicles
n_LCV <- metadata[metadata$family == "LCV", ]$vehicles[1:4]
n_MC <- metadata[metadata$family == "MC", ]$vehicles

ns <- c(
  "PC", "LCV", "MC",
  "PC", "LCV", "MC",
  "PC", "LCV", "MC"
)
ln <- list(
  n_PC, n_LCV, n_MC,
  n_PC, n_LCV, n_MC,
  n_PC, n_LCV, n_MC
)
laby <- c(
  "g/day", "g/day", "g/day",
  "g/trip", "g/trip", "g/trip",
  "g/trip", "g/trip", "g/trip"
)
ev <- c(
  "DIURNAL", "DIURNAL", "DIURNAL",
  "RUNNING_LOSSES", "RUNNING_LOSSES", "RUNNING_LOSSES",
  "HOT_SOAK", "HOT_SOAK", "HOT_SOAK"
)

# plotting
switch(language,
       "portuguese" = cat("Plotando EF\n"),
       "english" = cat("Plotting EF\n"),
       "spanish" = cat("Plotando EF\n")
)

for (i in seq_along(ns)) {
  dl <- lapply(seq_along(ef_d), function(j) {
    data.frame(ef_cetesb(
      p = ef_d[j], 
      veh = ln[[i]], 
      year = year,
      agemax = 40, 
      verbose = verbose
    ), 
    month = nmonth[j])
  })
  
  dl <- rbindlist(dl)
  df <- wide_to_long(
    df = dl,
    column_with_data = ln[[i]],
    column_fixed = "month"
  )
  df$age <- 1:40
  setDT(df)
  names(df) <- c("ef", "month", "veh", "age")
  p <- ggplot(
    df[df$ef > 0, ],
    aes(x = age, 
        y = ef, 
        colour = veh)
  ) +
    geom_line() +
    facet_wrap(~month) +
    ylim(0, NA) +
    labs(y = laby[i], 
         title = ev[i]) +
    # scale_y_log10() +
    theme_bw()
  
  png(
    filename = paste0("images/EF_", ev[i], "_", ns[i], ".png"),
    width = 2100, 
    height = 1500, 
    units = "px", 
    pointsize = 12,
    bg = "white", 
    res = 300
  )
  print(p)
  dev.off()
}

switch(language,
       "portuguese" = message("\nFiguras em /images\n"),
       "english" = message("\nFigures in /image\n"),
       "spanish" = message("\nFiguras en /images\n")
)



switch(language,
       "portuguese" = cat("\nEmissões evaporativas\n"),
       "english" = cat("\nEvaporative diurnal\n"),
       "spanish" = cat("\nEmisiones evaporativas\n")
)

evtype <- c("Diurnal", "Running Losses", "Hot Soak")

for (i in seq_along(veh_ev)) {
  
  cat(
    "\n", veh_ev[i],
    rep("", max(nchar(veh_ev) + 1) - nchar(veh_ev[i])),
    "\n"
  )
  
  x <- readRDS(paste0("veh/", veh_ev[i], ".rds"))
  
  for (j in seq_along(te)) {
    cat("\nhour ", j, " ")
    
    
    for(k in seq_along(evtype)) {
      cat(evtype[k], " ")
      
      if(evtype[k] == "Diurnal") {
        
        ef <- ef_cetesb(
          p = ef_d[j],
          veh = veh_ev[i],
          year = year,
          agemax = ncol(x),
          # diurnal: g/day* day/km= g/km
          verbose = verbose
        ) / (mileage[[veh_ev[i]]] / 365) # mean daily mileage 
        
      } else if(evtype[k] == "Running Losses"){
        
        ef <- ef_cetesb(
          p = ef_rl[j],
          veh = veh_ev[i],
          year = year,
          agemax = ncol(x),
          # g/trip * trip/day * day/km = g/km
          verbose = verbose
        ) * meta_ev$trips_day[i] / (mileage[[veh_ev[i]]] / 365)
        
      } else {
        
        ef <- ef_cetesb(
          p = ef_hs[j],
          veh = veh_ev[i],
          year = year,
          agemax = ncol(x),
          # g/trip * trip/day * day/km = g/km
          verbose = verbose
        ) * meta_ev$trips_day[i] / (mileage[[veh_ev[i]]] / 365)
      }
      
      
      # muda NaNaN para 0
      ef[is.na(ef)] <- 0
      
      array_x <- emis(
        veh = x,
        lkm = lkm,
        ef = ef,
        profile = tfs[[veh_ev[i]]][j],
        fortran = TRUE,
        nt = check_nt() / 2,
        simplify = TRUE,
        verbose = verbose
      )
      
      x_DF <- emis_post(
        arra = array_x,
        veh = veh_ev[i],
        size = meta_ev$size[i],
        fuel = meta_ev$fuel[i],
        pollutant = "NMHC",
        type_emi = evtype[k],
        by = "veh"
      )
      x_DF$hour <- j
      
      fwrite(x_DF, 
             "emi/EVAP_DF.csv", 
             append = TRUE)
      
      
      x_STREETS <- emis_post(
        arra = array_x,
        pollutant = veh_ev[j],
        by = "streets"
      )
      
      
      x_STREETS$id <- 1:nrow(net)
      x_STREETS$family <- meta_ev$family[i]
      x_STREETS$vehicles <- meta_ev$vehicles[i]
      x_STREETS$fuel <- meta_ev$fuel[i]
      x_STREETS$pol <- evtype[k]
      x_STREETS$hour <- j
      
      fwrite(x_STREETS, 
             "emi/EVAP_STREETS.csv", 
             append = TRUE)
      
    }# type of ev
    
    } #hourly temp
  rm(array_x, ef, x, x_DF, x_STREETS)
}  # 4 strokes veh



x <- fread("emi/EVAP_STREETS.csv")

x$hour <- paste0("V", x$hour)

dcast.data.table(data = x, 
                 formula = id + 
                   family + 
                   vehicles + 
                   fuel + 
                   pol ~ hour, 
                 value.var = "V1") -> xx

xxx <- xx[, 
          c(paste0("V", 1:nrow(tfs)), 
            "id",
            "family",
            "vehicles",
            "fuel",
            "pol" ), 
          with = FALSE]

fwrite(xxx, "emi/EVAP_STREETS.csv")


switch(language,
       "portuguese" = message("\n\nArquivos em: /emi/*:"),
       "english" = message("\nFiles in: /emi/*"),
       "spanish" = message("\nArchivos en: /emi/*")
)


switch(language,
       "portuguese" = message("Limpando..."),
       "english" = message("Cleaning..."),
       "spanish" = message("Limpiando...")
)

suppressWarnings(rm(
  i, mileage, meta_ev, veh_ev, year,
  diurnal_ef, hot_soak_ef, running_losses_ef,
  x, xx, xxx
))

invisible(gc())