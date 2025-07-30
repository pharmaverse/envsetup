# source_warn_conflicts works with one directory in global

    Code
      source_warn_conflicts(dirs)
    Output
      
       The following objects are added to .GlobalEnv:
      
          'my_conflict', 'not_a_conflict_dev'
      

---

    Code
      envsetup_environment$object_metadata$object_name
    Output
      [1] "my_conflict"        "not_a_conflict_dev"

# source_warn_conflicts works when adding a second directory with conflicts in global

    Code
      source_warn_conflicts(dirs[[2]])
    Output
      
       The following objects are added to .GlobalEnv:
      
          'my_conflict', 'not_a_conflict_qa'
      
       The following objects were overwritten in .GlobalEnv:
      
          'my_conflict'
      

