# envsetup 0.0.1

## New Features

- `init()` added to assist with setting up a project to use envsetup (#21)
- `rprofile()` will automatically store your configuration file in a standard location with a standard name, allowing `library()` to use this to re-assign autos

## Breaking Changes

- `library()` will now respect invisible return instead of always returning the list of attached packages (#24)
- `set_autos()` now expects a different YAML structure for hierarchical filtering based on ENVSETUP_ENVIRON (#28)
