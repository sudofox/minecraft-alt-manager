# sudofox/minecraft-alt-manager

A tool to use to store Minecraft credentials

Requires: PHP with SQLite3 extension (if not already installed)


## Initialize the database (this only needs to be run once!)

```
$ cat schema.sql | sqlite3 database/alt-manager.db
```

## Add an account...

```
./add_account.sh
$ Add new Minecraft account to the database.
Usage: ./add_account.sh <email address> <username> <password>
```

## Refresh accessToken/clientToken

Incomplete: This only populates the accessToken and clientToken if we don't already have one.

```
Check if current access token/client token is usable, and if not, obtain a new one
Usage: ./refresh_account.sh <email address or username>
```

## TODO:

- Actual account verification 
- Token storage
- Integration with Minecraft clients (?)

