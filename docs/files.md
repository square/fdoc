# fdoc File Naming Guide

A sample file hierarchy (derived from `spec/fixtures`)

    * docs/fdoc
      - sample.fdoc.service
      * members
        - add-PUT.fdoc
        - draft-POST.fdoc
        * list
          - GET.fdoc
          - filter-GET.fdoc

These files describe an API with the following endpoints:

- `PUT  /members/add`
- `POST /members/draft`
- `GET  /members/list`
- `GET  /members/list/filter`

## Endpoints

Endpoint filenames must match `*.fdoc` and derive their paths from their path relative to their service.

Given a VERB and a PATH, an endpoint *must* be named one of:

- `PATH-VERB.fdoc` (flat style) 
- `PATH/VERB.fdoc` (nested style)

Whichever naming convention is used does not matter. There is no one default that works for all cases, because the flat style makes no sense when an endpoint is part of a group, and the nested style makes no sense for a bunch of one-off endpoints.

## Services

Services are groups of endpoints.

- A service filename must match `*.fdoc.service`
- A service file *must* marks the top-level directory for a service. All endpoint files must be in or nested in the same directory as their service file.

Service files contain
- `name`: their human-readable name or title
- `basePath`: the prefix shared by all endpoints of the service
- `description`


## Meta-Services

Meta-services are groups of services.

- A meta-service filename must match `*.fdoc.meta`
- Services referenced by the meta-service may be anywhere.

Meta-service files contain
- `name`: their human-readable name or title
- `services`: an array of paths to directories that contain `*.fdoc.service` files. Paths may be relative, absolute, or `~`-prefixed
- `description`