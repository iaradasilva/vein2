library(vein)
library(sf)
library(sp)
library(units)
library(ggplot2)
#library(RColorBrewer)
# library(DiagrammeR)


## ---- fig.width=8, fig.height=6------------------------------------------
# 1 ####
data(net) ; net <- as_Spatial(net)
class(net$ldv) <- "numeric"

spplot(net, "ldv", scales=list(Draw=T),cuts=12,
       colorkey = list(space = "bottom", height = 1),
       col.regions = rev(bpy.colors(13)))

# 2 ####
PC_G <- c(33491,22340,24818,31808,46458,28574,24856,28972,37818,49050,87923,
          133833,138441,142682,171029,151048,115228,98664,126444,101027,
          84771,55864,36306,21079,20138,17439, 7854,2215,656,1262,476,512,
          1181, 4991, 3711, 5653, 7039, 5839, 4257,3824, 3068)
veh <- data.frame(PC_G = PC_G)
pc1 <- my_age(x = net$ldv, y = PC_G, name = "PC")
pc2 <- age_ldv(x = net$ldv,name = "PC",agemax = 41)
pc3 <- age_ldv(x = net$ldv,name = "PC",b=-0.14,agemax = 41)

df <- data.frame(pc = c(colSums(pc1),colSums(pc2),colSums(pc3)),
                 Age = c(rep(15.17,41),rep(11.09,41),rep(15.53,41)),
                 x = rep(1:41,3))

ggplot(df, aes(x = x, y = pc, colour = as.factor(Age))) + geom_point(size=3)  +
  geom_line() + theme_bw() + labs(x="Age", y="Distribution") +
  theme(legend.position = c(0.8,0.8)) +
  guides(colour = guide_legend(keywidth = 2, keyheight = 2))+
  scale_color_discrete(name = "Average age")

# 3 ####
data("profiles")
pc_profile <- profiles$PC_JUNE_2012
df2 <- data.frame(TF = as.numeric(unlist(pc_profile)),
                  Hour = rep(1:24,7),
                  Day = c(rep("Monday",24),
                          rep("Tuesday",24),
                          rep("Wednesday",24),
                          rep("Thursday",24),
                          rep("Friday",24),
                          rep("Saturday",24),
                          rep("Sunday",24)))
df2$Day <- factor(df2$Day,
                  levels =  c("Monday", "Tuesday", "Wednesday", "Thursday",
                              "Friday", "Saturday", "Sunday"))
ggplot(df2, aes(x = Hour, y = TF, colour = Day,
                shape = Day)) + geom_point(size = 4)  +
  geom_line() + theme_bw() + labs(x = "Hours", y = "TF") +
  theme(legend.position = c(0.1,0.7))+
  guides(colour = guide_legend(keywidth = 2, keyheight = 2))

# 4 ####


# 5 ####
data(net)
net <- as_Spatial(net)
data("profiles")
pc_profile <- profiles$PC_JUNE_2012
pcw <- temp_fact(net$ldv+net$hdv, pc_profile)
df <- netspeed(pcw, net$ps,
               net$ffs, net$capacity, net$lkm, alpha = 1)

net@data$nts <- as.factor(
  ifelse(
    net@data$tstreet==1, "Other",
    ifelse(
      net@data$tstreet==2, "Arterial",
      ifelse(
        net@data$tstreet==3, "Arterial",
        ifelse(
          net@data$tstreet==4, "Arterial",
          ifelse(
            net@data$tstreet==5, "Collect",
            ifelse(
              net@data$tstreet==6, "Collect",
              ifelse(
                net@data$tstreet==7, "Local",
                ifelse(
                  net@data$tstreet==37, "Local",
                  ifelse(
                    net@data$tstreet==41, "Motorway",
                    ifelse(
                      net@data$tstreet==42, "Motorway",
                      "Other")))))))))))

net@data <- cbind(net@data,df)

spplot(net, c("S8","S23"), scales=list(Draw=T),
       col.regions = rev(bpy.colors(16)))

