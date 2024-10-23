# DrOnline.Umbrella

[![pipeline status](https://git.appunite.com/dronline/dronline-backend/badges/master/pipeline.svg)](https://git.appunite.com/dronline/dronline-backend/commits/master)

## Development setup

1. Install [asdf version manager](https://github.com/asdf-vm/asdf)
2. Install plugins (`asdf plugin add erlang` and repeat for `elixir` and `protoc`) and run `asdf install` to install correct version of erlang/otp and elixir
3. Install docker to run database [Docker](https://www.docker.com/products/docker-desktop/)
4. Start docker compose `docker compose up -d`
5. Run `mix deps.get` to download dependencies
6. Run `mix ecto.create` to create database
7. Run `iex -S mix phx.server` to start local server
    - if error occurs `Could not start application pdf_generator [...] wkhtmltopdf executable was not found on your system` run `brew install wkhtmltopdf`

## Tests

1. `MIX_ENV=test mix ecto.create && MIX_ENV=test mix ecto.migrate`
2. `mix test`

## Useful

- `psql` - open PostgreSQL console
- `createdb` - create a new PostgreSQL database for current user
- `CREATE ROLE postgres SUPERUSER LOGIN;` crete role postgres

## Compile protobufs

This process is complicated and requires Elixir installed via asdf and a little magic with `.zshrc` or `.bashrc` files to add compilers to your path.
We download binary protoc directly since asdf doesn't support that old version of protobuf (idk why exactly, they also changed the versioning in protobuf repository).

Proto definitions are set a submodule, to keep them up2date you should run: `git submodule update --recursive --remote`, **NOTE** After fresh clone you should also add `--init` flag to the given command.

### To add new changes to protobufs:

1. Install elixir-protobuf escript according to version we are actually using (e.g. `mix escript.install hex protobuf 0.7.1`)
2. Run `asdf reshim`
3. Each time you want to compile protobufs:

    - Run `./scripts/compile-local-protobufs.sh` in `dronline-backend` directory
    - Create new branch in `/dronline-backend/apps/proto/proto_submodule` and add changes in `messages/` to new commit. Push that commit to remote. New pull request will be automatically created in [dronline-protobuf](https://github.com/Dronline-Inc/dronline-protobuf) repo
    - Go back to `dronline-backend` directory. Add the changes made by script in `apps/proto/lib/pb/` to the rest of your changes to dronline-backend 

## Build release locally

- `COMMIT_SHA=<string here> mix release --env=prod`

## Use dump from k8s in localhost

- `kubectl exec [PG_POD_NAME] -- bash -c "pg_dump -U postgres dronline_dev > /home/dronline_dev.sql"`
- `kubectl cp dronline/[PG_POD_NAME]:home/dronline_dev.sql dronline_dev.sql`
- `psql -U postgres -d dronline_dev -1 -f dronline_dev.sql`

## Database magic

### `Postgres.Repo.Migrations.CreateTriggersForHandlingActiveSubscriptions`

introduced 2 database triggers to our system. They are responsible for tracking active subscription for external doctors.

They were written because, they:

- reduce number of database transactions in Elixir code,
- guarantee desired state in database (keep only one active subscription) and help managing (upgrading/downgrading/cancelling) subscriptions,
- allow us to keep type of active subscription in handy place for authorization.

First one, called `subscription_activation_trigger` is activated when status of subscription is set to `ACCEPTED`. The trigger checks if there is already active subscription for given specialist. In the case there is no such subscription, updated one is set to active and type of this subscription is set in `specialists` table as active package.

Second one - `subscription_deactivation_trigger` is activated when status of subscription is set to `ENDED`. First the trigger deactivates current subscription. Then checks if there is subscription waiting for activation - with status `ACCEPTED`. If there is a such subscription it is set to active. In the other case pacakge type for specialist is being set to `BASIC`.

### `Postgres.Repo.Migrations.UpdateTableAndTriggersForPatientFiltering`

_Updated in `Postgres.Repo.Migrations.UsePatientInsteadOfUser`_

introduced 2 triggers and `patient_filter_datas` table with `tsvector` column. They are responsible for keeping data required for patients filtering up to date.

They were written because:

- there should be more reads than writes thus we want to persist results of `to_tsvector` calls,
- triggers reduce number of database transactions in Elixir code,
- triggers eliminate necessity of writing custom ecto type for `tsvector`.

Both triggers do the same thing. They upsert a row in `patient_filter_datas` when corresponding row in `patient_basic_infos` or `patient_addresses` is inserted or updated.

### `Postgres.Repo.Migrations.CreateTableAndTriggersForSpecialistsFiltering`

introduced 2 triggers and `specialist_filter_datas` table with `tsvector` column. They are responsible for keeping data required for specialists filtering up to date.

## Githooks

Git hooks allow scripts to be executed before or after certain git processes. In this project, we
use Client-side hooks to reduce costs of Github Actions by. We decide
to add Githooks to the project for better stability and prevent regression. All Githooks are located
in /.githooks.

By default, git hooks reside in the ./git/hooks folder. The problem is that this folder would not be
part of source control and everyone in team should be using the same hooks. To change the hooks
folder to be .githooks, run:

```sh
git config core.hooksPath .githooks/
```

Git hooks should be run whenever possible, but for the few times that you want to skip the hook
execution, add the no-verify or -n flags. e.g.

```sh
$ git commit --no-verify -m 'demo commit message'
```

or

```sh
git commit -n -m 'demo commit message'
```
