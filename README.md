# Flow Monitoring Drift Detection program

## Introduction

Sensor-monitored data may suffer from trend change due to sensor drifting, ragging, or pipe surcharging, etc. As a data QA measure, the water level and velocity in sewer pipes, and the trunk & SWO level at regulator outfalls are examined to detect potential change in trend. 

## Methodology

BreakoutDetection is an open-source R package that makes breakout detection simple and fast. The underlying algorithm – referred to as E-Divisive with Medians (EDM) – employs energy statistics to detect divergence in mean. Note that EDM can also be used detect change in distribution in a given time series. EDM uses [robust statistical metrics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-0470129905.html), viz., median, and estimates the statistical significance of a breakout through a permutation test. 

## How to use

The `FlowMon_drift.Rmd` is the core script. By taking `qtrYr` as the input, data in the specific quarter-year are queried from the `CentralDB` database, then analyzed for breakouts by functions from the `breakoutDetection` package. A table is generated that includes the detected breakouts, and time-series plots are generated for each monitored site with breakouts annotated. The output is a HTML report, including the breakouts table and plots. All reports are saved in the `/reports` subfolder.

There are two methods to generate a new report: 

1.  `run_FlowMon_drift.bat`: double-click to run the batch file, specify the `qtrYr` in the console, then wait until the process finished. The generated file will be opened in chrome.

2.  `create_report.R`: open the file, change the `qtrYr` to the desired quarter-year, then run/source the script.

    -  `create_report.R`: a variant for generating multiple reports through loops

