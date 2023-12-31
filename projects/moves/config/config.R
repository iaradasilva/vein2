# apagando dados ####
a <- list.files(path = "config", pattern = ".rds", full.names = T)
file.remove(a)

# configuracao ####
metadata <- as.data.frame(metadata)
mileage <- as.data.frame(mileage)
mileage[, metadata$vehicles] <- add_miles(mileage[, metadata$vehicles])
tfs <- as.data.frame(tfs)
veh <- as.data.frame(veh)
vmt_age <- as.data.frame(vmt_age)
fuel <- as.data.frame(fuel)
fuel_type <- as.data.frame(fuel_type)
met <- as.data.frame(met)

setDT(met)
setDT(fuel)

# checkar metadata$vehicles ####
switch(language,
       "portuguese" = cat("Metadata$Vehicles é:\n"),
       "english" = cat("Metadata$Vehicles is:\n"),
       "spanish" = cat("Metadata$Vehicles es:\n")
)

# cat( "Metadata$Vehicles é:\n")
print(metadata$vehicles)

# checar nomes mileage ####
if (!length(intersect(metadata$vehicles, names(mileage))) == length(metadata$vehicles)) {
  switch(language,
         "portuguese" = stop(
           "Precisa adicionar coluna ",
           setdiff(metadata$vehicles, names(mileage)),
           " em `mileage`"
         ),
         "english" = stop(
           "You need to add column ",
           setdiff(metadata$vehicles, names(mileage)),
           " in `mileage`"
         ),
         "spanish" = stop(
           "Necesitas agregar la columna ",
           setdiff(metadata$vehicles, names(mileage)),
           " en `mileage`"
         )
  )
}

# checar nomes tfs ####
if (!length(intersect(metadata$vehicles, names(tfs))) == length(metadata$vehicles)) {
  switch(language,
         "portuguese" = stop(
           "Precisa adicionar coluna ",
           setdiff(metadata$vehicles, names(mileage)),
           " em `tfs`"
         ),
         "english" = stop(
           "You need to add column ",
           setdiff(metadata$vehicles, names(mileage)),
           " in `tfs`"
         ),
         "spanish" = stop(
           "Necesitas agregar la columna ",
           setdiff(metadata$vehicles, names(mileage)),
           " en `tfs`"
         )
  )
}

# checar nomes veh ####
if (!length(intersect(metadata$vehicles, names(veh))) == length(metadata$vehicles)) {
  switch(language,
         "portuguese" = stop(
           "Precisa adicionar coluna ",
           setdiff(metadata$vehicles, names(mileage)),
           " em `veh`"
         ),
         "english" = stop(
           "You need to add column ",
           setdiff(metadata$vehicles, names(mileage)),
           " in `veh`"
         ),
         "spanish" = stop(
           "Necesitas agregar la columna ",
           setdiff(metadata$vehicles, names(mileage)),
           " en `veh`"
         )
  )
}

# checar Year ####
if (!"Year" %in% names(veh)) {
  switch(language,
         "portuguese" = stop("Não estou enxergando a coluna 'Year' em `veh`"),
         "english" = stop("I'm not seeing column 'Year' in `veh`"),
         "spanish" = stop("No estoy viendo la columna 'Year' in `veh`")
  )
}


# veh
veh <- veh[veh$Year <= year, ][1:31,]
dim(veh)

veh[is.na(veh)] <- 0

switch(language,
       "portuguese" = message("Arquivos em: ", getwd(), "/config/*\n"),
       "english" = message("Files in: ", getwd(), "/config/*\n"),
       "spanish" = message("Archivos en: ", getwd(), "/config/*\n")
)
#fuel
names(fuel)
head(fuel)
fuel <- fuel[Year == year & Month == month]


# met ####

met <- met[Year == year & Month == month]

saveRDS(metadata, "config/metadata.rds")
saveRDS(mileage, "config/mileage.rds")
saveRDS(tfs, "config/tfs.rds")
saveRDS(veh, "config/fleet_age.rds")
saveRDS(fuel, "config/fuel.rds")
saveRDS(fuel_type, "config/fuel_type.rds")
saveRDS(met, "config/met.rds")

