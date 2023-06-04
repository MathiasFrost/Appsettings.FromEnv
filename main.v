module main

import os
import regex

enum Parameter {
	pending
	help
	vars
	file
	output
}

fn main() {
	env_vars := os.environ()
	mut parse_all := false
	mut output := 'appsettings.local.json'
	mut vars := map[string]string{}
	mut rc_path := '.fromenvrc'

	mut parameter := Parameter.pending
	for arg in os.args {
		if arg == '--help' {
			println('Appsettings.FromEnv

Parameter          Description                                                                      Example                                          Default
--vars             Specify environment variables to search for.                                     fromenv --vars ConnectionString ClientSecret
--file             Specify file containing new-line-separated environment variables to search for.  fromenv --file ../.fromenvrc                     ${rc_path}
--output           Specify output file.                                                             fromenv --output out/appsettings.local.json      ${output}
--all              If we should parse ALL environment variables that exists.                        fromenv --all                                    ${parse_all}
')
			return
		}
		if arg == '--vars' {
			parameter = Parameter.vars
			continue
		} else if arg == '--output' {
			parameter = Parameter.output
			continue
		} else if arg == '--file' {
			parameter = Parameter.file
			continue
		} else if arg == '--all' {
			parse_all = true
		}

		if parameter == Parameter.vars {
			vars[arg] = env_vars[arg] or { 'null' }
		} else if parameter == Parameter.output {
			output = arg
		} else if parameter == Parameter.file {
			rc_path = arg
		}
	}

	if parse_all {
		for key, value in env_vars {
			vars[key] = value
			println(key)
		}
	}

	// Parse .fromenvrc
	if os.exists(rc_path) {
		rc_vars := os.read_file(rc_path)!.replace('\r\n', '\n').split('\n')
		for var in rc_vars {
			vars[var] = env_vars[var] or { 'null' }
		}
	}

	parts := output.split(os.path_separator)
	dir := parts[0..parts.len - 1].join(os.path_separator)

	if dir != '' && !os.exists(dir) {
		os.mkdir(dir)!
	}

	mut res := ''
	mut written := []string{}
	mut re := regex.regex_opt(r'(__)|(:)')?
	mut base := ''
	for key, value in vars {
		key_parts := re.split(key).filter(it.trim_space() != '')
		for i, part in key_parts {
			base += part
			if base in written {
			} else {
				res += '{\n' + '\t'.repeat(i + 1) + '"${part}": '
			}
			if i == key_parts.len - 1 {
				res += '"${value}"'
			}
			written << base
		}

		for i, _ in key_parts {
			if i == 0 {
				continue
			}
			res += '\n' + '\t'.repeat(key_parts.len - i) + '}'
		}

		base = ''
	}

	println(res + '\n}')

	println('Writing to ${output}:\n${res}')
	os.write_file(output, res.replace('\\', '\\\\'))!

	println('Application executed successfully ^^')
}
