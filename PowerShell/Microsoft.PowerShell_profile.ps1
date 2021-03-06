# Command to push to a new upstream branch
function Push-Upstream
{
    $remote = Invoke-Expression 'git remote'

    if ($remote)
    {
        $branch = Invoke-Expression 'git rev-parse --abbrev-ref HEAD'

        if ($branch)
        {
            $expression = 'git push --set-upstream ' + $remote + ' ' + $branch
            Write-Host $expression
            Invoke-Expression $expression
        }
    }
}

# Command to open the git remote in an internet browser
function Browse-Remote 
{
    $remote = Invoke-Expression 'git remote get-url origin'
    $remote = $remote.Replace('.git', '')

    if ($remote)
    {
        $expression = $remote
        $branch = Invoke-Expression 'git rev-parse --abbrev-ref HEAD'

        if ($branch)
        {
            # Visual Studio Team Services (VSTS) & Team Foundation Server (TFS)
            if ($remote -like '*visualstudio.com*' -or $remote -like '*tfs*' -or $remote -like '*DefaultCollection*')
            {
                $expression = $remote + "?version=GB" + $branch
            }

            # GitHub.com
            if ($remote -like '*github*')
            {
                $expression = $remote + "/tree/" + $branch
            }
        }

        Write-Host $expression
        Start-Process $expression
    }
}

function Push-Upstream-And-Browse-Remote
{
    Push-Upstream
    Browse-Remote
}

function Find-File-Upwards($fileName, $startPath)
{
	$path = $startPath
	while($path -and !(Test-Path (Join-Path $path $fileName)))
	{
		$path = Split-Path $path -Parent
	}
	
	if ([string]::IsNullOrEmpty($path))
	{
		return ''
	}

	return (Join-Path $path $fileName)
}

# Command to invoke a Cake command with a given target
function Invoke-Cake($target)
{
	$fileName = "build.ps1"
	$path = (Get-Location).Path
	$cakeFile = Find-File-Upwards $fileName $path
		
	if ([string]::IsNullOrEmpty($cakeFile))
	{
		Write-Output ("File '$fileName' not found going upwards from '$path'")
	}
	else
	{
        $cakeDir = [System.IO.Path]::GetDirectoryName($cakeFile)

        Push-Location $cakeDir
		Invoke-Expression "$cakeFile -Target $target"
        Pop-Location
	}
}

Set-Alias -Name pu -Value Push-Upstream
Set-Alias -Name br -Value Browse-Remote
Set-Alias -Name pubr -Value Push-Upstream-And-Browse-Remote

Set-Alias -Name cake -Value Invoke-Cake