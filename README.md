# fenv

Patch html files with `REACT_APP_` environment variables within docker.

## Usage

### Starting point
Assuming you have frontend dockerfile defined like this:

```Dockerfile
FROM nginx:1.19.2
WORKDIR /app

# your payload
COPY /build/ /usr/share/nginx/html/
```

(Your main html file is in `/usr/share/nginx/html/index.html`)

### Introduce fenv

Include `fenv.sh` in your docker container and make it the default entrypoint.

```Dockerfile
FROM nginx:1.19.2
WORKDIR /app

# your payload
COPY /build/ /usr/share/nginx/html/

# adjust left path to your situation
COPY vendor/fenv.sh /usr/local/bin

ENTRYPOINT ["fenv.sh", "/usr/share/nginx/html/index.html"]
```

### Test

Let's assume we have the following (very basic) html file in docker.

```html
<html>
    <head>
        </head>
    <body>
    </body>
</html>
```

If we start the container with:

```bash
docker run -e REACT_APP_SOMETHING="else" <imagename>
```

The index.html within docker would be changed to:

```html
<html>
    <head>
        </head>
    <body><script id="fenv">window.env = {REACT_APP_SOMETHING: 'else',};</script>
    </body>
</html>

