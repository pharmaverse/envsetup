test_envre <- list()

test_envre$PDEV <- get_path(
  topdrv, "PDEV", username, compound, protocol, dbrelease, rpteff, "analysis"
)

test_envre$PREPROD <- get_path(
  topdrv, "PREPROD", NA, compound, protocol, dbrelease, rpteff, "analysis"
)

test_envre$PROD <- get_path(
  topdrv, "PROD", NA, compound, protocol, dbrelease, rpteff, "analysis"
)

envre_loc <- "pdev"
