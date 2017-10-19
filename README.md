# Picobrew Proxy Server

Provides a web based REST api to your Picobrew data - recipes, sessions, etc.  Just acts as a pass-through proxy to the Picobrew server, does not store any data.

To show examples of what data can be fetched, there's a *very* simple webapp running with the api proxy that will render the data in html.  Login at http://foo.com and browse around to see what it looks like.

### Proxy API

You'll need to first login with your Picobrew account credentials and have cookies enabled in whatever you're hitting the api endpoints with.


```
# Login
$ curl -c cookiefile -X POST -F "user=username" -F "password=password" http://pico-proxy/login
# Get a list of your recipes
$ curl -b cookiefile http://pico-proxy/api/recipes
```

See the [Wiki]() for documentation on the current API endpoints.

### Build
```
docker build -t pico-proxy .
```

### Run
```
docker run -d --name pico-proxy -p 3000:3000 pico-proxy
```

### Run in Development
```
docker run -it --rm -p 3000:3000 -v $PWD:/app/ pico-proxy dev
```

This will mount and serve your local project files in the container, and auto-reload changes as you save them.

### Contributing

Issues and pull requests are welcome!  Note that the heavy lifting of interfacing with the Picobrew backend is split out into a separate project at https://github.com/toddq/picobrew-api, so check that out too.