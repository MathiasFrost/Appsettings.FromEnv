module tests

import os

fn test_should_generate_appsettings() {
	os.setenv('Identity__ClientId', 'my_secret_client_id', true)
	os.setenv('Identity__ClientSecret', '1234567890', true)
	os.setenv('ConnectionString', '69310+498120394809', true)
	os.setenv('AFB__Fileshare__APIKey', '1234', true)

	os.execute('bin\\main.exe --vars AFB__Fileshare__APIKey Identity__ClientId Identity__ClientSecret ConnectionString --output out\\appsettings.local.json --file null')
	content := os.read_file('out\\appsettings.local.json')!
	assert content == '{
	"Identity": {
		"ClientId": "my_secret_client_id",
		"ClientSecret": "1234567890"
	},
	"AFB": {
		"Fileshare": {
			"APIKey": "1234"
		}
	}
	"ConnectionString": "69310+498120394809"
}'.replace('\n',
		'\r\n') // Not sure how to handle different newlines
}
