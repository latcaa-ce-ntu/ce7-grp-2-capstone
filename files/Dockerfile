# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
# COPY . /app
COPY Dockerfile /app/Dockerfile
COPY index.html /app/index.html
COPY joke.png /app/joke.png
COPY jokes_app.py /app/jokes_app.py
COPY jokesbank.csv /app/jokesbank.csv
COPY requirements.txt /app/requirements.txt
COPY styles.css /app/styles.css


# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app runs on (Flask defaults to 5000)
EXPOSE 5000

# Define environment variable to tell Flask to run the application
ENV FLASK_APP=jokes_app.py  
ENV FLASK_RUN_HOST=0.0.0.0

# Run flask when the container launches
CMD ["flask", "run"]