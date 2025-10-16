# envsetup (development version)

# envsetup 0.3.0

- `paths` no are no longer attached to the search path (#80)
- `paths` objects default to the global environment now, but they can be changed using the `envsetup.path.environment` option (#80)
- `get_path()` was added to help you retrieve a path with changing the storage environment using the `envsetup.path.environment` option (#80)
- `autos` are no longer attached to the search path, and are sourced to global (#81)
- `rprofile` lets you specify if sourcing of autos should overwrite an object in global if it already exists (#81)
- extensive messaging added to make users aware of autos being attached and conflicts (#81)
- object metadata storage is added to track what functions were sourced from where, see `envsetup_environment$object_metadata` (#81)
- vignettes updated to divide content into smaller chunks (#82)

# envsetup 0.2.1

- `set_autos()` will now handle NULL hierarchical paths (#66)
- `set_autos()` will account for using `@include` to define function dependencies (#70)

# envsetup 0.2.0

- `library()` will no longer actively reset autos, instead placing newly attached packages in the correct position that respects existing autos (#59)

# envsetup 0.1.0

- Minor updates to prepare for initial CRAN release (#55)

# envsetup 0.0.1

## New Features

- `init()` added to assist with setting up a project to use envsetup (#20, #21, #31)
- `build_from_config()` added to add ability to also use config to create your directories (#25)
- `validate_config()` added to assist with creating configuration files (#23)
- `rprofile()` will automatically store your configuration file in a standard location with a standard name, allowing `library()` to use this to re-assign autos

## Breaking Changes

- `library()` will now respect invisible return instead of always returning the list of attached packages (#24)
- `set_autos()` now expects a different YAML structure for hierarchical filtering based on ENVSETUP_ENVIRON (#28)

## Bug Fixes

- `read_path()` and `write_path()` will work correctly now even if the path objects exists in other environments (#36)
