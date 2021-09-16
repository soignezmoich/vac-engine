# Makefile targets

## General

- `help`            print this message
- `readme`          print the README

## Building

- `clean`           clean the project
- `release`         build a release

The following are called by `release` and should not be called directly.

- `assets`          build assets
- `build`           compile the app
- `deps`            fetch dependencies

## Server

- `server`          run development server

The following is automatically launched from `server` so you usually will never
call this directly.

- `assets-watch`    run the webpack assets pipeline

## Testing

- `test`            run all tests
- `test-watch`      run test with autoreload, requires fswtch

## Databse

- `psql`            connect to the database with psql
- `db`              reset database (only in development)
- `test-db`         reset test database (only in development)
- `rollback`        rollback one migration (only in development)
- `rollback-all`    rollback all migrations (only in development)
