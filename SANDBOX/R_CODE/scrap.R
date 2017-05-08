setup_cmds <- '
mkdir flight-analytics/data
cd flight-analytics/data

wget https://ibis-resources.s3.amazonaws.com/data/airlines/airlines_parquet.tar.gz
tar xvzf airlines_parquet.tar.gz
hadoop fs -mkdir /tmp/airlines/
hadoop fs -put airlines_parquet/* /tmp/airlines/

wget http://stat-computing.org/dataexpo/2009/airports.csv
hadoop fs -mkdir /tmp/airports
hadoop fs -put airports.csv /tmp/airports/

hadoop fs -chmod 777 /tmp/airlines /tmp/airports

rm -rf flight-analytics/data
'

runCommand <- function(cmd_txt, ...) {
  tryCatch(system(cmd_txt, ...), 
    error = function(c) {
    c$message <- paste0("ERROR: ", cmd_txt, c$message)
    stop(c)
  })
}

runCommand(setup_cmds)
runCommand("pwd")