# VacEngine


## Compiling a release

NOTE: If you build in your development machine, be sure to stop `make server`
prior to build.

Compile time env var must be set prior to build.

The application is the compiled with:

`make release`

This will generate the application in:

`_build/prod/rel/vac_engine`

This whole folder must be then deployed.

The binary to control the app is:

`_build/prod/rel/vac_engine/bin/vac_engine`

## Environment variables

The application is configured throught environment variables.

There is two types of environment variables.

Compile time env var:

- `SESSION_SIGNING_SALT`
- `SESSION_ENCRYPTION_SALT`
- `SESSION_KEY`
- `LIVE_VIEW_SALT`

Run time env var:

- `DATABASE_URL`
- `HOST`
- `PORT`
- `SECRET_KEY_BASE`
- `POOL_SIZE`

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

The HTTP port to listen on.

### `SECRET_KEY_BASE`

This is the secret used to derive all the keys used in the application.

Must be a random string between 64 and 120 characters long.

This is a secret and must be protected.

### `POOL_SIZE`

The postgresql pool size. This is the number of database connection to open.

Default to 10.
