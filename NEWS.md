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
