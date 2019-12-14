# Install specified Python version.
# Install only if:
#    Our current matrix entry uses this Python version AND
#    Python version is not already available.

$py_exe = "${env:PYTHON}\Python.exe"
if ( [System.IO.File]::Exists($py_exe) ) {
    echo "$py_exe exists"
    exit 0
}
$req_nodot = $env:PYTHON -replace '\D+Python(\d+(?:rc\d+)?)(-x64)?','$1'
$req_ver = $req_nodot -replace '(\d)(\d+)','$1.$2.0'
$req_dir = $req_nodot -replace '(\d)(\d+)(.*)','$1.$2.0'
$last_three = $env:PYTHON[-3 .. -1] -join ''

if ($last_three -eq "x64") {
    $exe_suffix="-amd64"
} else {
    $exe_suffix=""
}

$py_url = "https://www.python.org/ftp/python"
Write-Host "Installing Python ${req_dir}/${req_ver}$exe_suffix to $env:Python ..." -ForegroundColor Cyan
$exePath = "$env:TEMP\python-${req_ver}${exe_suffix}.exe"
$downloadFile = "$py_url/${req_dir}/python-${req_ver}${exe_suffix}.exe"

Write-Host "Downloading $downloadFile..."
(New-Object Net.WebClient).DownloadFile($downloadFile, $exePath)
Write-Host "Installing..."
cmd /c start /wait $exePath /quiet TargetDir="$env:PYTHON" Shortcuts=0 Include_launcher=0 InstallLauncherAllUsers=0
Write-Host "Python ${req_ver} installed to $env:PYTHON"

echo "$(& $py_exe --version 2> $null)"
