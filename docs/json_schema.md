# JSON Schema in fdoc

## Verification

All the hard work of verifying that inputs conform their respective schemas is done by [hoxworth][hoxworth]'s [JSON schema gem][json-schema-gem].

We added a small patch to help error messages be more descriptive, and it was [merged upstream][square-contribution]. It's a useful tool, and we like to contribute back anything we can.

## Undocumented Keys

In our usage, the most valuable part of API documentation is what keys are and what they mean. By default, JSON schema does not care about extra keys, but it can if a schema's `additionalProperties` key is set to `false`.

At Square, our desired behavior is throw an error when a new property is detected in the schema to verify, indicating the documentation needs updating.

To achieve this, fdoc's verification methods will, in memory, modify schemas to default `additionalProperties` to `false` (unless specified).

[hoxworth]: https://github.com/hoxworth/
[json-schema-gem]: https://github.com/hoxworth/json-schema
[square-contribution]: https://github.com/hoxworth/json-schema/commit/bdb82ba2afce6f10fec405be3654d950c86d30c6
