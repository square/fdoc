# fdoc File Naming Guide

A sample file hierarchy (derived from `spec/fixtures`)

    * docs/fdoc              |
      - sample.fdoc.service  |
      * members              |
        - add-PUT.fdoc       | docs/fdoc/members/add-PUT.fdoc
        - draft-POST.fdoc    | docs/fdoc/members/draft-POST.fdoc
        * list               |
          - GET.fdoc         | docs/fdoc/members/list/GET.fdoc
          - filter-GET.fdoc  | docs/fdoc/members/list/filter-GET.fdoc

These files describe an API with the following endpoints:

- `PUT  /members/add`
- `POST /members/draft`
- `GET  /members/list`
- `GET  /members/list/filter`

## Endpoints

Endpoint filenames must match `*.fdoc`. The endpoints derive their API path from their path relative to their service file.

Given a VERB and a PATH, an endpoint *must* be named one of:

- `PATH-VERB.fdoc` (flat style)
- `PATH/VERB.fdoc` (nested style)

There is no one default that covers all cases, so fdoc offers two options. The flat style works for groups of one-off endpoints, while the nested style groups well for endpoints that can be grouped.

## Services

Services are groups of endpoints.

- A service filename must match `*.fdoc.service`
- A service file *must* marks the top-level directory for a service. All endpoint files must be in or nested in the same directory as their service file.

Service files contain

- `name`: their human-readable name or title
- `basePath`: the prefix shared by all endpoints of the service
- `description`: a description, parsed as Markdown, that appears at the top of service HTML pages
- `discussion`: a longer description, also parsed as Markdown, that appears at the bottom of service HTML pages

## Meta-Services

Meta-services are groups of services.

- A meta-service filename must match `*.fdoc.meta`
- Services referenced by the meta-service may be anywhere.

Meta-service files contain

- `name`: their human-readable name or title
- `services`: an array of paths to directories that contain `*.fdoc.service` files. Paths may be relative, absolute, or `~`-prefixed
- `description`: a description, parsed as Markdown, that appears at the top of meta-service HTML pages
- `discussion`: a longer description, also parsed as Markdown, that appears at the bottom of meta-service HTML pages