speed <- netspeed(pcw, net$ps, net$ffs, net$capacity, net$lkm, alpha = 1)

# 6 ####
df2 <- aggregate(net@data[,11:178], by=list(net$nts), mean )
df3 <- as.data.frame(t(df2[,2:169]))
names(df3) <- as.character(t(df2[,1]))
df4 <- data.frame(speed =c(df3$Arterial,df3$Collect,df3$Local,df3$Motorway),
                  Street = c(rep("Arterial",168),
                             rep("Collect",168),
                             rep("Local",168),
                             rep("Motorway",168)),
                  Hour = rep(1:168,4))

ggplot(df4, aes(x=Hour, y=speed, colour=Street)) +
  geom_point(size=3) + geom_line() +theme_bw()+
  labs(x=NULL, y="Spped (km/h)") +
  guides(colour = guide_legend(keywidth = 3))+
  theme(legend.position = "bottom", legend.key.width  = unit(2,units="cm"))

# 7 ####
fe2015 <- ef_cetesb(p = c("CO"), veh = "PC_G", full = T, agemax = 36)
names(fe2015)[ncol(fe2015)] <- "PC_G"
names(fe2015)[5] <- "Euro_LDV"
data("profiles")
pc_profile <- profiles$PC_JUNE_2012
data(fkm)
pckm <- fkm[[1]](1:24)
pckma <- cumsum(pckm)
kma <- units::set_units(pckma[1:11], km)
kmb <- units::set_units(pckma[12:24], km)
cod1 <- emis_det(po = "CO", cc = 1000, eu = "III", km = kma)
cod2 <- emis_det(po = "CO", cc = 1000, eu = "I", km = kmb)
co1 <- fe2015[fe2015$Pollutant=="CO", ]
cod <- c(co1$PC_G[1:24] * c(cod1,cod2),
         co1$PC_G[25:nrow(co1)])

# 8 ####
fe2015 <- ef_cetesb(p = c("CO"), veh = "PC_G", full = T, agemax = 36)
names(fe2015)[ncol(fe2015)] <- "PC_G"
names(fe2015)[5] <- "Euro_LDV"
data(fkm)
pckm <- fkm[[1]](1:24); pckma <- cumsum(pckm)
cod1 <- emis_det(po = "CO", cc = 1000, eu = "III", km = kma)
cod2 <- emis_det(po = "CO", cc = 1000, eu = "I", km = kmb)
#vehicles newer than pre-euro
co1 <- fe2015[fe2015$Pollutant == "CO", ] #24 obs!!!
cod <- c(co1$PC_G[1:24] * c(cod1, cod2), co1$PC_G[25:nrow(co1)])
lef <- ef_ldv_scaled(dfcol = cod, v = "PC", cc = "<=1400",
                     f = "G",p = "CO", eu=co1$Euro_LDV)
# lef <- c(lef,lef[length(lef)],lef[length(lef)],lef[length(lef)],
#          lef[length(lef)],lef[length(lef)])

# 9 ####
data("profiles")
pc_profile <- profiles$PC_JUNE_2012
data(net) ; net <- as_Spatial(net)
E_CO <- emis(veh = pc1,lkm = net$lkm, ef = lef, speed = speed, profile = pc_profile)
E_CO_DF <- emis_post(arra = E_CO, veh = "PC", size = "1400", fuel = "Gasoline",
                     pollutant = "CO", by = "veh")
head(E_CO_DF) # take care of units
df <- aggregate(E_CO_DF$g, by=list(E_CO_DF$hour), sum)

df$Day <- c(
  rep("Monday", 24),
      rep("Tuesday", 24),
           rep("Wednesday", 24),
           rep("Thursday", 24),
           rep("Friday", 24),
           rep("Saturday", 24),
               rep("Sunday", 24))
names(df) <- c("Hour", "g_CO", "Day" )
df$day <- factor(df$Day,
                 levels =  c("Monday", "Tuesday", "Wednesday", "Thursday",
                             "Friday", "Saturday", "Sunday"))

