suppressMessages(library(shiny))
suppressMessages(library(leaflet))
suppressMessages(library(dplyr))
suppressMessages(library(htmltools))
suppressMessages(library(sf))
suppressMessages(library(geojsonR))


#### Input data ####
trace <- st_read("www/data/trace.geojson")
heberg <- st_read("www/data/hebergements.geojson")
heberg_icon <- makeIcon("www/svg/accommodation_youth_hostel.svg", 30, 30)

#### Infobulles ####
trace$tooltip <- sprintf(
  "<strong>Trace : </strong>%s<br>
  <strong>Longueur : </strong>%s km<br>",
  trace$name, round(trace %>% st_length() / 1000, 1)
) %>% lapply(htmltools::HTML)
heberg$tooltip <- sprintf(
  "<h5>%s</h5>",
  heberg$nom
) %>% lapply(htmltools::HTML)

####  UI  ####
ui <- fluidPage(

  # Chargement du CSS
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/default.css")),

  # Création de la layout
  navbarPage("Rando 2024", id = "main",
    tabPanel("Entre Clarée et Écrins",
      div(class = "outer",
        leafletOutput(
          outputId = "mymap",
          height = "100%",
          width = "100%"
        )
      )
    )
  )
)


#### Server ####
server <- function(input, output, session) {

  ## La carto
  output$mymap <- renderLeaflet({
    leaflet() %>% 
    setView(lng = 6.47153, lat = 45.00168, zoom = 13) %>%
    
    addTiles(group="OSM") %>%
    addTiles("http://wxs.ign.fr/choisirgeoportail/wmts?REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&STYLE=normal&TILEMATRIXSET=PM&FORMAT=image/jpeg&LAYER=ORTHOIMAGERY.ORTHOPHOTOS&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}", options = WMSTileOptions(tileSize = 256),group = "Orthos") %>%      
    addTiles("http://wxs.ign.fr/cartes/wmts?REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&STYLE=normal&TILEMATRIXSET=PM&FORMAT=image/png&LAYER=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}",options = WMSTileOptions(tileSize = 256),group = "Plan IGN") %>%
    addTiles("https://a.tile.opentopomap.org/{z}/{x}/{y}.png", group = "OpenTopoMap") %>%
             
    addPolylines(
      data = trace,
      stroke = TRUE,
      dashArray =  "5",
      color = "red",
      group = "Trace",
      weight = 5,
      popup = trace$tooltip,
      label = trace$tooltip,
      highlightOptions = highlightOptions(
        color = "#b16694", 
        weight = 5,
        bringToFront = TRUE
      )
    ) %>%

    addMarkers(
      data = heberg,
      icon = heberg_icon,
      label = heberg$nom,
      group = "Gîtes"
    ) %>% 

    addMeasure(
      position = "topleft",
      primaryLengthUnit="kilometers", 
      primaryAreaUnit = "sqmeters",
      activeColor = "#3D535D",
      completedColor = "#7D4479"
    ) %>%

    addLayersControl(
      baseGroups = c("Plan IGN", "OpenTopoMap", "Orthos", "OSM"),
      overlayGroups = c("Trace"),
      position = "topright",
      options = layersControlOptions(collapsed = FALSE)
    )
  })
}

shinyApp(ui, server)