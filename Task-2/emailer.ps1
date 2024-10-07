$region = "us-east-1"
$snsTopicName = "emailer"
$lambdaIAMRoleName = "emailer-lambda-role"
$policyARN = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
$lambdaFunctionName = "dailyEmail"
$mailTriggerRuleName = "dailyEmailRule"
$scriptPath = "lambdaCode.ps1"


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
`#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.1.671'}
`#Requires -Modules @{ModuleName='AWS.Tools.S3';ModuleVersion='4.1.671'}
`#Requires -Modules @{ModuleName='AWS.Tools.SimpleNotificationService';ModuleVersion='4.1.671'}

Write-Host (ConvertTo-Json -InputObject `$LambdaInput -Compress -Depth 5)

Publish-SNSMessage -TopicArn $snsTopicArn -Message "Hello, World!"
"@

try
{
  Set-Content -Path $scriptPath -Value $lambdaFunctionCode
} catch
{
  Write-Host("File already exists")
}

Publish-AWSPowerShellLambda -ScriptPath $scriptPath -Name $lambdaFunctionName -Region $region -IAMRoleArn $roleArn

try
{
  #Add-LMPermission -FunctionName $lambdaFunctionName -StatementId "AllowSNSPublish" -Action "lambda:InvokeFunction" -Principal "sns.amazonaws.com" -SourceArn $snsTopicArn -Region $region
} catch
{
  Write-Host("Permission already exists")
}

$ruleArn = Write-EVBRule -Name $mailTriggerRuleName -ScheduleExpression "cron(0 1 * * ? *)" -Region $region
Write-Host("Rule ARN: " + $ruleArn)

$target = New-Object Amazon.EventBridge.Model.Target
$target.Id = $lambdaFunctionName
$target.Arn = (Get-LMFunction -FunctionName $lambdaFunctionName -Region $region).Configuration.FunctionArn


Write-EVBTarget -Rule $mailTriggerRuleName -Target $target -Region $region

try
{
  Add-LMPermission -FunctionName $lambdaFunctionName -StatementId "AllowEventRule" -Action "lambda:InvokeFunction" -Principal "events.amazonaws.com" -SourceArn $ruleArn -Region $region
} catch
{
  Write-Host("Permission already exists")
}
