# Read files into global memory
countries_dMort <-read.csv("csvData/GISS_Run3_2000.csv")
countries_mmm <-read.csv("csvData/MMMresults.csv")
initialmort <- read.csv("csvData/InitialMort.csv")
initialO3 <- read.csv("csvData/InitialO3.csv")
afFormat <-read.csv("csvData/AFFormatted.csv")
allagePop <-read.csv("csvData/AllAgePopulation.csv")
surfaceTemp <-read.csv("csvData/Country_Level_Temp_Change_MMM_1StandardErrors_50%_ValidDataEachCountry.csv")
nationalVSL <-read.csv("csvData/VSL2018USD.csv")
asthmaERV <-read.csv("csvData/AsthmaEV4Mar2020.csv")

shinyServer(function(input, output){

cat("\nEXECUTION ", format(Sys.time(), "%a %b %d %X %Y"), "\n", file=stderr())
#cat("\n\nAAAAAAAAAAAAAAAAAAAA\n\n", file=stderr())
  #Environment variablesmor 
  EpiHR = 1.12
  EpiTMREL = 26.3
  EpiBeta = .01133
  
  #text render
  n = renderText({input$obs})
  dataSetMMM <-reactive({switch(input$countries_dMort)})
  output$caption <- renderText({
    input$obs
  })
  df<-data.frame(countries_mmm["Country"],countries_mmm["ANN_MDA8Sim2.Sim1.Diff."])
  dfO3 <-data.frame(initialO3["Country"],initialO3["MMM.Initial.O3..ppb."])
  #Ozone Delta Map

  output$ozoneCountry_2040 <- renderggiraph({
    world <- map_data("world")
    ozoneDF<-setNames(data.frame(df[1],df[2]*-1*input$obs*(1/134)),c("Country","OzoneReduction"))
    map.world_joined <- left_join(world, ozoneDF, by = c('region' = 'Country'))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
    gg<-ggplot() + geom_polygon_interactive(data = map.world_joined, 
                                            aes(x = long, y = lat, group = group, fill = OzoneReduction, tooltip
=sprintf("%s<br/>%s",region,OzoneReduction)))
    gg<-gg+ scale_fill_gradient(low = "grey95", high = "tomato")
    gg<-gg+ coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    gg<-gg+theme_map()
    ggiraph(code = print(gg), width_svg=10)
  })

  #Delta Surface Temperature Map

  dfSAT <- data.frame(surfaceTemp["Country"],surfaceTemp["NationalAverageC"])
  output$dSAT_2040 <-renderggiraph({
    world <- map_data("world")
    satDF<-setNames(data.frame(df[1],dfSAT[2]*input$obs*(1/134)),c("Country","AvoidedWarming"))
    map.world_joined <- left_join(world, satDF, by = c('region' = 'Country'))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
    gg<-ggplot() + geom_polygon_interactive(data = map.world_joined, 
                                            aes(x = long, y = lat, group = group, fill = AvoidedWarming, tooltip
=sprintf("%s<br/>%s",region,AvoidedWarming)))
     gg<-gg+ scale_fill_gradient(low = "grey95", high = "tomato")
    gg<-gg+ coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    gg<-gg+theme_map()
    ggiraph(code = print(gg), width_svg=10)
  })

  #Delta Asthma-related ER visits Map

  dfAsthmaER <- data.frame(asthmaERV["Country"],asthmaERV["CasesMEANper10Mt"],asthmaERV["CostsMEAN2018USDperkt"])
  output$ozoneAsthmaER_2040 <-renderggiraph({
    world <- map_data("world")
    asthmaDF<-setNames(data.frame(df[1], dfAsthmaER[2]*input$obs*(17/134)),c("Country","AvoidedVisits"))
    # data is outdated and assumed 170 Mt methane between sims 1 and 2, really 134, so adjustment here * 170/134 (plus 1/10)
    map.world_joined <- left_join(world, asthmaDF, by = c('region' = 'Country'))
    # using width="auto" and height="auto" to automatically adjust the map size
    gg<-ggplot() + geom_polygon_interactive(data = map.world_joined, 
                                            aes(x = long, y = lat, group = group, fill = AvoidedVisits, tooltip
=sprintf("%s<br/>%s",region, AvoidedVisits)))
    gg<-gg+ scale_fill_gradient(low = "grey95", high = "tomato")
    gg<-gg+ coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    gg<-gg+theme_map()
    ggiraph(code = print(gg), width_svg=10)
  })

  #Delta Costs Asthma-related ER visits Map

  #dfAsthmaER <- data.frame(asthmaERV["Country"],asthmaERV["CasesMEANper10Mt"],asthmaERV["CostsMEAN2018USDperkt"])
  output$ozoneAsthmaERCost_2040 <-renderggiraph({
    world <- map_data("world")
    asthmaDFcost<-setNames(data.frame(df[1], dfAsthmaER[3]*input$obs*(1700/1.34)),c("Country","AvoidedCosts"))
    map.world_joined <- left_join(world, asthmaDFcost, by = c('region' = 'Country'))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
    gg<-ggplot() + geom_polygon_interactive(data = map.world_joined, 
                                            aes(x = long, y = lat, group = group, fill = AvoidedCosts, tooltip
=sprintf("%s<br/>%s",region, AvoidedCosts)))
     gg<-gg+ scale_fill_gradient(low = "grey95", high = "tomato")
    gg<-gg+ coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    gg<-gg+theme_map()
    ggiraph(code = print(gg), width_svg=10)
  })

  #Delta Total Mortality Map
  
  dfAF <- data.frame(afFormat["TotalOAF"],afFormat["InitialMort"])
  #avoided deaths
  output$dMortCountry_2040 <-renderggiraph({    
    #below sets up the two columns of the truth statement for Mean AF
    meanAF<-data.frame((data.frame((df[2]*input$obs*(1/134))-EpiTMREL)+dfO3[2]))
    tempExpFrame<-data.frame(1-exp((data.frame((df[2]*input$obs*(1/134))-EpiTMREL)+dfO3[2])*-1*EpiBeta))
    #below is the Mean AF
    meanAF[2] <- ifelse(meanAF[1]<0,0,tempExpFrame[1])
    deathCol<-ceiling(-1*data.frame(meanAF[2])*dfAF[1]+dfAF[2])
    deathFram <- data.frame(df[1],deathCol)
    dfDeaths <- setNames(deathFram,c("Country","AvoidedDeaths"))
    
    #plot everything below
    world <- map_data("world")
    map.world_joined <- left_join(world, dfDeaths, by = c('region' = 'Country'))
    gg<-ggplot() + geom_polygon_interactive(data = map.world_joined, 
                                            aes(x = long, y = lat, group = group, fill = AvoidedDeaths, tooltip=
sprintf("%s<br/>%s",region,AvoidedDeaths)))
     gg<-gg+ scale_fill_gradient(low = "grey95", high = "tomato")
    gg<-gg+ coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    gg<-gg+theme_map() 
    ggiraph(code = print(gg), width_svg=10)
  })

  #Delta Per Capita Mortality Map
  
  dfPOP <- data.frame(allagePop["Country"],allagePop["Population"])
  output$dMortCountry_capita_2040 <-renderggiraph({
    
    #below sets up the two columns of the truth statement for Mean AF
    meanAF<-data.frame((data.frame((df[2]*input$obs*(1/134))-EpiTMREL)+dfO3[2]))
    tempExpFrame<-data.frame(1-exp((data.frame((df[2]*input$obs*(1/134))-EpiTMREL)+dfO3[2])*-1*EpiBeta))
    #below is the Mean AF
    meanAF[2] <- ifelse(meanAF[1]<0,0,tempExpFrame[1])
    deathCol<-ceiling((-1*data.frame(meanAF[2])*dfAF[1]+dfAF[2])/(dfPOP[2]/1000000))
    deathFram <- data.frame(df[1],deathCol)
    dfDeaths <- setNames(deathFram,c("Country","AvoidedDeaths"))
    
    #plot everything below
    world <- map_data("world")
    map.world_joined <- left_join(world, dfDeaths, by = c('region' = 'Country'))
    gg<-ggplot() + geom_polygon_interactive(data = map.world_joined, 
                                            aes(x = long, y = lat, group = group, fill = AvoidedDeaths, tooltip=
sprintf("%s<br/>%s",region,AvoidedDeaths)))
     gg<-gg+ scale_fill_gradient(low = "grey95", high = "tomato")
    gg<-gg+ coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    gg<-gg+theme_map() 
    ggiraph(code = print(gg), width_svg=10)
  })

  #Delta Valuation of Reduced Mortality Map
  
  dfVSL <- data.frame(nationalVSL["Country"],nationalVSL["VSLmillionsUSD2018"])
  output$dMortCountry_VSL_2040 <-renderggiraph({
    
    #below sets up the two columns of the truth statement for Mean AF
    meanAF<-data.frame((data.frame((df[2]*input$obs*(1/134))-EpiTMREL)+dfO3[2]))
    tempExpFrame<-data.frame(1-exp((data.frame((df[2]*input$obs*(1/134))-EpiTMREL)+dfO3[2])*-1*EpiBeta))
    #below is the Mean AF
    meanAF[2] <- ifelse(meanAF[1]<0,0,tempExpFrame[1])
    deathCol<-ceiling((-1*data.frame(meanAF[2])*dfAF[1]+dfAF[2])*dfVSL[2])
    deathFram <- data.frame(df[1],deathCol)
    dfDeaths <- setNames(deathFram,c("Country","MillionsUSD"))
    
    #plot everything below
    world <- map_data("world")
    map.world_joined <- left_join(world, dfDeaths, by = c('region' = 'Country'))
    gg<-ggplot() + geom_polygon_interactive(data = map.world_joined, 
                                            aes(x = long, y = lat, group = group, fill = MillionsUSD, tooltip=
sprintf("%s<br/>%s",region,MillionsUSD)))
     gg<-gg+ scale_fill_gradient(low = "grey95", high = "tomato")
    gg<-gg+ coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    gg<-gg+theme_map() 
    ggiraph(code = print(gg), width_svg=10)
  })
})
#geom_sf will work for netcdf files likely.



