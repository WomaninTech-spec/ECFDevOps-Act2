# Base Image OpenJDK 11 JRE Slim as Spark needs OpenJDK 8+
FROM openjdk:11-jre-slim

# Install Python, wget, and procps
RUN apt-get update && \
    apt-get install -y python3 python3-pip wget procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy your application files into the container
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run your application
CMD ["python", "app.py"]