# pastas
if (delete_directories) {
  choice <- 1
  
  if (language == "portuguese") {
    # choice <- utils::menu(c("Sim", "Não"), title="Apagar pastas csv, emi, images, notes, post e veh??")
    if (choice == 1) {
      message("Apagando pastas `emi`, `images`, `notes`, `post` e `veh`")
      unlink("csv", recursive = T)
      unlink("emi", recursive = T)
      unlink("images", recursive = T)
      unlink("notes", recursive = T)
      unlink("post", recursive = T)
      unlink("veh", recursive = T)
    }
  } else if (language == "english") {
    # choice <- utils::menu(c("Yes", "No"), title="Delete folders `csv`, `emi`, `images`, `notes`, `post` e `veh`??")
    if (choice == 1) {
      message("Deleting folders `emi`, `images`, `notes`, `post` and `veh`")
      unlink("csv", recursive = T)
      unlink("emi", recursive = T)
      unlink("images", recursive = T)
      unlink("notes", recursive = T)
      unlink("post", recursive = T)
      unlink("veh", recursive = T)
    }
  } else if (language == "spanish") {
    # choice <- utils::menu(c("Si", "No"), title="Borrar carpetas `csv`, `emi`, `images`, `notes`, `post` y `veh`??")
    if (choice == 1) {
      message("Borrando carpetas `emi`, `images`, `notes`, `post` y `veh`")
      unlink("csv", recursive = T)
      unlink("emi", recursive = T)
      unlink("notes", recursive = T)
      unlink("images", recursive = T)
      unlink("post", recursive = T)
      unlink("veh", recursive = T)
    }
  }
}

dir.create(path = "csv", showWarnings = FALSE)
dir.create(path = "emi", showWarnings = FALSE)
dir.create(path = "emi/FC", showWarnings = FALSE)
dir.create(path = "emi/emissions_rate_per_distance", showWarnings = FALSE)
dir.create(path = "emi/emissions_rate_per_vehicle", showWarnings = FALSE)

dir.create(path = "images", showWarnings = FALSE)
dir.create(path = "notes", showWarnings = FALSE)
dir.create(path = "post", showWarnings = FALSE)
dir.create(path = "post/datatable", showWarnings = FALSE)
dir.create(path = "post/streets", showWarnings = FALSE)
dir.create(path = "post/grids", showWarnings = FALSE)
dir.create(path = "veh", showWarnings = FALSE)

# for (i in seq_along(metadata$vehicles)) dir.create(path = paste0("emi/", metadata$vehicles[i]))


pa <- list.dirs(path = "emi", full.names = T, recursive = T)
po <- list.dirs("post", full.names = T, recursive = T)

switch(language,
       "portuguese" = message("Novas pastas:"),
       "english" = message("New directories:"),
       "spanish" = message("Nuevas carpetas")
)

message("csv\n")
message("images\n")
message(paste0(po, "\n"))
message(paste0(pa, "\n"))
message("veh\n")

# names groups ####
n_PC <- metadata$vehicles[grep(pattern = "PC", x = metadata$vehicles)]
n_PT <- metadata$vehicles[grep(pattern = "PT", x = metadata$vehicles)]
n_LCT <- metadata$vehicles[grep(pattern = "LCT", x = metadata$vehicles)]
n_TRUCKS <- metadata$vehicles[grep(pattern = "TRUCKS", x = metadata$vehicles)]
n_BUS <- metadata$vehicles[grep(pattern = "BUS", x = metadata$vehicles)]
n_MC <- metadata$vehicles[grep(pattern = "MC", x = metadata$vehicles)]
n_veh <- list(
  PC = n_PC,
  PT = n_PT,
  LCT = n_LCT,
  TRUCKS = n_TRUCKS,
  BUS = n_BUS,
  MC = n_MC
)
# Fuel ####
switch(language,
       "portuguese" = cat("Plotando combustivel \n"),
       "english" = cat("Plotting fuel \n"),
       "spanish" = cat("Plotando combustible \n")
)

png("images/FUEL.png", width = 1500, height = 2000, units = "px", res = 300)
barplot(
  height = fuel$gallons,
  names.arg = fuel$fuel, xlab = "Fuel",
  ylab = "gallons",
  main = paste0("Fuel consumded during Year ", year, " and month ", month)
)
month
dev.off()

setDF(veh)
# Fleet ####
switch(language,
       "portuguese" = cat("Plotando frota \n"),
       "english" = cat("Plotting fleet \n"),
       "spanish" = cat("Plotando flota \n")
)

for (i in seq_along(n_veh)) {
  df_x <- as.data.frame(veh[, n_veh[[i]]])
  if(ncol(df_x) == 1) {
    names(df_x) <- n_veh[i][[1]]
  }
  png(
    paste0(
      "images/FLEET_",
      names(n_veh)[i],
      ".png"
    ),
    2000, 1500, "px",
    res = 300
  )
  colplot(
    df = df_x,
    cols = n_veh[[i]],
    xlab = "Age",
    ylab = "veh",
    main = names(n_veh)[i],
    type = "l",
    pch = NULL,
    lwd = 1,
    theme = theme,
    spl = 8
  )
  dev.off()
}

