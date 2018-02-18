library(tidyverse)
library(RPostgreSQL)
library(BreakoutDetection)

params <- list()
params$qtrYr <- 'Q2-16'

drv <- dbDriver('PostgreSQL')
con <- dbConnect(
    drv,
    dbname = 'CentralDB',
    host = '170.115.81.37',
    user = 'flowmon_drift',
    password = 'water.123',
    port = 5432
)

query <- paste0(
    'SELECT d."DateTime" AS dt, i."MANHOLE_ID" AS mhid, d."Level_1" AS lvl, d."Vel_1" AS vel ',
    'FROM flow.data d LEFT JOIN flow.inventory i ON d.id=i.id ',
    'WHERE i."qtrYr" =\'', params$qtrYr, "' ",
    'ORDER BY i."MANHOLE_ID", d."DateTime"'
)
d <- dbGetQuery(con, query)
o <- dbDisconnect(con)

lvl.hr <- d %>%
    filter(mhid==site & minute(dt)==0) %>%
    transmute(timestamp=dt,
              count=lvl)

lvl.breakouts <- breakout(
    lvl.hr,
    min.size = 240, # equals 10 days of data,
    # i.e., the shift must last more than 10 days
    method = 'multi',
    degree=1,      # default
    beta=0.008,    # default, but cannot be omitted
    percent=0.10,
    plot=F)
