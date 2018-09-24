# Panter Public Data Api

## Components used

* Redis
* Panter Controllr
* Github
* Gitlab

## Setup

* Install ruby (`rbenv` recommended)
* Install redis
* `cp .env.example .env` and fill in some values (esp. the access tokens)
* `rake clone_git_repositories` to have all git repositories locally.
  alternatively you can rsync the cloned repositories from the production
  server.
* `rails s`

  The server will fetch all data for all modules by default. To only load
  certain modules the environment variable `MODULES` can be used.

  Example 1, only load controllr data

  `MODULES=controllr rails s`

  Example 2, skip all data fetching altogether (useful when you already have
  data fetched previously and want to quickly start the server)

  `MODULES= rails s`

  Example 3, fetch git and controllr data

  `MODULES=controllr,git rails s`

## Swagger API Doc

Whenever an endpoint is updated or a new one is added the swagger docs need to
be updated as well. [ZRO: OpenApi 3 JSON-Doc Generator for
Rails](https://github.com/zhandao/zero-rails_openapi) is used for this.

After updating the definition in the respective controller the task `rake doc`
generates the Swagger definition in `public/api.json`. This file should be
checked in to Git as well.

## License

Licensed under the [GNU Affero General Public License v3.0](LICENSE)

    Copyright 2016 Panter AG <info@panter.ch>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
