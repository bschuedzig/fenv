FROM alpine:latest
WORKDIR /app

# alpine does not come with bash by default
RUN apk add --no-cache bash

# your payload
COPY /app/ ./

# the custom scripts
COPY fenv.sh /usr/local/bin

ENTRYPOINT ["fenv.sh", "/app/index.html"]

# usually this would be 'nginx' or something alike
CMD ["/app/program.sh"]
