module main

import os
import regex
import math

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

	vars["Logging__LogLevel__Default"] = "Information"
	vars["Logging__LogLevel__Test"] = "Warning"
	vars["SmtpUrl"] = "test"

	mut res := '{'
	mut written2 := []string{}
	mut re := regex.regex_opt(r'(__)|(:)')!
	mut base := ''
	for key, value in vars {
		key_parts := re.split(key).filter(it.trim_space() != '')
		for i, part in key_parts {
			base += part + "__"

			curr_parts := base.split('__')
			prev_parts := if written2.len > 0 { written2[written2.len - 1].split('__') } else { []string{} }

			max := math.max(curr_parts.len, prev_parts.len) - 1
			mut diff := 0
			for j in 0..max {
				if j < curr_parts.len - 1 && j < prev_parts.len - 1 && curr_parts[j] == prev_parts[j] {
					diff += 0
				} else if curr_parts.len < prev_parts.len {
					diff += 1
				} else {
					diff -= 1
				}
			}

			if written2.len > 0 {
				// println("Prev: ${written2[written2.len - 1]}\nCurr: ${base}\nDiff: ${diff}\n")
			}
			if diff > 0 { // Ascend
				for j in 0..diff {
					res += '\n' + '\t'.repeat(diff - j) + '}'
				}
			} else if diff < 0 { // Descend
				res += '\n' + '\t'.repeat(i + 1) + '"${part}": '
				written2 << base
			} else { // Same level
				res += ','
			}

			if i == key_parts.len - 1 { // Write value of env var at last level
				if value == "null" {
					res += 'null'
				} else {
					res += '"${value}"'
				}
			} else { // More objects to write
				res += '{'
			}
		}
		base = ''
	}

	res = res.substr(0, res.len - 1) + "\n}"
	println('Writing to ${output}:\n${res}')
	os.write_file(output, res.replace('\\', '\\\\'))!

	println('Application executed successfully ^^')
}
