<#
.SYNOPSIS
Retrieves all notes for the authenticated user from Supabase in JSON format.

.DESCRIPTION
This script:
1. Uses the stored SUPABASE_TOKEN from environment variables
2. Makes an authenticated GET request to the /get_notes endpoint
3. Returns formatted JSON output with error handling
#>

# Configuration
$supabaseUrl = "https://opoakxgxbaftmacemewm.supabase.co"
$functionUrl = "$supabaseUrl/functions/v1/get_notes"

# Check for auth token
if (-not $env:SUPABASE_TOKEN) {
    Write-Error "SUPABASE_TOKEN not found. Run get_token.ps1 first."
    exit 1
}

try {
    # Make the API request
    $response = Invoke-RestMethod -Uri $functionUrl -Method Get -Headers @{
        "Authorization" = "Bearer $env:SUPABASE_TOKEN"
        "Content-Type" = "application/json"
    }

    # Create enhanced output object
    $output = @{
        metadata = @{
            timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz")
            noteCount = $response.Count
            userId = $response[0].user_id  # Assuming all notes have same user_id
        }
        notes = $response
    }

    # Convert to pretty-printed JSON
    $jsonOutput = $output | ConvertTo-Json -Depth 10

    # Output to console and clipboard
    $jsonOutput
    $jsonOutput | Set-Clipboard
    Write-Host "`nNote data has been copied to your clipboard." -ForegroundColor Green

    # Optional: Save to file
    $jsonOutput | Out-File -FilePath "user_notes_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Write-Host "Saved to user_notes_$(Get-Date -Format 'yyyyMMdd_HHmmss').json" -ForegroundColor Cyan

} catch {
    # Enhanced error handling
    $errorDetails = @{
        error = @{
            message = $_.Exception.Message
            statusCode = $_.Exception.Response.StatusCode.value__
            request = @{
                method = "GET"
                url = $functionUrl
                headers = @{
                    Authorization = "Bearer ***redacted***"
                }
            }
            timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz")
        }
    }

    $errorDetails | ConvertTo-Json -Depth 5 | Write-Output
    exit 1
}