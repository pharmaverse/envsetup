my_conflict <- function(){
  print("This is a function that makes a conflict.  It is in PROD.")
}

not_a_conflict_prod <- function(){
  print("This function does not cause a conflict.  It is in PROD.")
}
