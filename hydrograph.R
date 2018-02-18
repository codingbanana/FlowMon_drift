library(ggplot2)
library(readr)
df <- read_csv("date, precip_in, discharge_cfs
               2000-01-01, 13.2, 150
               2000-01-02, 9.5, 135
               2000-01-03, 7.3, 58
               2000-01-04, 0.2, 38")

# input:
# data: the dataframe
# dtime: datetime column
# flow: flow column, in cfs
# rain: precipitation column, in inches
gg_hydrograph <- function(data=NULL, dtime, flow, rain, ratio=0.2) {

    # test case:
    # data=df
    # dtime='date'
    # rain='precip_in'
    # flow='discharge_cfs'
    # ratio=0.4

    if(!is.null(data)) {
        try({
            dtime=data[[dtime]]
            flow=data[[flow]]
            rain=data[[rain]]
        })

    }

    max_flow <- max(flow, na.rm = T)
    min_flow <- 0
    max_rain <- max(rain, na.rm = T)
    min_rain <- 0

    newMax <- (1.1+ratio)*max_flow
    scaleFactor <- (max_flow-min_flow)/(max_rain-min_rain)*ratio

    # Create a function to backtransform the axis labels for precipitation
    flow_breaks <- pretty(flow,n = 4)
    rain_breaks <- pretty(rain,n = 4)

    # Plot the data
    p <- ggplot() +
        # Plot your discharge data
        geom_line(aes(x = dtime, y = flow),
                  color = "darkgreen") +
        # geom_col(aes(y=rain*scaleFactor))+
        # Use geom_tile to create the inverted hyetograph. geom_tile has a bug that displays a warning message for height and width, you can ignore it.
        suppressWarnings(geom_tile(aes(
                     x = dtime,
                     y = newMax-rain*scaleFactor/2, # y = the center point of each bar
                     height = rain*scaleFactor),
                  width = 1,
                  fill = "darkred")) +
        # Create a second axis with sec_axis() and format the labels to display the original precipitation units.
        scale_y_continuous(name = "Discharge (cfs)             ", limits = c(min_flow, newMax),
                           breaks = flow_breaks, labels=flow_breaks, expand = c(0,0),
                           sec.axis = sec_axis(trans = ~(newMax-.)/scaleFactor,
                                               name = "Precip. (in)",
                                               breaks = rain_breaks, labels = rain_breaks))+
        theme_bw()+
        theme(axis.title.x=element_blank(),
              axis.title.y = element_text(angle=90, hjust=0.5),
              axis.title.y.right = element_text(angle=270, hjust=0))

    return(p)
}

# test case:
# gg_hydrograph(df,'date','discharge_cfs','precip_in')
gg_hydrograph(df,'date','discharge_cfs','precip_in',0.4)
# gg_hydrograph(dtime=df$date,flow = df$discharge_cfs,rain = df$precip_in)
