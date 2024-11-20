FROM node:23-alpine
WORKDIR /my-app
COPY package*.json ./
COPY . .
RUN npm install
EXPOSE 8080
CMD ["node", "index.js"]