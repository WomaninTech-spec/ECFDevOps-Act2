from fastapi import FastAPI
from pyspark.sql import SparkSession

app = FastAPI()

@app.get("/")
spark = SparkSession.builder \
 .master("local") \
 .appName("Word Count") \
 .config("spark.some.config.option", "some-value") \
 .getOrCreate()
    from datetime import datetime
    from pyspark.sql import Row
    spark = SparkSession(sc)
allTypes = sc.parallelize([Row(i=1, s="string", d=1.0, l=1,
b=True, list=[1, 2, 3], dict={"s": 0}, row=Row(a=1),
time=datetime(2014, 8, 1, 14, 1, 5))])
    df = allTypes.toDF()
    df.createOrReplaceTempView("allTypes")
    spark.sql('select i+1, d+1, not b, list[1], dict["s"], time, row.a '
            'from allTypes where b and i > 0').collect()
[Row((i + 1)=2, (d + 1)=2.0, (NOT b)=False, list[1]=2,         dict[s]=0, time=datetime.datetime(2014, 8, 1, 14, 1, 5), a=1)]
    df.rdd.map(lambda x: (x.i, x.s, x.d, x.l, x.b, x.time, x.row.a, x.list)).collect()
[(1, 'string', 1.0, 1, True, datetime.datetime(2014, 8, 1, 14, 1, 5), 1, [1, 2, 3])]




if __name__ == "__main__":
    # Créer une session Spark
    spark = SparkSession.builder \
        .appName("HelloWorld") \
        .getOrCreate()

    # Afficher Hello World
    print("Hello World from PySpark!")

    # Arrêter la session Spark
    spark.stop()
