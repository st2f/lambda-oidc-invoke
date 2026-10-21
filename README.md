# lambda-oidc-invoke

A small learning project for invoking an AWS Lambda directly from GitHub Actions using OIDC.

A dummy Lambda echoes its JSON input with an `ok: true` result. Terraform manages the function, its execution role, and a CloudWatch log group with seven-day retention. No triggers are configured.

The existing `github-ci-role` receives an inline policy granting `lambda:InvokeFunction` on this function's exact ARN. Terraform looks up the role without managing its trust policy or other permissions.

Example response for the payload `{"hello":"github"}`:

```json
{ "ok": true, "payload": { "hello": "github" } }
```

Configure AWS CLI credentials and set `allowed_account_ids` in `terraform/main.tf` to the target account ID. The GitHub OIDC role must already exist; its name is configured in `terraform/github.tf`. Initialize, validate, and preview the infrastructure:

```sh
terraform -chdir=terraform init
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

Deploy:

```sh
terraform -chdir=terraform apply
```

Invoke the function using an AWS identity with `lambda:InvokeFunction` permission:

```sh
aws lambda invoke \
  --region eu-north-1 \
  --function-name "$(terraform -chdir=terraform output -raw function_name)" \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{"hello":"github"}' \
  /tmp/lambda-oidc-invoke-response.json
cat /tmp/lambda-oidc-invoke-response.json
```

Successful execution returns `StatusCode: 200`, no `FunctionError`, and the JSON response shown above. A successful API request alone does not indicate that the handler succeeded.
