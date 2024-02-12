# Utilisez une image Python officielle en tant que base
FROM python:3.9-slim

# Définissez le répertoire de travail dans le conteneur
WORKDIR /app

# Copiez le fichier requirements.txt dans le conteneur
COPY requirements.txt .

# Installez les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiez le reste des fichiers de l'application dans le conteneur
COPY . .

# Commande par défaut pour exécuter votre application lorsque le conteneur démarre
CMD ["python3", "app.py"]

# Add Spark to PATH
ENV PATH $PATH:$SPARK_HOME/bin

# Install FastAPI, Uvicorn, PySpark, and any other dependencies
RUN pip install fastapi uvicorn pyspark==$APACHE_SPARK_VERSION

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container
COPY . .

#Add authorisation
RUN chmod +x app.py

# Expose the port FastAPI will run on
EXPOSE 4040

# Command to run the Uvicorn server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "4040"]