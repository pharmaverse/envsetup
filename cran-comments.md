## Resubmission
This is a resubmission.  In this version I have:

* Corrected quotations in the description.
* Removed the LICENSE file, as there are no additional restrictions.
* Removed the default write path in R/init.R.

## envsetup 0.1.0

Tested on RHEL 7, RHEL 8, GitHub Action and RHub.

Two notes found:

Possibly misspelled words in DESCRIPTION:
  Workflows (3:21)

Found the following calls to attach():
File ‘envsetup/R/autos.R’:
  attach(NULL, name = name_with_prefix)
  attach(NULL, name = name_with_prefix)
File ‘envsetup/R/rprofile.R’:
  attach(config_minus_autos$paths, name = "envsetup:paths", pos = pos)
See section ‘Good practice’ in ‘?attach’.

Our use of attach within this package is explicit and intentional, as we are essentially introducing shims. The intention of autos.R and rprofile.R are to attach objects to the search path based on a configuration file. This configuration file is to be explicitly configured by a user, and the resulting behaivior is to be tested by the user, for which `vignette("config")` provides guidance. The purpose of this is to allow a consistent, automatic set of objects to be made available across a potentially large number of projects. The name argument is distinct for both attached paths, named as envsetup:paths, and autos are always prefixed with "autos:"; for example autos:my_functions.
