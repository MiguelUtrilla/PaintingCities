#########################################
# Script. PintarCiudades.R
# Author: MUB
# Date: 4/4/2020
#Descrition: Painting Madrid
####################################################

#use https://boundingbox.klokantech.com/ for further precision of the bounding box of the map (frame)


#limpio entorno
rm(list = ls())
cat("\14")

#listo los paquetes de trabajo, y si no están los instalo
print("Installed packages: ")
lsPackages <- c("tidyverse", "osmdata", "ggsave", "here")

for (strPackage in lsPackages) {
  print(strPackage)
  if (!(strPackage %in% rownames(installed.packages()))) {
    install.packages(strPackage)}
}


#cargo los paquetes
lapply(lsPackages, require, character.only = TRUE)

#limpio la cadena de paquetes para que no moleste como variable
rm(strPackage)
rm(lsPackages)

#guardo el puntero al entorno de trabajo
here()


#selector colores
hxColorCallesGrandes <- "#7fc0ff"
hxColorCallesPequeñas <- "#ffbe7f"
hxColorRio <- "#ffbe7f"
hxColorMetro <- "#E85D42"
hxColorWater <- "#ffbe7f"
hxBackground <- "#282828" #ffffff


ListOfCities <-c("Zaragoza", "Jerez de La Frontera Cadiz")


for(city in ListOfCities) {
  TimestampInicio <- Sys.time()
  
strPoblacion <- city
strShortName <- strPoblacion

blPrecision <- FALSE


if(blPrecision){
  vLatitud <- c(36.653834,36.748676)
  vLongitud <- c(-6.171728, -6.051531)
  
}else{
    vLatitud <- c(getbb(strPoblacion)[2], getbb(strPoblacion)[4])
    vLongitud <- c(getbb(strPoblacion)[1], getbb(strPoblacion)[3])
}





#me guardo una lista como las calles
streets <- getbb(strPoblacion)%>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value = c("motorway", "primary", 
                            "secondary", "tertiary")) %>%
  osmdata_sf()

#ahora guardo las calles pequeñas
small_streets <- getbb(strPoblacion)%>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value = c("residential", "living_street",
                            "unclassified",
                            "service", "footway")) %>%
  osmdata_sf()

#ahora guardo el metro
subway <- getbb(strPoblacion)%>%
  opq()%>%
  add_osm_feature(key = "railway", 
                  value = c("subway")) %>%
  osmdata_sf()

#por último guardo el rio
river <- getbb(strPoblacion)%>%
  opq()%>%
  add_osm_feature(key = "waterway", value = "river") %>%
  osmdata_sf()

#por último guardo el agua
water <- getbb(strPoblacion)%>%
  opq()%>%
  add_osm_feature(key = "natural", 
                  value = c("coastline")) %>%
  osmdata_sf()





#ahora lo pinto añado las tres capas, acoto el mapa, y le pongo fondo
ggplot() +
  geom_sf(data = subway$osm_lines,
          inherit.aes = FALSE,
          color = eval(hxColorMetro),
          size = .4,
          alpha = .8)+
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color = eval(hxColorCallesGrandes),
          size = .4,
          alpha = .8) +
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = hxColorCallesPequeñas,
          size = .2,
          alpha = .6) +
  geom_sf(data = river$osm_lines,
          inherit.aes = FALSE,
          color = hxColorRio,
          size = .2,
          alpha = .5) +
  geom_sf(data = water$osm_lines,
          inherit.aes = FALSE,
          color = hxColorWater,
          size = .2,
          alpha = .5) +
  coord_sf(xlim = vLongitud ,
           ylim = vLatitud,
           expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = hxBackground)
  )
  
  strFileName <- paste(strShortName,
        Sys.time()%>%str_replace_all('[^0-9]', ''),
        ".jpeg",
        sep = "_")
  
  ggsave(strFileName, width = 6, height = 6)
  
  TimestampFin <- Sys.time()
  print(city)
  print(TimestampFin-TimestampInicio)
  
}



