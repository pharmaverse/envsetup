# init creates a .Rprofile

    Code
      init(init_tmpdir, config_path, create_paths = FALSE)
    Message <rlang_message>
      v Configuration file found!
      i The following paths in your configuration do not exist:
        /DEV/username/project1/data
        /PROD/project1/data
        /DEV/username/project1/programs
        /PROD/project1/programs
        /DEV/username/project1/functions
        /PROD/project1/functions
        /DEV/username/project1/output
        /PROD/project1/output
      i All path objects will not work since directories are missing.
      v envsetup initialization complete

# init initializes an .Rprofile correcty when one does not exist

    Code
      init(init_tmpdir, config_path, create_paths = FALSE)
    Message <rlang_message>
      v Configuration file found!
      i The following paths in your configuration do not exist:
        /DEV/username/project1/data
        /PROD/project1/data
        /DEV/username/project1/programs
        /PROD/project1/programs
        /DEV/username/project1/functions
        /PROD/project1/functions
        /DEV/username/project1/output
        /PROD/project1/output
      i All path objects will not work since directories are missing.
      v envsetup initialization complete

# init initializes an .Rprofile correcty when one does exist

    Code
      init(init_tmpdir, config_path, create_paths = FALSE)
    Message <rlang_message>
      v Configuration file found!
      i The following paths in your configuration do not exist:
        /DEV/username/project1/data
        /PROD/project1/data
        /DEV/username/project1/programs
        /PROD/project1/programs
        /DEV/username/project1/functions
        /PROD/project1/functions
        /DEV/username/project1/output
        /PROD/project1/output
      i All path objects will not work since directories are missing.
      v .Rprofile created
      v envsetup initialization complete

