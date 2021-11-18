# Deployment

## Compiling a release

NOTE: If you build in your development machine, be sure to stop `make server`
prior to build.

Compile time env var must be set prior to build.

The application is the compiled with:

```shell
make clean
make release
```

This will generate the application in:

`_build/prod/rel/vac_engine`

When the release is built, the
`_build/prod/rel/vac_engine`
folder is self contained.

## Deployment

1. Move the whole application folder (located at `_build/prod/rel/vac_engine`
   after the build) to your target machine.
2. Start the app from the application folder on your destination machine:

```console
./bin/vac_engine start
```

## Release tasks

Once the server has started, you can use the release tasks the following way:
```console
./bin/vac_engine eval 'VacEngine.Release.<task_name>'
```

The following release tasks are available:

- `migrate()` - Migrate the database to the last version.
- `rollback(version)` - Rollback the database to the provided version.
- `create_admin()` - Create a default admin user, the credentials will be logged
  to `STDOUT`.

## SSL

The application MUST be served on HTTPS.

Two configurations are possible:

- Put a reverse proxy terminating SSL in front of the application, the
  application listener will be on HTTP on the given `PORT`.
- Configure `SSL_KEY_PATH` and `SSL_CERT_PATH` and the application
  will terminate SSL itself, `PORT` must be 443.

### Reverse proxy

If you use a reverse proxy, you must pass the following headers:

- `X-Real-IP`
- `X-Forwarded-For`
- `X-Forwarded-Proto`

Example Nginx configuration:

```
server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        include ssl.conf;
        include errors.conf;
        server_name vac-engine.goyman.com;

        location / {
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $http_connection;
                proxy_read_timeout 86400;
                proxy_pass http://127.0.0.1:3003;
        }
}
```
