# VacEngine Installation

## Prerequisites

The detailed installation instructions below are aimed to Ubuntu/Debian
distributions. For other distributions, installation instructions are
available on the websites the different softwares.

#### erlang and rebar3

```console
sudo apt install erlang
```

For other distirubtions, installation files are available at

https://www.erlang.org/downloads


#### elixir

```console
Wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt update
sudo apt install esl-erlang
sudo apt install elixir
```

#### nodejs and npm

```console
sudo apt install nodejs npm
```

Upgrade npm and node if needed:
```console
sudo npm install -g n
sudo n latest
```

#### yarn
```console
sudo npm install --global yarn
```

#### inotify-tools
sudo apt install inotify-tools

#### postgresql
sudo apt install postgresql postgresql-contrib


## Environment Variables

The application is configured throught environment variables.

There is two types of environment variables:
- compile time environment variables
- run time environment variables

### Compile time environment variables

Must be available on the machine that compiles the application.

- `SESSION_SIGNING_SALT`
- `SESSION_ENCRYPTION_SALT`
- `SESSION_KEY`
- `LIVE_VIEW_SALT`

All the environment variables above are mandatory. They must be available on the system both:
- when compiling (i.e. when executing "make release") or
- when starting the dev server (i.e. when executing "make server")

### Run time environment variables

Must be available on the machine that runs the application. The variables are partly different for production and development.


#### Production

- `DATABASE_URL`
- `HOST`
- `PORT`
- `SECRET_KEY_BASE`
- `POOL_SIZE` ¹
- `ADDRESS` ²
- `SSL_KEY_PATH` ³
- `SSL_CERT_PATH` ³

 ¹ Optional, defaults to 10.  
 ² Optional, defaults to "::0".  
 ³ Optional, only necessary if the application is supposed to terminate SSL connections.

#### Development

- `DATABASE_URL`
- `DATABASE_TEST_URL` ¹
- `NO_DEBUG_LOG` ²
  
¹ Only necessary to run tests.
² Optional, prevents debug log output.  



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

Example:
```
postgresql://user:password@127.0.0.1:5432/dbname
```

[Format](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)

When using make to run test, the Makefile will override `DATABASE_URL` with
`DATABASE_TEST_URL`.

### `DATABASE_TEST_URL`

Same as `DATABASE_URL` but used when running tests.

### `HOST`

The public host of the server.

This is used to generate redirect URLs.

For example, if set to `myapp.example.com` then all full URLs would be
`https://myapp.example.com/path`.

This is only a hostname, protocol will be forced to `https` and no path can be
added.

### `PORT`

The HTTP port on which Erlang will listen (can be proxied, but not necessary).

### `POOL_SIZE`

The postgresql pool size. This is the number of database connection to open.

Default to 10.

### `ADDRESS`

The IP address to bind the HTTP listener to. By default it will use `::0` which
will bind to all ipv6 and ipv4 addresses. You can set it to either an ipv6 or
ipv4 address. Set it to `127.0.0.1` for ipv4 only localhost listening.

### `SECRET_KEY_BASE`

This is the secret used to derive all the keys used in the application.

Must be a random string between 64 and 120 characters long.

This is a secret and must be protected.

Modifying this key will invalidate all cookies, sessions, activation tokens.

### `SSL_KEY_PATH`

Path to a `.pem` file containing the private key.

If both `SSL_KEY_PATH` and `SSL_CERT_PATH` are set, the application
will terminate SSL itself, and `PORT` should be set to `443`.

### `SSL_CERT_PATH`

Path to a `.pem` file containing the FULL CHAIN certificate.

If both `SSL_KEY_PATH` and `SSL_CERT_PATH` are set, the application
will terminate SSL itself, and `PORT` should be set to `443`.

### `NO_DEBUG_LOG`

If set to true, no debug log will be output.

## Initialize Database

### Development

To initialize the database on the development machine, run:

```console
make db
```

Note: The command will output the credentials of the admin user of the
application. Write it down so you can connect to the application interface.

And if you intend to run test, create the test database by running:

```console
make test-db
```

Note: the two commands above will only succeed if the `DATABASE_URL` and `DATABASE_TEST_URL` are set, respectively.

### Production

On production, you need to create a database with the dbname, user and password corresponding to the `DATABASE_URL` environment variable.

In order to populate the database, you need to play the migrations by executing the following command:
```console
./bin/vac_engine eval 'VacEngine.Release.migrate'
```

Then finally, create an admin user using the following command (don't forget to write down the credentials):
```console
./bin/vac_engine eval 'VacEngine.Release.create_admin'
```

## Next Steps

From now, you can start developing or deploying the app. Please refer to
the DEVELOPEMENT.md and DEPLOYMENT.md files respectively.


