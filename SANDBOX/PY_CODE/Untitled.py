for name, value in os.environ.items():
  if name == "SPARK_DIST_CLASSPATH":
    pass
  else:
    print "%s\t= %s <br/>" % (name, value)

