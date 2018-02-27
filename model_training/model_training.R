if (!grepl("model_training", getwd())) setwd('model_training')
library(tidyverse)
library(lubridate)
library(RPostgreSQL)
library(BreakoutDetection)
library(zoo)

######## input ##########
site='IALL-0008'
qtrYr='Q3-17'
type='velocity'
min.size.default=120
degree.default=1
beta.default=0.007
percent.default=NULL
#########################

# data downloader
dl.data <- function(site, qtrYr, type) {
    drv <- dbDriver('PostgreSQL')
    con <- dbConnect(
        drv,
        dbname = 'CentralDB',
        host = '170.115.81.37',
        user = 'flowmon_drift',
        password = 'water.123',
        port = 5432
    )

    if(type=='level') {
        query <- paste0(
            'SELECT d."DateTime" AS timestamp, d."Level_1" AS count ',
            'FROM flow.data d LEFT JOIN flow.inventory i ON d.id=i.id ',
            'WHERE i."qtrYr" =\'', qtrYr,'\' AND i."MANHOLE_ID"=\'', site,"\' ",
            'ORDER BY i."MANHOLE_ID", d."DateTime"'
        )
    } else {
        query <- paste0(
            'SELECT d."DateTime" AS timestamp, d."Vel_1" AS count ',
            'FROM flow.data d LEFT JOIN flow.inventory i ON d.id=i.id ',
            'WHERE i."qtrYr" =\'', qtrYr,'\' AND i."MANHOLE_ID"=\'', site,"\' ",
            'ORDER BY i."MANHOLE_ID", d."DateTime"'
        )
    }

    d <- dbGetQuery(con, query)
    o <- dbDisconnect(con)
    return(d)
}

# hourly data (sampled, not averaged)
d <- dl.data(site, qtrYr, type) %>%
    filter(minute(timestamp)==0)

# set up plots ----------------------
png(filename = paste0(site,"_", qtrYr,"_", type,
                      "_minsize.", min.size.default,
                      "_degree.", degree.default,
                      "_beta.", beta.default,
                      "_percent.", percent.default, ".png"),
    width = 960, height = 960, units = "px", res=144)
par(mfrow=c(3,2))
par(mar=c(4,4,1,1) + 0.1)
par(cex.lab=1.5, cex.axis=1.5)

# 1. test min.size --------------------
n.fn <- function(data, n) {
    ans <- breakout(
        data,
        min.size = n,
        method = 'multi',
        degree=degree.default,
        beta=beta.default,
        percent=percent.default,
        plot=F)
    length(ans$loc)
}

min.size <- seq(2, 242, 24)
plot(data.frame(min.size,
                breakouts=sapply(min.size, function(p) n.fn(data=d, n=p))),
     type='b')
title(xlab="min.size", ylab="breakouts")

# 2. test degree --------------
degree.fn <- function(data, degree) {
    ans <- breakout(
        data,
        min.size = min.size.default,
        method = 'multi',
        degree=degree,
        beta=beta.default,
        percent=percent.default,
        plot=F)
    length(ans$loc)
}

degree <- 0:2
plot(data.frame(degree,
                breakouts=sapply(degree, function(p) degree.fn(data=d, degree=p))),
     type='b')
title(xlab="degree", ylab="breakouts")

# 3. test beta ------------
beta.fn <- function(data, beta) {
    ans <- breakout(
        data,
        min.size = min.size.default,
        method = 'multi',
        degree=degree.default,
        beta=beta,
        percent=percent.default,
        plot=F)
    length(ans$loc)
}

beta <- exp(1:10)*0.00001
plot(data.frame(beta,
                breakouts=sapply(beta, function(p) beta.fn(data=d, beta=p))),
     type='b', log='x')
title(xlab="beta", ylab="breakouts")

# 4. test percent -----------------
percent.fn <- function(data, percent) {
    ans <- breakout(
        data,
        min.size = min.size.default,
        method = 'multi',
        degree= degree.default,
        # beta= beta.default,
        percent= percent,
        plot=F)
    length(ans$loc)
}

percent <- seq(0,1,0.2)
plot(data.frame(percent,
                breakouts=sapply(percent, function(p) percent.fn(data=d, percent=p))),
     type='b')
title(xlab="percent", ylab="breakouts")

# 5. test rolling median window ----------------
agg.fn <- function(data, window) {
    d <- rollmedian(x = zoo(order.by = data$timestamp,
                            x = data$count),
                    k = window)

    d <- data.frame(timestamp=index(d),
                    count=coredata(d))
    ans <- d %>%
        breakout(
            min.size = min.size.default,
            method = 'multi',
            degree= degree.default,
            beta= beta.default,
            percent= percent.default,
            plot=F)
    length(ans$loc)
}

agg <- seq(1, 101, 12)
plot(data.frame(smoother=agg,
                breakouts=sapply(agg, function(p) agg.fn(data=d, window=p))),
     type='b')
title(xlab="smoother", ylab="breakouts")

# 6. time-series
loc <- breakout(
    d,
    min.size = min.size.default,
    method = 'multi',
    degree= degree.default,
    beta= beta.default,
    percent= percent.default, # no used when beta is given
    plot=F)$loc

plot(d, type='l')
abline(v=d[loc,"timestamp"], col='red', lty=2)

dev.off()
