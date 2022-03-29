$proxy='http://webproxystatic-ab.tsl.telus.com:8080'
[Environment]::SetEnvironmentVariable("http_proxy",$proxy,"Machine")
[Environment]::SetEnvironmentVariable("https_proxy",$proxy,"Machine")