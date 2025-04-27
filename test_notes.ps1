<#
.SYNOPSIS
Interactive note creation and listing tool for Supabase Notes API
#>

# Configuration
$supabaseUrl = "https://opoakxgxbaftmacemewm.supabase.co"
$postUrl = "$supabaseUrl/functions/v1/post_notes"
$getUrl = "$supabaseUrl/functions/v1/get_notes"

# Check for token or get new one
if (-not $env:SUPABASE_TOKEN) {
    Write-Host "No token found. Getting new access token..." -ForegroundColor Yellow
    try {
        $token = .\get_token.ps1
        $env:SUPABASE_TOKEN = $token
    } catch {
        Write-Error "Failed to get token: $_"
        exit 1
    }
}

# Interactive note creation
function New-Note {
    Write-Host "`nCreate New Note" -ForegroundColor Cyan
    Write-Host "---------------"

    $title = Read-Host "Enter note title (required)"
    while ([string]::IsNullOrWhiteSpace($title)) {
        Write-Host "Title cannot be empty!" -ForegroundColor Red
        $title = Read-Host "Enter note title (required)"
    }

    $content = Read-Host "Enter note content (optional)"
    $isPublic = $false
    $confirm = Read-Host "Make note public? (y/N)"
    if ($confirm -eq 'y') { $isPublic = $true }

    $body = @{
        title = $title
        content = $content
        is_public = $isPublic
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $postUrl -Method Post -Headers @{
            "Authorization" = "Bearer $env:SUPABASE_TOKEN"
            "Content-Type" = "application/json"
        } -Body $body

        # Success output
        $output = @{
            status = "success"
            message = "Note created successfully!"
            note = $response
            timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }

        $output | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Green
        return $response
    } catch {
        $errorOutput = @{
            status = "error"
            message = "Failed to create note"
            error = $_.Exception.Message
            request = @{
                method = "POST"
                url = $postUrl
                body = $body
            }
            timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
        $errorOutput | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Red
        return $null
    }
}

# Main interactive loop
do {
    # Create note
    $newNote = New-Note

    # Show all notes if creation was successful
    if ($newNote) {
        try {
            $notes = Invoke-RestMethod -Uri $getUrl -Method Get -Headers @{
                "Authorization" = "Bearer $env:SUPABASE_TOKEN"
            }

            Write-Host "`nAll Your Notes" -ForegroundColor Cyan
            Write-Host "--------------"
            $notes | Format-Table -Property @(
                @{Name="Title"; Expression={$_.title}; Width=30},
                @{Name="Created"; Expression={[datetime]::Parse($_.created_at).ToString("g")}; Width=20},
                @{Name="ID"; Expression={$_.id.Substring(0,8)+"..."}; Width=15}
            ) -AutoSize
        } catch {
            Write-Host "`nFailed to retrieve notes: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    $continue = Read-Host "`nCreate another note? (Y/n)"
} while ($continue -ne 'n')

Write-Host "`nSession complete. Your access token remains valid for future use." -ForegroundColor Green