# Plot TFS ####
switch(language,
       "portuguese" = cat("Plotando perfis `tfs`\n"),
       "english" = cat("Plotting profiles `tfs`\n"),
       "spanish" = cat("Plotando perfiles `tfs`\n")
)

for (i in seq_along(n_veh)) {
  df_x <- as.data.frame(tfs[, n_veh[[i]]])
  if(ncol(df_x) == 1) {
    names(df_x) <- n_veh[i][[1]]
  }
  png(
    paste0(
      "images/TFS_",
      names(n_veh)[i],
      ".png"
    ),
    2000, 1500, "px",
    res = 300
  )
  colplot(
    df = df_x,
    cols = n_veh[[i]],
    xlab = "Hour",
    ylab = "",
    main = paste0("TFS ", names(n_veh)[i]),
    type = "l",
    pch = NULL,
    lwd = 1,
    theme = theme,
    spl = 8
  )
  dev.off()
}


# Plot Mileage ####
switch(language,
       "portuguese" = cat("Plotando quilometragem \n"),
       "english" = cat("Plotting mileage `tfs`\n"),
       "spanish" = cat("Plotando kilometraje `tfs`\n")
)

for (i in seq_along(n_veh)) {

  df_x <- as.data.frame(mileage[, n_veh[[i]]])
  if(ncol(df_x) == 1) {
    names(df_x) <- n_veh[i][[1]]
  }
  png(
    paste0(
      "images/MILEAGE_",
      names(n_veh)[i],
      ".png"
    ),
    2000, 1500, "px",
    res = 300
  )
  colplot(
    df = df_x,
    cols = n_veh[[i]],
    xlab = "Age of use",
    ylab = "[km/year]",
    main = paste0("Mileage ", names(n_veh)[i]),
    type = "l",
    pch = NULL,
    lwd = 1,
    theme = theme,
    spl = 8
  )
  dev.off()
}



# Plot vmt_age ####
switch(language,
       "portuguese" = cat("Plotando vmt \n"),
       "english" = cat("Plotting vmt \n"),
       "spanish" = cat("Plotando vmt \n")
)

for (i in seq_along(n_veh)) {
  
  df_x <- as.data.frame(vmt_age[, n_veh[[i]]])
  if(ncol(df_x) == 1) {
    names(df_x) <- n_veh[i][[1]]
  }
  png(
    paste0(
      "images/VMT_AGE_",
      names(n_veh)[i],
      ".png"
    ),
    2000, 1500, "px",
    res = 300
  )
  colplot(
    df = df_x,
    cols = n_veh[[i]],
    xlab = "Age of use",
    ylab = "[km/year]",
    main = paste0("VMT ", names(n_veh)[i]),
    type = "l",
    pch = NULL,
    lwd = 1,
    theme = theme,
    spl = 8
  )
  dev.off()
}


# Temperature ####
png("images/Temperature.png",
    2000, 1500, "px",
    res = 300
)
colplot(
  df = met,
  cols = "Temperature",
  xlab = "Months",
  ylab = "°F",
  main = "Temperature",
  type = "l",
  pch = NULL,
  lwd = 1,
  theme = theme,
  spl = 8
)
dev.off()

# Notes ####
switch(language,
       "portuguese" = cat("\nFazendo anotações\n"),
       "english" = cat("\nTaking some notes\n"),
       "spanish" = cat("\nEscribiendo notas\n")
)

vein_notes(
  notes = c("Default notes for vein::get_project"),
  file = "notes/README",
  title = paste0(basename(getwd()), year),
  approach = "Bottom-up",
  traffic = "AADT",
  composition = "MOVES",
  ef = "MOVES ",
  cold_start = "Not Applicable",
  evaporative = "all",
  standards = "US/EPA",
  mileage = "US/EPA"
)

# message ####
switch(language,
       "portuguese" = message("\nArquivos em:"),
       "english" = message("\nFiles in:"),
       "spanish" = message("\nArchivos en:")
)

message(
  "config/metadata.rds\n",
  "config/tfs.rds\n",
  "config/fleet_age.rds\n",
  "config/fuel.rds\n"
)

switch(language,
       "portuguese" = message("\nFiguras em /images\n"),
       "english" = message("\nFigures in /image\n"),
       "spanish" = message("\nFiguras en /images\n")
)

switch(language,
       "portuguese" = message("Limpando..."),
       "english" = message("Cleaning..."),
       "spanish" = message("Limpiando...")
)


suppressWarnings(
  rm(i, choice, pa, metadata, po, tfs, veh, mileage, fuel, theme,
     n_PC, n_LCV, n_TRUCKS, n_BUS, n_MC, df_x, ef, cores, vkm, ef, a, rota,
     delete_directories, met, month, n_veh, scale, path, year)
)