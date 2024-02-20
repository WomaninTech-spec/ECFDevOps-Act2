# Import required modules
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pyspark.sql import SparkSession
from datetime import datetime
from pyspark.sql import Row
import pytest

# Create FastAPI app
app = FastAPI()

# Initialize SparkSession
def get_spark_session():
    spark = SparkSession.builder \
        .master("local") \
        .appName("Test App") \
        .getOrCreate()
    return spark

# Define FastAPI route
@app.get("/")
async def root():
    spark = get_spark_session()  # Get SparkSession
    allTypes = spark.sparkContext.parallelize([
        Row(i=1, s="string", d=1.0, l=1, b=True, list=[1, 2, 3], dict={"s": 0}, row=Row(a=1), time=datetime(2014, 8, 1, 14, 1, 5))
    ])
    
    df = allTypes.toDF()
    df.createOrReplaceTempView("allTypes")
    
    result = spark.sql('SELECT i+1, d+1, NOT b, list[1], dict["s"], time, row.a FROM allTypes WHERE b AND i > 0').collect()
    spark.stop()  # Stop the SparkSession

    return {"result": str(result)}

# Test setup
client = TestClient(app)

# Pytest function to test the FastAPI route
def test_root_route():
    response = client.get("/")
    assert response.status_code == 200
    # Add more assertions based on your expected output
    assert "result" in response.json()

# If this script is run directly, only start the FastAPI app if we're not in test mode
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
