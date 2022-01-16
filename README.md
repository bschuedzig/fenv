# fenv

Patch html files with runtime configuration. Useful when using `nginx` to host your single page applications.

## Usage

`fenv` expects a recent nginx image with support for `/docker-entrypoint.d` directory.

Additionally you need to install `bash` manually if you are using the `alpine` variant.

### Starting point

Assuming you have frontend dockerfile defined like this:

```Dockerfile
FROM nginx:1.21.5
WORKDIR /app

# your payload
COPY /build/ /usr/share/nginx/html/
```

(Your main html file is in `/usr/share/nginx/html/index.html`)

### Introduce fenv

- Clone `fenv.sh` (or copy it to your repository).
- Make sure that it has the `+x` (executable) flag
- Adjust variables if needed (path etc.)
- Include it in your container

⚠️ Make sure that bash is installed

```Dockerfile
FROM nginx:1.21.5-alpine

# For alpine you need to install bash by yourself
RUN apk add --no-cache bash

WORKDIR /app

# adjust left path to your situation
COPY vendor/fenv.sh /docker-entrypoint.d/99-fenv.sh

# your payload
COPY /build/ /usr/share/nginx/html/
```

### Test

Let's assume we have the following (very basic) html file in docker.

```html
<html>
  <head></head>
  <body></body>
</html>
```

If we start the container with:

```bash
docker run -e REACT_APP_SOMETHING="else" <imagename>
```

The index.html within docker would be changed to:

```html
<html>
  <head></head>
  <body>
    <script id="fenv">
      window.env = {REACT_APP_SOMETHING: "else"};
    </script>
  </body>
</html>
```

## Usage from within create-react-app / dotenv

Example typescript:

```ts
/**
 *  envName: the REACT_APP_ environment variable
 *  default1: a direct reference to it (useful for build replacements)
 *  default2: the fallback value
 */
function getEnv(envName: string, default1: string, default2: string): string {
  var wnd = window as any;

  // see if we have it in the window object
  if (wnd != null && wnd.env != null && wnd.env[envName] != null)
    return wnd.env[envName];

  // in environment variables?
  if (default1 != null) return default1;

  // fall back to user specified default value
  return default2;
}

const env = {
  apiUrl: getEnv(
    "REACT_APP_API_URL",
    process.env.REACT_APP_API_URL!,
    "http://localhost:3000/"
  ),
  stage: getEnv(
    "REACT_APP_API_URL_STAGE",
    process.env.REACT_APP_STAGE!,
    "development"
  ),
};

export {env};
```
