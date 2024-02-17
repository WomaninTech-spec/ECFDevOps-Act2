# ECFDevOps-Act2 

### Activité type 2 : Déploiement d’une application en continu
## Table of Contents
1. [Introduction](#Introduction)
2. [Flask App](#Flask App)
3. [Construction Projet](#constructionprojet)
4. [Collaboration](#collaboration)
5. [FAQs](#faqs)



1. Créez une application Python (hello word) avec Pyspark intégré.
2. Dockerizez votre application Python.
3. Écrivez le script qui build/test le Python et déployez le dans un container de votre
choix => Utilisation de Dockerfile

---

# Table des matières

1. [Introduction](#introduction)
2. [Application Flask](#application-flask)
3. [Application FastAPI](#application-fastapi)
4. [Configuration de construction](#configuration-de-construction)
5. [Dockerfile](#dockerfile)
6. [Ci pipeline github ] (#cipipelinegithub)

---

## Introduction

Ce dépôt contient du code pour deux applications web développées en Python : une utilisant Flask et l'autre utilisant FastAPI. De plus, il comprend un Dockerfile et un fichier de configuration de construction pour AWS CodeBuild.

## Application Flask

```python
from flask import Flask

def create_app():
    app = Flask(__name__, static_folder="static")
    app.config.from_object("config")

    # Routage des pages web
    with app.app_context():
        # Ajoutez vos routes ici si nécessaire
        pass

    return app

if __name__ == "__main__":
    # Exécuter localement
    app = create_app()
    app.run(debug=True)
```

## Application FastAPI

```python
from fastapi import FastAPI
from pyspark.sql import SparkSession
from datetime import datetime
from pyspark.sql import Row

app = FastAPI()

# Initialiser SparkSession
spark = SparkSession.builder \
    .master("local") \
    .appName("Word Count") \
    .config("spark.some.config.option", "some-value") \
    .getOrCreate()

# Créer une route avec FastAPI
@app.get("/")
async def root():
    # Création du DataFrame Spark
    allTypes = spark.sparkContext.parallelize([Row(i=1, s="string", d=1.0, l=1,
        b=True, list=[1, 2, 3], dict={"s": 0}, row=Row(a=1),
        time=datetime(2014, 8, 1, 14, 1, 5))])
    
    df = allTypes.toDF()
    df.createOrReplaceTempView("allTypes")
    
    # Requête SQL
    result = spark.sql('select i+1, d+1, not b, list[1], dict["s"], time, row.a '
            'from allTypes where b and i > 0').collect()

    return {"result": result}
```

## Configuration de construction (`buildspec.yaml`)

```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Connexion à Amazon ECR...
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
      - REPOSITORY_URI=040336645459.dkr.ecr.eu-central-1.amazonaws.com/pysparkdockeract2
      - IMAGE_TAG=latest

  build:
    commands:
      - echo Construction démarrée le `date`
      - echo Construction de l'image Docker...
      - docker build -t $REPOSITORY_URI:$IMAGE_TAG .
```

## Dockerfile

```Dockerfile
# Utiliser une image de base qui inclut Python
FROM python:3.8-slim

# Définir JAVA_HOME sur le bon chemin
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64

# Mettre à jour les paquets et installer les dépendances nécessaires
RUN apt-get update \
    && apt-get install -y openjdk-17-jdk \
    && apt-get clean

# Copier les fichiers de votre application dans le conteneur
WORKDIR /app
COPY . /app

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Commande pour exécuter votre application
CMD ["python", "app.py"]
```

---

### Explication du code

- **Application Flask** :
  - Ce code initialise une application Flask avec quelques configurations de base et fournit une structure pour ajouter des routes.
- **Application FastAPI** :
  - Ici, une application FastAPI est créée avec une route racine. Elle initialise une SparkSession, effectue des opérations avec Spark DataFrame et retourne le résultat.
- **Configuration de construction (`buildspec.yaml`)** :
  - Ce fichier YAML définit le processus de construction pour AWS CodeBuild. Il inclut des commandes pour se connecter à Amazon ECR, configurer l'URI du référentiel et construire l'image Docker.
- **Dockerfile** :
  - Ce Dockerfile configure un conteneur Docker pour exécuter l'application Python. Il installe Java, copie les fichiers de l'application, installe les dépendances Python et spécifie la commande pour exécuter l'application.
 
  # Création et exécution d'une application Docker avec Visual Studio Code

Ce guide vous montrera comment créer une image Docker à partir d'une application Python dans Visual Studio Code, puis exécuter cette application dans un conteneur Docker.

## Créer une application Python

1. Ouvrez Visual Studio Code.
2. Créez un nouveau dossier pour votre application.
3. Dans VS Code, ouvrez le terminal et initialisez un environnement virtuel Python (optionnel mais recommandé).
4. Installez Flask (ou tout autre framework web Python) dans votre environnement virtuel.

```bash
pip install flask

*1 - Créez un fichier app.py contenant votre application Flask :
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

### Créer un fichier Dockerfile
À la racine de votre projet, créez un fichier nommé Dockerfile sans extension.
Ajoutez les instructions suivantes dans votre fichier Dockerfile pour créer une image Docker :

# Utilisez une image de base qui inclut Python
FROM python:3.8-slim

# Copiez les fichiers de votre application dans le conteneur
WORKDIR /app
COPY . .

# Installez les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Commande pour exécuter votre application
CMD ["python", "app.py"]

## Construire et exécuter l'image Docker

Assurez-vous que Docker est installé sur votre machine.
Ouvrez un terminal dans VS Code.
Naviguez vers le répertoire de votre projet.
Exécutez la commande suivante pour construire votre image Docker :

docker build -t mon_image .

Une fois la construction terminée, exécutez la commande suivante pour exécuter votre application dans un conteneur Docker :

docker run -p 5001:5000 mon_image

Accédez à votre application dans un navigateur Web en accédant à http://localhost:5001.
=> **C'est tout ! Vous avez maintenant une application Python exécutée dans un conteneur Docker.**


6. [Ci pipeline github ] (#cipipelinegithub)

---

# Table des matières de mes reflexions et test : choix final Test deploy sur **Github**

1. [Introduction à la mise en place d'un pipeline CI/CD sur AWS](#introduction-à-la-mise-en-place-dun-pipeline-cicd-sur-aws)
    - Définition du CI/CD
    - Utilisation des services AWS pour créer un pipeline
2. [Procédure générale pour la mise en place d'un pipeline CI/CD sur AWS](#procédure-générale-pour-la-mise-en-place-dun-pipeline-cicd-sur-aws)
    - Création d'un référentiel de code
    - Configuration d'AWS CodePipeline
    - Configuration d'AWS CodeBuild
    - Configuration d'AWS CodeDeploy (si nécessaire)
    - Intégration avec d'autres services AWS
    - Test et validation du pipeline
    - Maintenance et amélioration
    - Documentation
3. [Comparaison de la mise en place d'un pipeline CI/CD sur Jenkins](#comparaison-de-la-mise-en-place-dun-pipeline-cicd-sur-jenkins)
    - Installation et configuration initiales
    - Configuration du pipeline
    - Intégrations et plugins
    - Maintenance et évolutivité
4. [CI avec GitHub](#ci-avec-github)
    - Utilisation de GitHub comme référentiel de code
    - Configuration de GitHub Actions pour le CI/CD
    - Intégration avec AWS (par exemple, déploiement sur AWS)

---

explication du code pour le test CI pipeline dans GitHub :

name: CI

on:
  push:
    branches: [ main ]

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8

    - name: Install dependencies
      run: |
        pip install --upgrade pip
        pip install -r requirements.txt

    - name: Run tests
      run: pytest
---

Ce fichier est écrit en YAML et est utilisé pour configurer un workflow GitHub Actions. Voici une explication de chaque partie :

name: CI: Définit le nom du workflow comme "CI".
on: Définit les déclencheurs du workflow. Dans ce cas, il est déclenché à chaque fois qu'un push est effectué sur la branche principale (main).
jobs: Définit les étapes à exécuter pour le workflow.
build: Définit un travail appelé "build".
runs-on: ubuntu-latest: Spécifie l'environnement d'exécution du travail comme Ubuntu.
steps: Définit les étapes à exécuter dans le travail.
name: Définit le nom de l'étape.
uses: Utilise une action existante. Par exemple, actions/checkout@v2 est utilisé pour récupérer le code du référentiel.
with: Fournit des paramètres à l'action.
run: Exécute une commande dans l'environnement de travail. Par exemple, pytest est utilisé pour exécuter les tests.
En résumé, ce fichier YAML définit un workflow GitHub Actions qui effectue les actions suivantes :

Récupère le code du référentiel.
Configure un environnement Python.
Installe les dépendances du projet.
Exécute les tests à l'aide de pytest.

Ce README fournit un aperçu de la structure du code et des instructions de configuration pour la construction et l'exécution des applications.
