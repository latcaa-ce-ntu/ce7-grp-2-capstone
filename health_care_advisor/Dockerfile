# Use Python base image
FROM python:3.13-alpine

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY app/ .

# Expose port and run the app
EXPOSE 5000
CMD ["python", "app.py"]
