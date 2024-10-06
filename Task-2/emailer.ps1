$region = "us-east-1"
$snsTopicName = "emailer"
$lambdaIAMRoleName = "emailer-lambda-role"
$policyARN = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
$lambdaFunctionName = "dailyEmail"

$snsTopic = New-SNSTopic -Name $snsTopicName -Region $region
Write-Host("SNS Topic ARN: " + $snsTopic)

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

$roleArn = New-IamRole -RoleName $lambdaIAMRoleName -AssumeRolePolicyDocument $rolePolicy -Region $region
Write-Host("IAM Role ARN: " + $roleArn)

Write-Host("Attaching policy to role")
Register-IAMRolePolicy -RoleName $lambdaIAMRoleName -PolicyArn $policyARN -Region $region
Write-Host("Policy attached to role")


