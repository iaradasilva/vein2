# apagando dados
file.copy("scripts/backup_evaporatives.R",
          "scripts/evaporatives.R", 
          overwrite = TRUE)

file.copy("scripts/backup_exhaust.R",
          "scripts/exhaust.R", 
          overwrite = TRUE)

file.copy("scripts/backup_fuel_eval.R",
          "scripts/fuel_eval.R", 
          overwrite = TRUE)

file.remove(c("scripts/backup_evaporatives.R",
              "scripts/backup_exhaust.R",
              "scripts/backup_fuel_eval.R"))


a <- list.files(path = "config", pattern = ".rds", full.names = T)
file.remove(a)

unlink("csv", recursive = T)
unlink("emi", recursive = T)
unlink("images", recursive = T)
unlink("notes", recursive = T)
unlink("post", recursive = T)
unlink("wrf/wrfc*")
unlink("veh", recursive = T)

d <- list.dirs(path = "wrf", full.names = T, recursive = T)
if(length(d) > 1) {
  d <- list.dirs(path = "wrf", full.names = T, recursive = T)
  d <- d[length(d)]
  unlink(d, force = T, recursive = T)
}


system(paste0("tar -caf ", basename(getwd()), ".tar.gz ."))
system(paste0("mv ", basename(getwd()), ".tar.gz ../"))
file.remove(".Rhistory")
# suppressWarnings(source("config/clean.R"))