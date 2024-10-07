#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.1.671'}
#Requires -Modules @{ModuleName='AWS.Tools.S3';ModuleVersion='4.1.671'}
#Requires -Modules @{ModuleName='AWS.Tools.SimpleNotificationService';ModuleVersion='4.1.671'}

Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

Publish-SNSMessage -TopicArn arn:aws:sns:us-east-1:225989340442:emailer -Message "Hello, World!"
