function Install-SplunkUF {
    param
    (
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_USERNAME,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_PASSWORD,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_PASS4SYMMKEY,
        [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$UF_GROUP
    )

    # Sleep to allow other extensions MSI interactions to complete
    Start-Sleep -s 60

    # Setup
    $installerURI = 'https://download.splunk.com/products/universalforwarder/releases/8.2.4/windows/splunkforwarder-8.2.4-87e2dda940d1-x64-release.msi'
    $installerFile = $env:Temp + "\splunkforwarder-8.2.4-87e2dda940d1-x64-release.msi"
    $indexServer = 'splunk-cm-prod-vm00.platform.hmcts.net:8089'
    $deploymentServer = 'splunk-lm-prod-vm00.platform.hmcts.net:8089'

    # Downloading & Installing Splunk Universal Forwarder
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Splunk Universal Forwarder installer."
    (New-Object System.Net.WebClient).DownloadFile($installerURI, $installerFile)
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Splunk Universal Forwarder."
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $installerFile DEPLOYMENT_SERVER=$deploymentServer RECEIVING_INDEXER=$indexServer WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=0 WINEVENTLOG_APP_ENABLE=0 WINEVENTLOG_FWD_ENABLE=0 WINEVENTLOG_SET_ENABLE=1 AGREETOLICENSE=Yes SERVICESTARTTYPE=AUTO LAUNCHSPLUNK=1 SPLUNKUSERNAME=$UF_USERNAME SPLUNKPASSWORD=$UF_PASSWORD /quiet" -Wait

    # Installation verification
    $splunk = Get-Process -Name "splunkd" -ErrorAction SilentlyContinue
    if ($null -ne $splunk) {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk Universal Forwarder has been installed successfully."
    }
    else {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk Universal Forwarder installation failed."
        exit 1
    }
}

if ( "${UF_INSTALL}" -eq "true" ) {
    Install-SplunkUF -UF_USERNAME "${UF_USERNAME}" -UF_PASSWORD "${UF_PASSWORD}" -UF_PASS4SYMMKEY "${UF_PASS4SYMMKEY}" -UF_GROUP "${UF_GROUP}"
}
