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
			if var.trim_space() == "" {
				continue
			}
			vars[var.trim_space()] = env_vars[var] or { 'null' }
		}
	}

	parts := output.split(os.path_separator)
	dir := parts[0..parts.len - 1].join(os.path_separator)

	if dir != '' && !os.exists(dir) {
		os.mkdir(dir)!
	}

	vars["Logging__LogLevel__Default"] = "Information"
	vars["Logging__LogLevel__Test"] = "Warning"
	vars["SmtpUrl"] = "test"

	mut re := regex.regex_opt(r'(__)|(:)')!
	mut res := '{'
	mut prev_parts := []string{}
	mut i := 0
	for key, value in vars {
		if i != 0 { res += ',' } // All values are separated by ',' (except first)
		curr_parts := re.split(key).filter(it.trim_space() != '')

		// Descend if multiple parts
		mut diff_parent := false
		for j, part in curr_parts {
			if !diff_parent && j < prev_parts.len - 1 && part == prev_parts[j] {
				continue
			}
			diff_parent = true
			res += '\n' + '\t'.repeat(j + 1) + '"${part}": '
			if j < curr_parts.len - 1 {
				res += '{'
			}
		}

		// All values are written once
		if value == 'null' {
			res += 'null'
		} else {
			res += '"${value}"'
		}

		// Ascend if next is not the same
		diff_parent = false
		next_parts := if i < vars.len - 1 { re.split(vars.keys()[i + 1]).filter(it.trim_space() != '') } else { []string{} }
		mut level := curr_parts.len - 1 
		for j in 0..(curr_parts.len - 1) {
			if !diff_parent && j < next_parts.len - 1 && curr_parts[j] == next_parts[j] {
				continue
			}
			diff_parent = true
			res += '\n' + '\t'.repeat(level) + '}'
			level -= 1
		}

		prev_parts = curr_parts.clone()		
		i += 1
	}

	res += "\n}"
	println('Writing to ${output}:\n${res}')
	os.write_file(output, res.replace('\\', '\\\\'))!

	println('Application executed successfully ^^')
}
