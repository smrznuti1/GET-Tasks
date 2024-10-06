param (
    [Amazon.Lambda.Core.ILambdaContext] \
)

Import-Module AWSPowerShell.NetCore

\arn:aws:sns:us-east-1:225989340442:emailer = 'arn:aws:sns:us-east-1:225989340442:emailer'

\ = New-SNSClient

\ = New-Object Amazon.SimpleNotificationService.Model.PublishRequest
\.TopicArn = \arn:aws:sns:us-east-1:225989340442:emailer
\.Message = 'Hello from Lambda'

\.PublishAsync(\) | Out-Null
