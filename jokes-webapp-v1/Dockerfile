# Use an official Python runtime as a parent image
# FROM python:3.9-slim
FROM python:3.13-alpine

# Install shadow required packages for python 3.13-alpine
# Set up a non-root user
RUN apk add --no-cache shadow && \
    groupadd -r ce7-grp2-app && \
    useradd -r -g ce7-grp2-app ce7-grp2-user

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
# COPY . /app
COPY .dockerignore /app/.dockerignore
COPY Dockerfile /app/Dockerfile
COPY index.html /app/index.html
COPY joke.png /app/joke.png
COPY jokes_app.py /app/jokes_app.py
COPY jokesbank.csv /app/jokesbank.csv
COPY requirements.txt /app/requirements.txt
COPY styles.css /app/styles.css

# Set permissions for the non-root user
RUN chown -R ce7-grp2-user:ce7-grp2-app /app

# Ensure the non-root user can install packages to their local directory
RUN mkdir -p /home/ce7-grp2-user/.local/bin && chown -R ce7-grp2-user:ce7-grp2-app /home/ce7-grp2-user/.local

# Switch to the non-root user
USER ce7-grp2-user

# Add local installation directory to PATH
ENV PATH="/home/ce7-grp2-user/.local/bin:${PATH}"

# Install any needed packages specified in requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir --user -r /app/requirements.txt
    
# Expose the port the app runs on (Flask defaults to 5000)
EXPOSE 5000

# Define environment variable to tell Flask to run the application
ENV FLASK_APP=jokes_app.py  
ENV FLASK_RUN_HOST=0.0.0.0

# Run flask when the container launches
# CMD ["flask", "run"]
CMD ["/home/ce7-grp2-user/.local/bin/flask", "run"]
