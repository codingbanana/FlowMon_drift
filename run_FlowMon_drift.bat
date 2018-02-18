@ ECHO OFF
pushd %~dp0
:while
set /p qtrYr="Enter qtrYr (e.g.,Q3-17):"

echo %qtrYr%|findstr "Q[1-4]-[0-9][0-9]">nul 2>&1
if not %errorlevel%==0 goto while

Rscript -e "rmarkdown::render('FlowMon_drift.Rmd',output_dir='reports',output_file='FlowMon_drift_%qtrYr%.html',params=list(qtrYr='%qtrYr%'))"

start chrome %~dp0reports\FlowMon_drift_%qtrYr%.html

