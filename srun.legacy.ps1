# Encoding needs to comply with your Windows system, when using non-ASCII characters.
# For example, use GBK for Windoiws Simplified Chinese Edition
$MY_NET_INTERFACE = '以太网'

$MY_IP = (Get-NetIPAddress -InterfaceAlias $MY_NET_INTERFACE -AddressFamily IPv4).IPAddress

# Use baidu.com which has no IPv6 address, since IPv6 ping is always okay here
# PowerShell 7 supports IPv4 or IPv6 by passing certain parameter, but PowerShell 5.1 doesn't.
if (Test-Connection baidu.com -Source $MY_IP -Count 1) {  # ping "www.gstatic.com" -S $MY_IP -n 1
    Write-Host "INFO`: Internet connection is OK."
    exit 0
}
else {
    Write-Host "INFO`: Internet connection is down, need login."
}

$AUTH_USERNAME = "useername"
$AUTH_PASSWORD = "password"

$API_ENDPOINT = "http://192.168.2.231/srun_portal_pc.php?ac_id=1`&"

$params = @{
    ac_id      = "1"
    action     = "login"
    user_ip    = $MY_IP
    nas_ip     = ""
    user_mac   = ""
    url        = ""
    username   = $AUTH_USERNAME
    password   = $AUTH_PASSWORD
}

$userAgent = "Mozilla/5.0 `(Windows NT 10.0; WOW64; Trident/7.0; rv:11.0`) like Gecko"

Invoke-WebRequest -Uri $API_ENDPOINT -Method POST -Body $params -UserAgent $userAgent -UseBasicParsing
