# fdoc
## Farnsdocs: Documentation format and verification

High-quality documentation is extremely useful, but maintaining it is often a pain. We aim to create a tool to facilitate easy creation and maintenance of API documentation.

### Goals

 - As a client engineer, I want to be able to document an API and keep it up to date
 - The server engineers want to be able to test their implementations
 - The documentation should be as close to the code as possible, it should live in the same repository (like specs)
   - Branches, reviews, and merges are the appropriate way to update the docs
   - Experimental drafts should just live on branches and never get merged into master
 - Specification alone is not enough, there needs to be room for discussion

### Usage

Fdoc creates an object graph based on `.fdoc` files in a directory when it is loaded (`Fdoc::load`), representing the source of truth.

The `MethodChecklist` class is the verifier of this source of truth, by wrapping around an individual method on an endpoint. Use `MethodChecklist#consume_request` and `#consume_request`, and it will return `true` if input data matches expectations, or raise some sort of `DocumentationError` if there is an incongruency. The intention is that this checklist is run in a spec environment in a project, to intercept usage of an endpoint.

Alternatively, to help create documentation, the `MethodScaffold` class can help create documentation. Its `#scaffold_request` and `#scaffold_response` take the exact same arguments as those of the checklist, but will absorb all incoming parameters and update the object graph. To write this object graph to disk, use `ResourceScaffold::write_to_directory`

### Hierarchy

In fdoc, the top level object in a graph is a Resource -- there is a one-to-one relation between Resources and individual `.fdoc` files. Resources typically represent groups of API endpoints (such as `/members`).

Resources can have multiple Methods, such as `GET list` or `POST add` (these are sometimes referred to as actions, because both `method` and `methods` would clash with built-in Ruby methods, natch). Methods represent individual endpoints and are essentially the atomic unit of testing and are often identified by their (`verb`, `name`) tuple.

Methods have:

- Request Parameters
    - Which must specify if they are required or not.
- Response Parameters
- Response Codes
    - Which must specify if they are successful or not.

### Feedback

Feedback from fdoc comes in the form of `DocumentationError`s thrown by `MethodChecklist`'s `#consume_request` and `#consume_request`.

- `MissingRequiredParameterError`
    - If a method's request parameter is marked as required, fdoc will expect that key in every single request, so missing that key is an error. Unfortunately, the `Required` property is a simple boolean, there is not yet a way to specify that a parameter is conditionally required. The temporary fix is to specify `Required: No` and describe clearly in the `Description` field how to use the field.
- `UndocumentedParameterError`
    - An undocumented parameter is an unknown key. This is an error because it indicates new functionality must have been added, but not documented.
- `UndocumentedResponseCodeError`
    - An unknown response code is also an unknown key. This is an error because because it indicates that a new result must have been added, but not documented.
- `UndocumentedMethodError`
    - See above.
