library(sf)

switch(language,
        "portuguese" = cat("\nNomes:\n ", names(net), "\n"),
        "english" = cat("\nNames:\n ", names(net), "\n"),
        "spanish" = cat("\nNombres:\n ", names(net), "\n")
)

net <- st_transform(net, crs)
# A composição veicular da CETESB tem 28 tipos de categories
# Em teoría, poderiamos ter 28 fluxos ou mais na rede net

# The number of traffic flow vehicles can be the same from vehicular composition
#
categories <- metadata$vehicles
for (i in seq_along(categories)) {
        png(
                filename = paste0("images/NET_", categories[i], ".png"),
                width = 2300, height = 1500, units = "px", pointsize = 12,
                bg = "white", res = 300
        )
  
        plot(net[categories[i]],
                axes = T,
                pal = cpt(colorRampPalette = T, rev = T),
                main = paste0(tit, ": ", categories[i])
        )
        
        dev.off()
}
# calculates lkm
net$lkm <- units::set_units(st_length(net), km)

saveRDS(net, "network/net.rds")

switch(language,
        "portuguese" = message("\nArquivos em: /net:"),
        "english" = message("\nFiles in: /net"),
        "spanish" = message("\nArchivos en: /net")
)

switch(language,
        "portuguese" = message("Figuras em: /images:"),
        "english" = message("Figures in: /images"),
        "spanish" = message("Figuras en: /images")
)

switch(language,
        "portuguese" = message("Limpando..."),
        "english" = message("Cleaning..."),
        "spanish" = message("Limpiando...")
)

suppressWarnings(
        rm(i, tit, net, categories, crs)
)
invisible(gc())