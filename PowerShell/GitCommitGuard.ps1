# Pre-commit hook: Remove lines containing a marker from staged files.

$ErrorActionPreference = "Stop"
$exitCode = 0

# Retrieve the list of staged files.
$stagedFiles = git diff --cached --name-only

foreach ($file in $stagedFiles) {
    # Only process if the file exists in the working directory.
    if (Test-Path $file) {
        # Get the staged content of the file.
        $stagedContent = git show ":$file"
        if ($stagedContent -match "git:nocommit") {
            Write-Host "Pre-commit hook: Removing 'git:nocommit' lines from staged version of $file"

            # Create temporary files.
            $stagedTemp = New-TemporaryFile
            $filteredTemp = New-TemporaryFile

            # Write the staged content to the temporary file.
            $stagedContent | Set-Content -Path $stagedTemp -Encoding UTF8

            # Filter out lines that contain "git:local" and write to the filtered temp file.
            Get-Content -Path $stagedTemp | Where-Object { $_ -notmatch "git:nocommit" } | Set-Content -Path $filteredTemp -Encoding UTF8

            # Compute the blob hash for the filtered file.
            $blobHash = git hash-object -w $filteredTemp

            # Retrieve the file mode from the index.
            $fileMode = git ls-files --stage $file | ForEach-Object { $_.Split()[0] }
            if (-not $fileMode) {
                $fileMode = "100644"
            }

            # Update the index with the filtered version.
            git update-index --cacheinfo $fileMode $blobHash $file

            # Clean up temporary files.
            Remove-Item $stagedTemp, $filteredTemp
        }
    }
}

exit $exitCode
