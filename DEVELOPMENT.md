# VacEngine Development

To install the development server, please refer to the INSTALLATION.md file.

## Run the development server locally

### Start server

To start the server, just run the following command:

```console
make server
```

### Connect to web application

You can now connect to the web application on <http://localhost:4000> and log in with
the credentials `make db` printed.

### Make api calls

In order to make api calls, you first need to create a blueprint, import it's content and publish it on a portal. A sample blueprint .json file is available in the `/examples/blueprints/` directory.

Report to the api interface documentation here: <https://vac-engine.github.com/api.html> to determine how to make calls to the API.

## Testing

### Run tests

Tests can be run by executing:
```console
make test
```

Fine grained testing can be made using the mix command directly:
```console
mix test <directory or file path>
```

### Coverage

Coverage can be analysed by running:
```console
make coverage
```

Coverage result will be printed on screen. More detailed information is generated in the `/cover/` directory.

There is a `.coverignore` file that is used to ignore module from coverage
check.

### Code formatting

Before committing your code, run:
```
make format
```
Doing so, you ensure that your code follows the elixir standard and that the project remains consistent.