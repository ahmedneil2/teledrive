FROM node:16.20.0 as build
ARG REACT_APP_TG_API_ID
ARG REACT_APP_TG_API_HASH

ENV NODE_ENV=production

WORKDIR /apps

COPY yarn.lock .
COPY package.json .
COPY api/package.json api/package.json
COPY web/package.json web/package.json
COPY docker/.env .
RUN yarn cache clean
RUN yarn install --network-timeout 1000000
COPY . .
# Generate Prisma client
RUN cd api && npx prisma generate

# Build API
RUN cd api && yarn build

# Build Web
RUN cd web && yarn build

# Create a smaller production image
FROM node:16.20.0-slim
WORKDIR /app

# Copy built files from the build stage
COPY --from=build /apps/api/dist /app/api/dist
COPY --from=build /apps/api/node_modules /app/api/node_modules
COPY --from=build /apps/api/prisma /app/api/prisma
COPY --from=build /apps/api/package.json /app/api/package.json
COPY --from=build /apps/web/build /app/web/build
COPY --from=build /apps/package.json /app/package.json

# Set environment variables
ENV NODE_ENV=production

# Expose port
EXPOSE 8080

# Start the application
CMD ["node", "api/dist/index.js"]
