module main

import os

fn main() {
	mut reading_output := false
	mut output := '.'

	env_vars := os.environ()

	mut reading_vars := false
	mut vars := map[string]string{}

	for arg in os.args {
		if reading_vars {
			val := env_vars[arg] or {
				"Tried to find environment variable '${arg}', but no such variable was found"
			}
			vars[arg] = val
		} else if reading_output {
			output = arg
		}

		if arg == '--vars' {
			reading_vars = true
		} else if arg == '--output' {
			reading_output = true
		}
	}

	println('Writing to ${output}: ${vars}')
	os.write_file(output, "$vars") or {
		'Could not write file to ${output}'
	}
}
