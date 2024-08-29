# Demonstration of DSpace REST API bug 9781

## Purpose

This simple program can be used to reproduce the DSpace REST API bug that was
reported in Github issue https://github.com/DSpace/DSpace/issues/9781

It was created by Sascha Szott (https://github.com/saschaszott).

## Usage

Run this program **twice** to trigger the error. If the error does not occur,
run the program two more times. If you cannot trigger the error in this way,
consider increasing the value of variable `MAX_NUM_OF_STATUS_REQUESTS` or 
modify (increase) the sleep period before the first GET request on `/api/authn/status`
is executed.

The error described in Github issue [9781](https://github.com/DSpace/DSpace/issues/9781)
(usually) occurs in the second run of the program.

## Which steps does the program perform?

The program performs a simple login - get status - logout roundtrip against the REST API of
the official DSpace Demo instance (https://demo.dspace.org). It executes the following steps:

- receive a valid CSRF token
- perform a login with demo user `dspacedemo+admin@gmail.com`
- after successful login: repeatedly get authentication status
- perform a logout

The program execution aborts immediately if the authentication status is `false`.

## Program output (first run - successful execution)

```sh
$ run.sh
CSRF token: b556e9be-e44c-4b9a-a0c4-3e0394092906
JWT token: eyJhbGciOiJIUzI1NiJ9.eyJlaWQiOiIzMzU2NDdiNi04YTUyLTRlY2ItYThjMS03ZWJhYmIxOTliZGEiLCJzZyI6W10sImV4cCI6MTcyNDkyMjUyOCwiYXV0aGVudGljYXRpb25NZXRob2QiOiJwYXNzd29yZCJ9.5wuU-KTPM7Pp8jbvRc5i07hJRKEmHE9kYh0aarDMcbE
TTTTTTTTTTTTTTTTTTTTT
No failures detected so far - log out
logout response code: 204
```

## Program output (second run - failed execution)

```sh
$ run.sh
CSRF token: 12fb2b7a-cfe9-4c32-9e2b-647ca7243700
JWT token: eyJhbGciOiJIUzI1NiJ9.eyJlaWQiOiIzMzU2NDdiNi04YTUyLTRlY2ItYThjMS03ZWJhYmIxOTliZGEiLCJzZyI6W10sImV4cCI6MTcyNDkyMjU0MSwiYXV0aGVudGljYXRpb25NZXRob2QiOiJwYXNzd29yZCJ9.0OFtSPkk9nmObmOxngCjlTXMXxzdjvL99Q5oZ2Wmx9U
TTF
Failure occurred - GET /api/authn/status returned "authenticated": false
```
