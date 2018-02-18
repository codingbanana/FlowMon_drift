library(knitr)

qtrYrs <- paste0("Q", 1:4,"-" ,
                 rep(16:17, each=4))

for (qtrYr in qtrYrs)
    rmarkdown::render(input = 'FlowMon_drift.Rmd',
                      output_format = 'html_document',
                      output_dir = 'reports',
                      output_file = paste0('FlowMon_drift_',qtrYr,'.html'),
                      envir = new.env(),
                      params=list(qtrYr=qtrYr))
