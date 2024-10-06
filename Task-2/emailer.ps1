$region = "us-east-1"
$snsTopicName = "emailer"
$emailAddress = "filipbozovic998@gmail.com"

$snsTopic = New-SNSTopic -Name $snsTopicName -Region $region
$snsTopic
