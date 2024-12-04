# Use Node.js official image as base image
FROM node:latest

# Set working directory in the container
WORKDIR /usr/src/app

# Copy package.json
COPY package.json ./

# Copy the rest of the application code
COPY . .

# Install dependencies
RUN npm install -g npm@10.9.1
RUN npm install

# Expose the port that the app runs on
EXPOSE 5000

# Command to run the application
CMD ["npm", "start"]