module tests

import os

env_vars = {
	'Identity__ClientId':     'my_secret_client_id'
	'Identity__ClientSecret': '1234567890'
	'ConnectionString':       '69310+498120394809'
}

fn test_should_generate_appsettings() {
	os.execute('bin/main.exe --vars Identity__ClientId Identity__ClientSecret ConnectionString')
	os.read_file("output")
	assert 'test' == 'test'
}
