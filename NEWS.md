# envsetup 0.0.1

## New Features

- `init()` added to assist with setting up a project to use envsetup (#20, #21, #31)
- `build_from_config()` added to add ability to also use config to create your directories (#25)
- `validate_config()` added to assist with creating configuration files (#23)
- `rprofile()` will automatically store your configuration file in a standard location with a standard name, allowing `library()` to use this to re-assign autos

## Breaking Changes

- `library()` will now respect invisible return instead of always returning the list of attached packages (#24)
