module tests

import os

fn test_should_generate_appsettings() {
	os.setenv('Identity__ClientId', 'my_secret_client_id', true)
	os.setenv('Identity__ClientSecret', '1234567890', true)
	os.setenv('ConnectionString', '69310+498120394809', true)

	os.execute('bin\\main.exe --vars Identity__ClientId Identity__ClientSecret ConnectionString --output out\\appsettings.local.json')
	content := os.read_file('out\\appsettings.local.json')!
	assert content == "{'Identity__ClientId': 'my_secret_client_id', 'Identity__ClientSecret': '1234567890', 'ConnectionString': '69310+498120394809'}"
}
