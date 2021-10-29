# VacEngine

## Development quick start

1) Set environment variables ([direnv](https://direnv.net/) is good)

    DATABASE_URL=postgres://<user>:<password>@<host>/<db_name>

2) Create database. This will:
    - drop database (if it exists)
    - create database with <db_name>
    - apply migrations
    - seed the database with an admin user (see below 4) and basic content

```
make db
```

3) Start server

    make server

4) Connect to localhost on port 4000

<https://localhost:4000>

Log in with the credentials `make db` printed.


## Compiling a release

NOTE: If you build in your development machine, be sure to stop `make server`
prior to build.

Compile time env var must be set prior to build.

The application is the compiled with:

`make clean`
`make release`

This will generate the application in:

`_build/prod/rel/vac_engine`

This whole folder must be then deployed.

The binary to control the app is:

`_build/prod/rel/vac_engine/bin/vac_engine`

## Release tasks

When the release is built, the
`_build/prod/rel/vac_engine`
folder is self contained.

Release tasks can be run with:

`./bin/vac_engine eval 'VacEngine.Release.<task_name>'`

The following release tasks are available:

- `migrate()` - Migrate the database to the last version
- `rollback(version)` - Rollback the database to the provided version
- `create_admin()` - Create a default admin user, the credentials will be logged
                     to STDOUT

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

## Environment variables

The application is configured throught environment variables.

There is two types of environment variables.

Compile time env var (must be available on the system when compiling i.e. when
executing "make release"):

- `SESSION_SIGNING_SALT`
- `SESSION_ENCRYPTION_SALT`
- `SESSION_KEY`
- `LIVE_VIEW_SALT`

Run time env var (must be available on the machine that runs the application):

- `DATABASE_URL`
- `HOST`
- `PORT`
- `SECRET_KEY_BASE`
- `POOL_SIZE`

Optional:

- `SSL_KEY_PATH`
- `SSL_CERT_PATH`

If both `SSL_KEY_PATH` and `SSL_CERT_PATH` are set, the application
will terminate SSL itself, and `PORT` should be set to `443`.

### `SESSION_SIGNING_SALT`

This is the session signing salt. This is a salt and not a secret.

Must be a random string between 8 and 32 characters long.

This is a compile time variable.

### `SESSION_ENCRYPTION_SALT`

This is the session encryption salt. This is a salt and not a secret.

Must be a random string between 8 and 32 characters long.

This is a compile time variable.

### `SESSION_KEY`

This is the name of the cookie used to store the session.

Must be a string between 4 and 16 characters long.

This is a compile time variable.

### `LIVE_VIEW_SALT`

This is the live view salt signing salt. This is a salt and not a secret.

Must be a random string between 8 and 32 characters long.

This is a compile time variable.

### `DATABASE_URL`

The database URL to use.

[Format](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)

When using make to run test, the Makefile will override `DATABASE_URL` with
`DATABASE_TEST_URL`.

### `HOST`

The public host of the server.

This is used to generate redirect URLs.

For example, if set to `myapp.example.com` then all full URLs would be
`https://myapp.example.com/path`.

This is only a hostname, protocol will be forced to `https` and no path can be
added.

### `PORT`

The HTTP port on which Erlang will listen (can be proxied, but not necessary).

### `ADDRESS`

The IP address to bind the HTTP listener to. By default it will use `::0` which
will bind to all ipv6 and ipv4 addresses. You can set it to either an ipv6 or
ipv4 address. Set it to `127.0.0.1` for ipv4 only localhost listening.

### `SECRET_KEY_BASE`

This is the secret used to derive all the keys used in the application.

Must be a random string between 64 and 120 characters long.

This is a secret and must be protected.

Modifying this key will invalidate all cookies, sessions, activation tokens.

### `POOL_SIZE`

The postgresql pool size. This is the number of database connection to open.

Default to 10.

### `SSL_KEY_PATH`

Path to a `.pem` file containing the private key.

If both `SSL_KEY_PATH` and `SSL_CERT_PATH` are set, the application
will terminate SSL itself, and `PORT` should be set to `443`.

### `SSL_CERT_PATH`

Path to a `.pem` file containing the FULL CHAIN certificate.

If both `SSL_KEY_PATH` and `SSL_CERT_PATH` are set, the application
will terminate SSL itself, and `PORT` should be set to `443`.

## Processor expressions

### Types

- `boolean` - `true` or `false` (`0` and `nil` are not `false` and truthy values
  are not `true`)
- `integer` - an integer
- `number` - any number, integer or decimal (this type must NOT be used for
  equality)
- `string` - a string, length limited to 100 characters
- `enum` - a string with a specific set of pre-defined values
- `date` - a date with a precision of one day
- `datetime` - a date with time, time has a 1 second precision

### Functions

- `is_true(a)` - a is true
- `is_false(a)` - a is false
- `not(a)` - invert a
- `eq(a, b)` - a is equal to b. Not to be used for non integer numbers.
- `neq(a, b)` - a is not equal to b
- `gt(a, b)` - a is greater than b
- `gte(a, b)` - a is greater than or equal to b
- `lt(a, b)` - a is less than b
- `lte(a, b)` - a is less than or equal to b
- `add(a, b)` - add a and b
- `sub(a, b)` - subtract b from a
- `mult(a, b)` - multiply a with b
- `div(a, b)` - divide a with b
- `contains(a, b)` - check if a contains b


## Testing

### Coverage

Coverage can be analysed by running `make coverage`.

There is a `.coverignore` file that is used to ignore module from coverage
check.



