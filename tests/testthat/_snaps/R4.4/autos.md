# Autos warns user when ENVSETUP_ENVIRON does not match named environments in autos

    Code
      suppressMessages(rprofile(custom_name))
    Condition
      Warning:
      The projects autos has named environments DEV, QA, PROD that do not match with the envsetup_environ parameter or ENVSETUP_ENVIRON environment variable bad_name
    Output
      
       The following objects are added to .GlobalEnv:
      
          'test_dev'
      
      
       The following objects are added to .GlobalEnv:
      
          'my_conflict', 'not_a_conflict_dev'
      
      
       The following objects are added to .GlobalEnv:
      
          'inc3'
      
      
       The following objects are added to .GlobalEnv:
      
          'inc2'
      
      
       The following objects are added to .GlobalEnv:
      
          'inc1'
      
      
       The following objects are added to .GlobalEnv:
      
          'mtcars', 'paste', 'test_qa'
      
      
       The following objects are added to .GlobalEnv:
      
          'not_a_conflict_qa'
      
       The following objects were not added to .GlobalEnv as they already exist:
      
          'my_conflict'
      
      
       The following objects were not added to .GlobalEnv as they already exist:
      
          'inc1'
      
      
       The following objects were not added to .GlobalEnv as they already exist:
      
          'inc2'
      
      
       The following objects were not added to .GlobalEnv as they already exist:
      
          'inc3'
      
      
       The following objects are added to .GlobalEnv:
      
          'not_a_conflict_prod'
      
       The following objects were not added to .GlobalEnv as they already exist:
      
          'my_conflict'
      
      
       The following objects are added to .GlobalEnv:
      
          'atest'
      
      
       The following objects are added to .GlobalEnv:
      
          'test_prod'
      
      
       The following objects are added to .GlobalEnv:
      
          'test_prod2'
      
      
       The following objects are added to .GlobalEnv:
      
          'test_global'
      
      
       The following objects were not added to .GlobalEnv as they already exist:
      
          'atest'
      