ggplot(df, aes(x=Hour, y=unclass(g_CO), colour = day)) +
  geom_line() + geom_point(size = 4) + theme_bw() +
  theme(legend.key.size = unit(0.6,"cm")) +
  labs(x="Hour", y=expression(g%.%h^-1))

df3 <- aggregate(unclass(E_CO_DF$g), by=list(E_CO_DF$age), sum)
names(df3) <- c("Age", "t_CO")
df3$CO <- df3$t_CO*52/1000000

ggplot(df3, aes(x=Age, y=CO, fill=unclass(CO))) + geom_bar(stat='identity') +
  scale_fill_continuous(low="pink", high="black") + theme_bw() + geom_line(size=0.3) +
  theme(legend.key.size=unit(0.8,"cm")) + labs(x="Age", y=expression(t%.%y^-1))

# 10 ####
sldv <- colSums(pc1)
sum(sldv[20:36])
sum(sldv[20:36]) / sum(sldv)
sum(sldv)
df3 <- aggregate(unclass(E_CO_DF$g), by=list(E_CO_DF$age), sum)
names(df3) <- c("age", "t_CO")
head(df3)
df3$t_CO <- df3$t_CO*52/1000000
sum(df3$t_CO)
sum(df3[20:36,]$t_CO)/ sum(df3$t_CO)

dfco <- data.frame(co = c(co1$PC_G, rep(co1$PC_G[length(co1$PC_G)],5),
                          c(cod,rep(cod[length(cod)],5))),
                   EF = c(rep("0 km", 41),rep("Deteriorated", 41)),
                   Age = rep(1:41,2))

ggplot(dfco, aes(x = Age, y = co, colour = EF, shape = EF)) +
  geom_point(size = 4)  +
  geom_line()+theme_bw() + labs(x="Age", y="CO (g/km)") +
  theme(legend.position = c(0.2,0.8)) +
  guides(colour = guide_legend(keywidth = 2, keyheight = 2))+
  scale_color_discrete(name = "EF")

# 11 ####
E_CO_STREETS_n <- emis_post(arra = E_CO, pollutant = "CO",
                            by = "streets_narrow")
E_CO_STREETS <- emis_post(arra = E_CO, pollutant = "CO",
                          by = "streets_wide")
data(net) ; net <- as_Spatial(net)
# spplot does not plot 'units' therefore, columns needs to be converted to
#numeric
for (i in 1:ncol(E_CO_STREETS)) {
  E_CO_STREETS[,i] <- as.numeric(E_CO_STREETS[,i])
}
net@data <- cbind(net@data, E_CO_STREETS)
g <- make_grid(net, 1/102.47/2, 1/102.47/2)
gg <- as(g, "Spatial")
spplot(net, "V138", scales=list(Draw=T), cuts = 15,
       colorkey = list(space = "bottom", height = 1),
       col.regions = rev(bpy.colors(16)),
       sp.layout = list("sp.polygons", gg, pch = 13, cex = 2))


net@data <- net@data[,- c(1:9)]
net <- st_as_sf(net)
E_CO_g <- emis_grid(spobj = net, g = g, sr = 31983, type = "lines")
E_CO_g <- remove_units(E_CO_g)
E_CO_g <- as_Spatial(E_CO_g)
spplot(E_CO_g, "V138", scales=list(Draw=T),cuts=8,
       colorkey = list(space = "bottom", height = 1),
       col.regions = rev(bpy.colors(9)),
       sp.layout = list("sp.lines", net, pch = 16, cex = 2, col = "black"))
# 12 ####
E_CO_g$id <- NULL
E_CO_g <- st_as_sf(E_CO_g)
ldf <- list("co" = E_CO_g)
df_wrf <- eixport::to_as4wrf(ldf,nr=1,dmyhm = "04-08-2014 00:00",
                   tz = "America/Sao_Paulo", islist=T)


