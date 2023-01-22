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

	parts := output.split(os.path_separator)
	dir := parts[0..parts.len - 1].join(os.path_separator)

	if dir != '' && !os.exists(dir) {
		os.mkdir(dir)!
	}

	mut res := '{'
	mut parents := []string{}
	for key, value in vars {
		key_parts := key.split('__')

		// Ascend if necessary
		mut ascended := false
		for {
			if key_parts.len <= parents.len {
				parents.pop()
				ascended = true
			} else {
				break
			}
		}

		// Descend if necessary
		mut descended := false
		for part in key_parts {
			if key_parts.len - 1 > parents.len {
				parents << part
				res += '\n' + '\t'.repeat(parents.len) + '"${part}": {'
				descended = true
			} else {
				break
			}
		}

		if !descended && !ascended {
			res += ','
		} else if ascended {
			res += '\n' + '\t'.repeat(1 + parents.len) + '},'
		}
		res += '\n' + '\t'.repeat(1 + parents.len) + '"${key_parts.last()}": "${value}"'
	}
	res += '\n}'

	println('Writing to ${output}:\n${res}')
	os.write_file(output, res)!

	println('Application executed successfully')
}
