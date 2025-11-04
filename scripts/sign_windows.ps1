param(
  [Parameter(Mandatory=$true)][string]$PfxPath,
  [Parameter(Mandatory=$true)][string]$PfxPassword,
  [Parameter(Mandatory=$true)][string]$BinaryPath
)

& signtool sign /f $PfxPath /p $PfxPassword /tr http://timestamp.digicert.com /td sha256 /fd sha256 $BinaryPath

