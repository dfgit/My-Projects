## NLP example: Wordcloud of "alice in wonder land"
# Basic code is taken from https://github.com/amueller/word_cloud/blob/master/examples/masked.py

##
#
# get supporting files
#
# example includes python package wget and os command
# !pip install wget

##
# Imports

# utility
from os import path
import subprocess
import wget

# spark processing 
from pyspark.sql import SparkSession

# wordcloud and image processing
from wordcloud import WordCloud, STOPWORDS
import PIL
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

##
#
# Globals
#
HDFS_ALICE_DIRECTORY = '/tmp/alice'
LOCAL_ALICE_DIRECTORY = '/tmp'

#%%capture
#from IPython.display import set_matplotlib_formats
#set_matplotlib_formats('retina')
%matplotlib inline
%config InlineBackend.figure_format = 'retina'

def run_cmd(args_list):
    print('Running system command: {0}'.format(' '.join(args_list)))
    proc = subprocess.Popen(args_list, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    (output, errors) = proc.communicate()
    if proc.returncode:
        raise RuntimeError(
            'Error running command: %s. Return code: %d, Error: %s' % (
                ' '.join(args_list), proc.returncode, errors))
    return (output, errors)
  

# uncomment if you don't have image files local
# Download from http://www.umich.edu/~umfandsf/other/ebooks/alice30.txt
wget_url = 'http://www.umich.edu/~umfandsf/other/ebooks/alice30.txt'
wget.download(wget_url, out='/tmp')

# put alice.txt to HDFS
(out, errors)= run_cmd(['hdfs', 'dfs', '-mkdir', '-p', HDFS_ALICE_DIRECTORY])

(out, errors)= run_cmd(['hdfs', 'dfs', '-put', '-f', '/tmp/alice30.txt', HDFS_ALICE_DIRECTORY])

# uncomment if you don't have image files local
# run os commands function (could use bang or from wget above)
#(out, errors) = run_cmd(['wget', \
#                         '--local-encoding=UTF-8', \
#                         'http://www.stencilry.org/stencils/movies/alice%20in%20wonderland/255fk.jpg?p=*full-image', \
#                         '-O', \
#                         '/home/cdsw/SANDBOX/PY_CODE/resources/alice-mask.jpg'])

# begin processing
spark = SparkSession.builder \
      .appName("Word count") \
      .getOrCreate()
    
threshold = 5

text_file = spark.sparkContext.textFile(path.join(HDFS_ALICE_DIRECTORY, "alice30.txt"))

# create word cloud 
stopwords = set(STOPWORDS)
stopwords.add("and")

counts = text_file.flatMap(lambda line: line.lower().split(" ")) \
             .filter(lambda word: word not in stopwords) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)

from pyspark.sql.types import *
schema = StructType([StructField("word", StringType(), True),
                     StructField("frequency", IntegerType(), True)])

filtered = counts.filter(lambda pair: pair[1] >= threshold)
counts_df = spark.createDataFrame(filtered, schema)

frequencies = counts_df.toPandas().set_index('word').T.to_dict('records')

# 
img = Image.open(path.join("/home/cdsw/SANDBOX/PY_CODE/resources", "alice-mask.jpg"))
print("%s", )
alice_mask = np.array(img)

wc = WordCloud(background_color="white", max_words=2000, mask=alice_mask,
               stopwords=stopwords)
wc.generate_from_frequencies(dict(*frequencies))

plt.imshow(wc, interpolation='bilinear')

# HDFS cleanup
# !hdfs dfs -rm -r $HDFS_ALICE_DIRECTORY
# (out, errors)= run_cmd(['hdfs', 'dfs', '-rm', '-r',  HDFS_ALICE_DIRECTORY])
# close spark session
spark.stop()
