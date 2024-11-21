FROM node:23-alpine
WORKDIR /usr/src/app
COPY package*.json ./
COPY . .
RUN npm install
EXPOSE 8080
CMD ["npm", "start"]