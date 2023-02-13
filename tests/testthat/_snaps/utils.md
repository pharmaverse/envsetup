# validate_config, no hierarchy paths return correct messages

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      v paths are specified as part of your configuration
      i no hierarchical paths found

---

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      v paths are specified as part of your configuration
      i no hierarchical paths found

# validate_config, hierarchy paths return correct messages

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      v paths are specified as part of your configuration
      v hierarchal paths found for:
        data
        output
        programs

---

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      v paths are specified as part of your configuration
      v hierarchal paths found for:
        data
        output
        programs

# validate_config, hierarchy paths return todo item/s when unnamed

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      v paths are specified as part of your configuration
      v hierarchal paths found for:
        data
        output
        programs
      * data has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for data.
      * output has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for output.
      * programs has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for programs.

---

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      v paths are specified as part of your configuration
      v hierarchal paths found for:
        data
        output
        programs
      * data has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for data.
      * output has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for output.
      * programs has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for programs.

---

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      v paths are specified as part of your configuration
      v hierarchal paths found for:
        data
        output
        programs
      * data has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for data.
      * output has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for output.
      * programs has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for programs.

# validate_config, no paths return correct message

    Code
      validate_config(config::get(file = path))
    Message <rlang_message>
      i no paths are specified as part of your configuration, skipping path valiation

