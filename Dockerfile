# base image with enforce yarn install
FROM node:21 as base
WORKDIR /app
ADD ./package.json ./package.json
ADD ./yarn.lock ./yarn.lock
RUN npm install -g yarn --force 

# All deps stage
FROM base as deps
WORKDIR /app
ADD package.json ./
RUN yarn install

# Production only deps stage
FROM base as production_deps
WORKDIR /app
ADD package.json ./
RUN yarn install --production

# Build stage
FROM base as build
WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
ADD . .
RUN yarn run build

# Production stage
FROM base AS prod
ENV NODE_ENV=production
WORKDIR /app
COPY --from=production_deps /app/node_modules /app/node_modules
COPY --from=build /app/build /app
CMD ["yarn", "start"]
