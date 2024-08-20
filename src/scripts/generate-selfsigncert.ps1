# windows example to create self sign certificate for vpn
$rootName="p2srootcertv8"
$clientName="p2sclientcertv8"

# root
$params = @{
    Type = 'Custom'
    Subject = "CN=$($rootName)"
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyUsage = 'CertSign'
    KeyUsageProperty = 'Sign'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddMonths(24)
    CertStoreLocation = 'Cert:\CurrentUser\My'
}
$cert = New-SelfSignedCertificate @params

# Client
$params = @{
    Type = 'Custom'
    Subject = "CN=$($clientName)"
    DnsName = $clientName
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddMonths(18)
    CertStoreLocation = 'Cert:\CurrentUser\My'
    Signer = $cert
    TextExtension = @(
    '2.5.29.37={text}1.3.6.1.5.5.7.3.2')
}
New-SelfSignedCertificate @params
