# Pull the Node.js image

# for local computer Macbook M2
# FROM node:18-alpine

# for AWS
FROM --platform=linux/amd64 node:18-alpine

# Create a Docker working directory
WORKDIR /usr/src/app

# copy dependencies files
COPY package*.json ./

# Install dependencies inside Docker
RUN npm install

# Copy the application source code
COPY . .

# Port number to expose the Node.js app outside Docker
EXPOSE 5000

# Command to run the application
CMD ["node", "index.js"]