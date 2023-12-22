# Read Input from prompt
$dirName = Read-Host "Please enter the folder name under the drive root"
$gh_org_username = Read-Host "Please enter the GitHub Organization Username"
$gh_pat = Read-Host "Please enter the GitHub PAT"
$repo_name = Read-Host "Please enter Github repo name"
$runner_name = Read-Host "Please enter github self-hosted runner name"
$label = Read-Host "Please enter the runner label name e.g. label-1,label-2"
$runner_work_folder_name = Read-Host "Please enter the _work folder name (runner default work location)"

# Download Runner

# Create a folder under the drive root
mkdir $dirName; cd $dirName

# Download the latest runner package
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-win-x64-2.311.0.zip -OutFile actions-runner-win-x64-2.311.0.zip

# Extract the installer
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.311.0.zip", "$PWD")

# Configure Runner

# Create the runner and start the configuration experience
& "$PWD\config.cmd" "--url" "https://github.com/$gh_org_username/$repo_name" "--token" $(Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$gh_org_username/$repo_name/actions/runners/registration-token" -Headers @{ "Accept" = "application/json" ; "Authorization" = "Bearer $gh_pat" ;"X-GitHub-Api-Version" = "2022-11-28"}).token "--name" "$runner_name" "--labels" "$label" "--work" "$runner_work_folder_name";

Start-Sleep -Seconds 30

# REST API request to get runner information
$runner_info = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$gh_org_username/$repo_name/actions/runners" -Headers @{ "Authorization" = "Bearer $gh_pat"; "Accept" = "application/vnd.github.v3+json" }

# Extract the runner ID and status
$runner_id = $runner_info.runners | Where-Object { $_.name -eq $runner_name } | Select-Object -ExpandProperty id
$runner_status = $runner_info.runners | Where-Object { $_.name -eq $runner_name } | Select-Object -ExpandProperty status

# Print the runner ID and status
Write-Host "Runner ID: $runner_id"
Write-Host "Runner Status: $runner_status"