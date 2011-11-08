# fdoc
## Farnsdocs: Documentation format and verification

### Abstract

High-quality documentation is extremely useful, but maintaining it is often a pain. We aim to create a tool to facilitate easy creation and maintenance of API documentation.

### Goals

 - As a client engineer, I want to be able to document an API and keep it up to date
 - The server engineers want to be able to test their implementations
 - The documentation should be as close to the code as possible, it should live in the same repository (like specs)
   - Branches, reviews, and merges are the appropriate way to update the docs
   - Experimental drafts should just live on branches and never get merged into master
 - By reading the documentation, we should know what state the API is in
   - The human-readable docs should show whether an API is documented but unimplemented, implemented but incomplete, implemented and complete, etc.
 - Specification alone is not enough, there needs to be room for discussion
 - I want to be able to synthesize a single site from smaller sites. 

### Intermediate Tasks

 - Create a documentation text format that is both human- and machine-friendly (likely YAML-based). This is tantamount to adoption.
 - Come up with a way to generate static pages (basically a wiki) from the docs.
 - Come up with a way to generate spec scaffolding from the docs.
 - Come up with a way to update the documentation site based on the results of running the specs.
