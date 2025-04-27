# Configuration
$supabaseUrl = "https://opoakxgxbaftmacemewm.supabase.co"
$supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wb2FreGd4YmFmdG1hY2VtZXdtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3NTMxOTgsImV4cCI6MjA2MTMyOTE5OH0.sOKL9mUyOCKCr5AgpGQM2WPw-z6iSQzOmhoz9v7TPlY" # Replace with your actual anon key
$userEmail = "user@example.com"
$userPassword = "123456"

# 1. First try to sign in
$authBody = @{
    email = $userEmail
    password = $userPassword
} | ConvertTo-Json

try {
    Write-Host "Attempting to sign in..."
    $response = Invoke-RestMethod `
        -Uri "$supabaseUrl/auth/v1/token?grant_type=password" `
        -Method Post `
        -Headers @{
            "apikey" = $supabaseKey
            "Content-Type" = "application/json"
        } `
        -Body $authBody

    $accessToken = $response.access_token
    Write-Host "Successfully signed in!"
    Write-Host "Access Token: $accessToken"
    
    # Store token for later use
    $env:SUPABASE_TOKEN = $accessToken
    [System.Environment]::SetEnvironmentVariable('SUPABASE_TOKEN', $accessToken, 'User')
    
    return $accessToken
} catch {
    Write-Host "`nSign in failed, attempting to create user..."
    
    # 2. If sign in fails, try to create user
    try {
        $signupBody = @{
            email = $userEmail
            password = $userPassword
        } | ConvertTo-Json

        $signupResponse = Invoke-RestMethod `
            -Uri "$supabaseUrl/auth/v1/signup" `
            -Method Post `
            -Headers @{
                "apikey" = $supabaseKey
                "Content-Type" = "application/json"
            } `
            -Body $signupBody

        Write-Host "User created successfully. Attempting to sign in again..."
        
        # 3. Try signing in again after creation
        $response = Invoke-RestMethod `
            -Uri "$supabaseUrl/auth/v1/token?grant_type=password" `
            -Method Post `
            -Headers @{
                "apikey" = $supabaseKey
                "Content-Type" = "application/json"
            } `
            -Body $authBody

        $accessToken = $response.access_token
        Write-Host "Successfully signed in!"
        Write-Host "Access Token: $accessToken"
        
        $env:SUPABASE_TOKEN = $accessToken
        [System.Environment]::SetEnvironmentVariable('SUPABASE_TOKEN', $accessToken, 'User')
        
        return $accessToken
    } catch {
        Write-Host "`nError details:"
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)"
        if ($_.ErrorDetails.Message) {
            Write-Host "Error Message: $($_.ErrorDetails.Message)"
        }
        exit 1
    }
}