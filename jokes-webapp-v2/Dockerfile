# Use the official Python image with Alpine (lightweight)
FROM python:3.13-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements.txt to the container
COPY requirements.txt /app/

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code to the container
COPY . /app/

# Set environment variables (optional for your Flask app)
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Expose the port Flask will run on (default is 5000)
EXPOSE 5000

# Run the Flask app
CMD ["flask", "run", "--host=0.0.0.0"]