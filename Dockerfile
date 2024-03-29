FROM node:20 AS build

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./
RUN npm install
COPY . ./
RUN npm run build

FROM nginx:1.25-alpine
COPY --from=build /app/public /usr/share/nginx/html

# docker build . -t svelte-docker
# docker run --rm --name=svelte-docker -p 5500:80 svelte-docker