# Utilisez une image de base qui inclut Python
FROM python:3.8-slim

# Mettez à jour les paquets et installez les dépendances nécessaires
RUN apt-get update \
    && apt-get install -y openjdk-21.0.2-jdk \
    && apt-get clean

# Copiez les fichiers de votre application dans le conteneur
WORKDIR /app
COPY . /app

# Installez les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Commande pour exécuter votre application
CMD ["python", "votre_script.py"]
