# Appsettings.FromEnv - _V_

App to turn environment variables into a appsettings.json file

## Use case

Let's say you have a CRON job or a desktop application that requires secrets you don't want to commit to source control.  
If you are deploying your app manually, there is no problem. You can just write your secrets in a `secrets.json` or `appsettings.local.json` locally.  
But what if you want to use an automated CI/CD?  
This app turns the environment variables you supply to the automated build and turn them into a JSON file your app can use in the build/publish stage.

## Example

### Supplied environment variables

```shell
ConnectionString=mariadb://root:1234@localhost:3306/my_schema
OpenId__ClientId=my_secret_client_id
OpenId__ClientSecret=1234567890
```

### Run before build/publish

```shell
fromenv --vars ConnectionString OpenId__ClientSecret OpenId__ClientId
```

### Resulting appsettings.local.json

```json
{
	"OpenId": {
		"ClientId": "my_secret_client_id",
		"ClientSecret": "1234567890"
	},
	"ConnectionString": "mariadb://root:1234@localhost:3306/my_schema"
}
```
