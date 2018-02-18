library(knitr)

qtrYr <- 'Q1-17'

rmarkdown::render(input = 'FlowMon_drift.Rmd',
                  output_format = 'html_document',
                  output_dir = 'reports',
                  output_file = paste0('FlowMon_drift_',qtrYr,'.html'),
                  envir = new.env(),
                  params=list(qtrYr=qtrYr))

system(
    paste0('"c:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe" ',
           getwd(), '\\reports\\FlowMon_drift_', qtrYr, '.html')
)
