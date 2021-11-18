# Makefile targets

## General

- `help`            print this message
- `readme`          print the README

## Development

- `server`          run development server
- `check`           run static analyser
- `format`          format code
- `docs`            generate elixir and swagger documentation
- `coverage`        check test code coverage

## Building

- `clean`           clean the project
- `release`         build a release

## Testing

- `test`            run all tests
- `test-watch`      run test with autoreload, requires fswtch

## Databse

- `psql`            connect to the database with psql
- `test-psql`       connect to the database with psql (test)
- `db`              reset database (only in development)
- `test-db`         reset test database (only in development)
- `migrate`         migrate all migrations (only in development)
- `rollback`        rollback one migration (only in development)
- `rollback-all`    rollback all migrations (only in development)
- `remigrate`       rollback and reapply migrations without droping DB
