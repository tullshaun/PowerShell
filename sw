#region Define Exit Codes
# Define a hash table for exit codes to represent different states
$ExitCode = @{ "Up"       = 0;    # OK
               "Down"     = 1;    # ERROR/FAILURE
               "Warning"  = 2;    # Potential Issue
               "Critical" = 3;    # Severe Issue
               "Unknown"  = 4     # Unable to determine
             }
#endregion Define Exit Codes

#region Check to see if this is running from within Orion
# Determine if the script is running within Orion or locally
if (-not ${IP}) {
    # Define default values for standalone execution
    $TargetServer = "localhost"
    $IsOrion      = $false
} else {
    # Use Orion-provided IP variable if script is executed in Orion
    $TargetServer = ${IP}
    $IsOrion      = $true
}
#endregion Check to see if this is running from within Orion

try {
    # TRY BLOCK: Place the core logic of the script here
    # Example: Collect data or perform an action
    # Replace the following with your own logic
    $exampleOutput = "Sample Output"

    if ($exampleOutput -eq "Expected Output") {
        Write-Host "Message: Everything is working as expected."
        Write-Host "Statistic: 1"
        $ExitState = "Up"
    } else {
        Write-Host "Message: Unexpected output detected."
        Write-Host "Statistic: 0"
        $ExitState = "Warning"
    }
} catch {
    # CATCH BLOCK: Handle errors gracefully
    Write-Host "Message: ERROR: $($Error[0])"
    Write-Host "Statistic: 0"
    $ExitState = "Down"
} finally {
    # FINALLY BLOCK: Ensure proper exit behavior
    if ($IsOrion) {
        # If running in Orion, exit with the appropriate code
        exit $ExitCode[$ExitState]
    } else {
        # If running locally, display exit codes without exiting
        Write-Host "Not running on an Orion Server - do not exit" -ForegroundColor Yellow
        Write-Host "Exit Code: $( $ExitCode[$ExitState] )" -ForegroundColor Red
    }
}

###############################################################################

#region Define Exit Codes
$ExitCode = @{ "Up"       = 0;
               "Down"     = 1;
               "Warning"  = 2;
               "Critical" = 3;
               "Unknown"  = 4
             }
#endregion Define Exit Codes

#region Check to see if this is running from within Orion
if (-not ${IP}) {
    $TargetServer = "localhost"
    $IsOrion      = $false
} else {
    $TargetServer = ${IP}
    $IsOrion      = $true
}
#endregion Check to see if this is running from within Orion

# Define the account name to check
$accountName = "OracleHomeUser"

try {
    # Run the Net User command and capture the output
    $netUserOutput = net user $accountName 2>&1

    # Check if the account exists
    if ($netUserOutput -like "*The user name could not be found*") {
        Write-Host "Message: $accountName does not exist on this server"
        Write-Host "Statistic: 1"
        $ExitState = "Down"
    }
    # Check if the account is active
    elseif ($netUserOutput -match "Account active\s+Yes") {
        Write-Host "Message: $accountName is active"
        Write-Host "Statistic: 0"
        $ExitState = "Up"
    }
    # Check if the account is locked out or disabled
    elseif ($netUserOutput -match "Account active\s+No") {
        Write-Host "Message: $accountName is locked out or disabled"
        Write-Host "Statistic: 3"
        $ExitState = "Critical"
    }
    # Unable to determine status
    else {
        Write-Host "Message: Unable to determine the status of $accountName"
        Write-Host "Statistic: 2"
        $ExitState = "Warning"
    }
} catch {
    # Handle any errors during execution
    Write-Host "Message: ERROR: $($Error[0])"
    Write-Host "Statistic: 0"
    $ExitState = "Down"
} finally {
    if ($IsOrion) {
        exit $ExitCode[$ExitState]
    } else {
        Write-Host "Not running on an Orion Server - do not exit" -ForegroundColor Yellow
        Write-Host "Exit Code: $( $ExitCode[$ExitState] )" -ForegroundColor Red
    }
}

#########notes ##############################

The #region Check to see if this is running from within Orion part of the script is designed to determine where the script is being executed: either:

Within SolarWinds Orion, where the script is part of a monitoring task (e.g., checking server health, application status, etc.), or
Locally or in another non-Orion environment, like your personal computer or a standalone server, for testing or development purposes.
Why Is This Check Important?
When a script runs in Orion, it has access to certain built-in variables, like ${IP}, which provides the target server's IP address. These variables help direct the script's operations.
When running locally, those variables won't exist. In such cases, the script needs a fallback mechanism, like using a default server (localhost in this case).
Breaking It Down:
Here’s what the region does step-by-step:

1. Check for Orion-Specific Variables
powershell
Copy code
if (-not ${IP}) {
${IP}: This variable is defined automatically by Orion when the script runs as part of a SolarWinds monitoring job.
-not: This checks if ${IP} is undefined or null. If ${IP} is not present, it means the script is not running in Orion.
2. Local Fallback
powershell
Copy code
    $TargetServer = "localhost"
    $IsOrion      = $false
$TargetServer: The server against which the script operates. Here, it defaults to localhost (the local machine) for testing purposes.
$IsOrion: A flag that indicates the script is not running in Orion ($false).
3. Orion Execution
powershell
Copy code
} else {
    $TargetServer = ${IP}
    $IsOrion      = $true
}
$TargetServer = ${IP}: Uses the ${IP} variable provided by Orion to set the target server for the script's operations.
$IsOrion: The flag is set to $true, indicating the script is running in the Orion environment.
Why Is This Useful?
Testing vs. Production:

When developing or debugging a script, you can test it locally using localhost or a specific server IP without depending on Orion's environment.
When deployed to Orion, the script seamlessly uses Orion-provided variables like ${IP}.
Flexibility:

This setup ensures the script works both inside and outside Orion, making it reusable and versatile.
Error Prevention:

Without this check, a script might fail locally due to missing Orion-specific variables, or worse, misbehave when deployed.
Example Use Case:
Imagine you're writing a script to check the disk space of a server:

Locally: The script uses localhost to check your computer's disk space during development.
In Orion: Orion supplies the ${IP} of the server being monitored, and the script automatically targets the correct server.
This dual-environment capability makes your script robust and adaptable.
