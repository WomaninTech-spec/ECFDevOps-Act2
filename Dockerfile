# Use a base image that includes Python
FROM python:3.8-slim

# Set environment variables for Corretto version and installation path
ENV CORRETTO_VERSION=11.0.16.8.1
ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto

# Install necessary dependencies and Corretto
RUN apt-get update \
    && apt-get install -y wget \
    && wget -O- https://apt.corretto.aws/corretto.key | apt-key add - \
    && echo 'deb https://apt.corretto.aws stable main' | tee /etc/apt/sources.list.d/corretto.list \
    && apt-get update \
    && apt-get install -y java-11-amazon-corretto-jdk \
    && apt-get clean

# Copy your application files into the container
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run your application
CMD ["python", "app.py"]
