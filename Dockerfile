# Use a specific version of the official Node.js Alpine image for a small footprint and reduced attack surface
FROM node:21-alpine3.18 as builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if available) to leverage Docker cache layers
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Install ncc
RUN npm install -g @vercel/ncc

# Copy the rest of the application code
COPY . .

# Use ncc to compile the application to a single file
RUN ncc build index.js -o dist

# Use a multi-stage build to minimize the final image size and reduce attack surface
FROM node:21-alpine3.18

# Set non-root user and switch to it for security
USER node

# Set the working directory in the new stage
WORKDIR /app

# Copy the compiled application from the previous stage
COPY --from=builder /app/dist/index.js ./index.js

# Define runtime environment variables if necessary
# ENV NODE_ENV=production

# Open the port the app runs on
EXPOSE 3000

# Run the compiled application
CMD ["node", "index.js"]
