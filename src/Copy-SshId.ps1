function Copy-SshId {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Server,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $PubKeyPath,

        [Parameter()]
        [int]
        $Port = 22,

        [Parameter()]
        [string]
        $User
    )

    $remoteScript = @'
    $pubKey = Read-Host; `
    $authorizedKeysPath = Join-Path $HOME .ssh/authorized_keys; `
    if (!(Test-Path $authorizedKeysPath)) { `
        New-Item $authorizedKeysPath -ItemType File; `
    } `

    $existingKeys = Get-Content $authorizedKeysPath; `
    if ($existingKeys -notcontains $pubKey) { `
        Set-Content -Value ($existingKeys + $pubKey) -Path $authorizedKeysPath; `
    }
'@

    $effectiveHost = $User ? "$User@$Server" : $Server;
    Get-Content -Path $PubKeyPath | ssh -p $Port $effectiveHost "$remoteScript";
}
