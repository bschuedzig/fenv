FROM nginx:1.21.5-alpine

# alpine does not come with bash by default
RUN apk add --no-cache bash

WORKDIR /usr/share/nginx/html

COPY ./fenv.sh /docker-entrypoint.d/99-fenv.sh

COPY /app/ ./
