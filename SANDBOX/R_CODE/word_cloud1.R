# generic package load / install
installLoadPkgs <- function(pkgList)
{
  print(pkgList)
  pkgsToLoad <- pkgList[!(pkgList %in% installed.packages()[,"Package"])];

  if(length(pkgsToLoad)) {
    install.packages(pkgsToLoad, dependencies = TRUE);
  }
  
  for(package_name in pkgList) {
    library(package_name, character.only=TRUE, quietly=FALSE);
  }
}

pkgs <- c("wordcloud2")
installLoadPkgs(pkgs)
library(sparklyr)
library(dplyr)

config <- spark_config()
config$spark.driver.cores   <- 2
config$spark.executor.cores <- 4
config$spark.executor.memory <- "4G"

# <- "/opt/cloudera/parcels/SPARK2/lib/spark2"
spark_version <- "2.1.0"
sc <- spark_connect(master="yarn-client", version=spark_version, config=config)

count_lines <- function(sc, path) {
  spark_context(sc) %>% 
    invoke("textFile", path, 1L) %>% 
      invoke("count")
}

counts <- count_lines(sc, "hdfs:///tmp/alice/alice30.txt") 
#counts = text_file.flatMap(lambda line: line.lower().split(" ")) \
#             .filter(lambda word: word not in stopwords) \
#             .map(lambda word: (word, 1)) \
#             .reduceByKey(lambda a, b: a + b)

#
#x <- f.flatMap(line => line.split(" "))
#               .map(word => (word, 1))
#               .reduceByKey(_ + _)

counts <- function(sc, f) {
  spark_context(sc) %>% 
      invoke("flatMap", f) %>%
      invoke("filter", "(line => line.contains('Alice'))")
}

getFile <- function(sc, path) {
    spark_context(sc) %>% 
      invoke("textFile", path, 1L) 
  
}


f <- getFile(sc, "hdfs:///tmp/alice/alice30.txt")
fc <- counts(sc, f)

getFileCollect <- function(sc, path) {
    spark_context(sc) %>% 
      invoke("textFile", path, 1L) %>%
        invoke("collect")
  
}

splitLines <- function(sc,path) {
    spark_context(sc) %>% 
      invoke("textFile", path, 1L) %>%  
        invoke_method(".flatMap(line => line.split(' ') ).map(word => (word, 1)).reduceByKey(_ + _)") 
}

x <- splitLines(sc, "hdfs:///tmp/alice/alice30.txt")

df = spark_read_csv(sc, path = "hdfs:///tmp/alice/alice30.txt", name = "alice", delimiter = " ", header = "false", infer_schema = "false")
#count_lines(sc, "hdfs:///tmp/alice/alice30.txt")


#ft <- mtcars %>% group_by(gear) %>% summarise(freq=n())

# get the right version of sparklyr until sparklyr supports Spark 2.1 
# wordcloud2(demoFreq, size=.7, shape='star')

wordcloud2(demoFreq, figPath = "alice-mask.png")

 
