from pyspark.sql import SparkSession

if __name__ == "__main__":
    # Créer une session Spark
    spark = SparkSession.builder \
        .appName("HelloWorld") \
        .getOrCreate()

    # Afficher Hello World
    print("Hello World from PySpark!")

    # Arrêter la session Spark
    spark.stop()
