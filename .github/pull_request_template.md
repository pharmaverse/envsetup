Thank you for your Pull Request! Completing the below tasks helps to ensure our reviewers can maximize their time on your code as well as making sure the codebase remains robust and consistent.

Please check off each taskbox as an acknowledgment that you completed the task or check off that it is not relevant to your Pull Request. This checklist is part of the Github Action workflows and the Pull Request will not be merged into the `devel` branch until you have checked off each task.

- [ ] Place Closes #<insert_issue_number> into the beginning of your Pull Request Title (Use Edit button in top-right if you need to update)
- [ ] Code is formatted according to the [tidyverse style guide](https://style.tidyverse.org/). Run `styler::style_file()` to style R and Rmd files
- [ ] Updated relevant unit tests or have written new unit tests
- [ ] Update to all relevant roxygen headers and examples.
- [ ] Run `devtools::document()` so all `.Rd` files in the `man` folder and the `NAMESPACE` file in the project root are updated appropriately
- [ ] Address any updates needed for vignettes and/or templates
- [ ] Update `NEWS.md` if the changes pertain to a user-facing function (i.e. it has an `@export` tag) or documentation aimed at users (rather than developers)
- [ ] Build site `pkgdown::build_site()` and check that all affected examples are displayed correctly and that all new functions occur on the reference page.
- [ ] Address or fix all lintr warnings and errors - `lintr::lint_package()`
- [ ] Run `R CMD check` locally and address all errors and warnings - `devtools::check()`
- [ ] Link the issue so that it closes after successful merging.
- [ ] Address all merge conflicts and resolve appropriately.
- [ ] Pat yourself on the back for a job well done! Much love to your accomplishment!
