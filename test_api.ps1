# API Test Script for HostelConnect GH
$baseUrl = "http://localhost:8080/api"
$adminEmail = "admin@hostelconnect.gh"
$adminPassword = "Admin@1234"
$agentEmail = "testagent@hostelconnect.gh"
$agentPassword = "Agent@1234"

function Write-Step($msg) {
    Write-Host "`n>>> $msg" -ForegroundColor Cyan
}

# 1. Login as Admin
Write-Step "Logging in as Admin..."
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$adminToken = $loginResponse.data.accessToken
Write-Host "Admin logged in. Token: $($adminToken.Substring(0, 20))..."

# 2. Register Agent
Write-Step "Registering Agent..."
$registerBody = @{
    fullName = "Test Agent"
    email = $agentEmail
    password = $agentPassword
    confirmPassword = $agentPassword
    phoneNumber = "0240000000"
    agencyName = "Test Agency"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register/agent" -Method Post -Body $registerBody -ContentType "application/json"
    Write-Host "Agent registered: $($registerResponse.message)"
} catch {
    Write-Host "Registration failed (likely already exists): $($_.Exception.Message)"
}

# 3. Get OTP from logs (Simulated by search)
# Note: Since I'm running this script, I'll tell the assistant to find the OTP and continue.
# For now, I'll assume I can find it in the logs.
Write-Host "LOOKING FOR OTP IN LOGS..."

# 4. Verify Email
# (This step will be done manually or in a second pass after I get the OTP)

# 5. Login as Agent
# 6. Upload ID
# 7. Approve Agent (Admin)
# 8. Create Listing

# Output tokens for next steps
$adminToken | Out-File -FilePath "admin_token.txt"
