$region = "us-east-1"
$snsTopicName = "emailer"
$lambdaIAMRoleName = "emailer-lambda-role"
$policyARN = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
$lambdaFunctionName = "dailyEmail"

$zipFileName = "emailer.zip"

$snsTopicArn = New-SNSTopic -Name $snsTopicName -Region $region
Write-Host("SNS Topic ARN: " + $snsTopicArn)

$rolePolicy = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
"@

try
{
  New-IamRole -RoleName $lambdaIAMRoleName -AssumeRolePolicyDocument $rolePolicy -Region $region
} catch
{
  Write-Host("Role already exists")
}

$roleArn = (Get-IAMRole -RoleName $lambdaIAMRoleName -Region $region).Arn

Write-Host("IAM Role ARN: " + $roleArn)

Write-Host("Attaching policy to role")
Register-IAMRolePolicy -RoleName $lambdaIAMRoleName -PolicyArn $policyARN -Region $region
Write-Host("Policy attached to role")


$lambdaFunctionCode = @"
param (
    [Amazon.Lambda.Core.ILambdaContext] \$context
)

Import-Module AWSPowerShell.NetCore

\$snsTopicArn = '$snsTopicArn'

\$snsClient = New-SNSClient

\$request = New-Object Amazon.SimpleNotificationService.Model.PublishRequest
\$request.TopicArn = \$snsTopicArn
\$request.Message = 'Hello from Lambda'

\$snsClient.PublishAsync(\$request) | Out-Null
"@

try
{
  Set-Content -Path "./Emailer/Emailer.ps1" -Value $lambdaFunctionCode
  Compress-Archive -Path "./Emailer/Emailer.ps1" -DestinationPath $zipFileName
} catch
{
  Write-Host("File already exists")
}

try
{
  Publish-LMFunction -Code_ZipFile $zipFileName -FunctionName dailyEmail -Region us-east-1 -Handler "./Emailer/Emailer.ps1" -Runtime dotnet8 -Role $roleArn
} catch
{
  Write-Host("Function already exists")
}

Add-LMPermission -FunctionName $lambdaFunctionName -StatementId "AllowSNSPublish" -Action "lambda:InvokeFunction" -Principal "sns.amazonaws.com" -SourceArn $snsTopicArn -Region $region
