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
CMD ["nginx", "-g", "daemon off;"]
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
```

## Usage from within create-react-app / dotenv

Example typescript:

```ts
function getEnv(envName: string, default1: string, default2: string): string {

  var wnd = window as any;

  // see if we have it in the window object
  if (wnd != null && wnd.env != null && wnd.env[envName] != null) return wnd.env[envName];

  // in environment variables?
  if (default1 != null) return default1;

  // fall back to user specified default value
  return default2;
}

const env = {
  apiUrl: getEnv('REACT_APP_API_URL', process.env.REACT_APP_API_URL!, ""),
  timeout: getEnv('REACT_APP_API_TIMEOUT', process.env.REACT_APP_TIMEOUT!, "5000"),
  stage: getEnv('REACT_APP_API_URL_STAGE', process.env.REACT_APP_STAGE!, ""),
}

export { env };
```
