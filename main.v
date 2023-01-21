module main

import os

fn main() {
	mut reading_output := false
	mut output := 'appsettings.local.json'

	env_vars := os.environ()

	mut reading_vars := false
	mut vars := map[string]string{}

	for arg in os.args {
		if arg == '--vars' {
			reading_vars = true
			reading_output = false
			continue
		} else if arg == '--output' {
			reading_output = true
			reading_vars = false
			continue
		}

		if reading_vars {
			val := env_vars[arg] or {
				error("Tried to find environment variable '${arg}', but no such variable was found")
				continue
			}
			vars[arg] = val
		} else if reading_output {
			output = arg
		}
	}

	println('Writing to ${output}: ${vars}')

	parts := output.split(os.path_separator)
	dir := parts[0..parts.len - 1].join(os.path_separator)

	if dir != "" && !os.exists(dir) {
		os.mkdir(dir)!
	}
	os.write_file(output, '${vars}')!

	println('Application executed successfully')
}
