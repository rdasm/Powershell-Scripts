#usage: .\VerifyCertificate.ps1 <URL without the https>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$url = "https://$args"
$req = [Net.HttpWebRequest]::Create($url)
$req.getresponse()
$cert = $req.servicepoint.certificate
$bytes = $cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)
set-content -value $bytes -encoding byte -path "$pwd\$args.cer"
certutil -verify "$pwd\$args.cer"