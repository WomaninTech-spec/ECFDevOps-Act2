from fastapi import FastAPI
from pyspark.sql import SparkSession
from datetime import datetime
from pyspark.sql import Row

app = FastAPI()

# Initialisation de SparkSession
spark = SparkSession.builder \
    .master("local") \
    .appName("Word Count") \
    .config("spark.some.config.option", "some-value") \
    .getOrCreate()

# Création d'une route avec FastAPI
@app.get("/")
async def root():
    allTypes = spark.sparkContext.parallelize([Row(i=1, s="string", d=1.0, l=1,
        b=True, list=[1, 2, 3], dict={"s": 0}, row=Row(a=1),
        time=datetime(2014, 8, 1, 14, 1, 5))])
    
    df = allTypes.toDF()
    df.createOrReplaceTempView("allTypes")
    
    result = spark.sql('select i+1, d+1, not b, list[1], dict["s"], time, row.a '
            'from allTypes where b and i > 0').collect()

    return {"result": result}

if __name__ == "__main__":
    # Pour exécuter localement
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
