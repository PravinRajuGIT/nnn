
param (
    [string]$CertificateNamePrefix,
    [int]$ExpiryInDays
)

$unsecurePassword = Read-Host "Enter password for certificate" -AsSecureString

$certFileName = "$CertificateNamePrefix-cert.pem"
$certPrivateKeyFileName = "$CertificateNamePrefix-key.pem"
$certPackFileName = "$CertificateNamePrefix-pack.pfx"
$certPemWithBagAttributesFileName = "$CertificateNamePrefix-PemWithBagAttributes.pem"

# generate cert.pem to be uploaded for spn
openssl req -x509 -days $ExpiryInDays -newkey rsa:2048 -keyout $certPrivateKeyFileName -out $certFileName
Read-Host “Check that $certFileName and $certPrivateKeyFileName are generated. Then press ENTER to continue...”

# generate pack to put private key and cert (public key) together
openssl pkcs12 -inkey $certPrivateKeyFileName -in $certFileName -export -out $certPackFileName -passout "pass:$unsecurePassword"
Read-Host “Check that $certPackFileName is generated. Then press ENTER to continue...”

# generate merged pem for pasting into Azure DevOps servce connection configuraiton
openssl pkcs12 -in $certPackFileName -passin "pass:$unsecurePassword"  -out $certPemWithBagAttributesFileName -nodes

Write-Host "Upload $certFileName to Azure Service principal."
Write-Host "Copy and paste content of $certPemWithBagAttributesFileName in Azure DevOps service connection certificate textbox."