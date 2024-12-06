# test  Write-Host "Message: $($ENV:ComputerName)"



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



#######################################################


The output is formatted as:

"Statistic" which is a numerical value
"Message" which is a string value
The value following the Message/Statistic keyword can be numerical or string values, and are the keys for identifying which Message/Statistic to reference, and will be the label given to it in the outputs section.

The value that Orion is checking for the thresholds is the numerical value (Statistic).

So, in order to monitor the output of your SQL query, you'll need to setup a comparison operation and use that to generate a numerical value that Orion can reference as a threshold. Given the type of data your example query returns you would need to come up with some logic to determine what you're looking for and then convert that into a True/False (1/0) response and return (Write-Host) that value.

If you're looking for a specific database name to be present you could do something like the following:

Import-Module SqlServer
$Query = "SELECT name FROM sys.databases"
$ServerInstance = $args[0]  # The argument ${Node.Caption} passed from the arguments line
$QueryResults = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $Query

$DatabaseNameExpected = "SolarWindsOrion"  # The name of the DB we are validating is present
$DatabasePresent = [int]($QueryResults.name -contains $DatabaseNameExpected)  # Checks for presence as True/False and converts to integer

Write-Host ("Statistic.OrionDatabaseExists: " + $DatabasePresent)

<#
    * This assumes that the credential set being used has permissions to query the databse.
    * Performs your query
    * Moves the "${Node.Caption}" Orion variable to the arguments line to that it can be used in the script body
    * And the rest is stuff I made up to provide an example of a way to parse the data into something usable by Orion
#>
Exit(0)

######################################################################################################reboot pending ##########################################


# Check if the registry path indicating a reboot is pending exists
$reg = test-path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'

# If the registry path exists (indicating a reboot is pending)
if ($reg) {
   # Write a message indicating a reboot is pending
   write-host "Message: Reboot Pending."
   # Write a statistic (custom metric) of 1 to indicate reboot required
   write-host "Statistic: 1"
   # Exit the script with a code of 0 (status "Up" or OK for Orion SAM)
   exit 0
} else {
   # If the registry path does not exist (no reboot is required)
   write-host "Message: Reboot not required."
   # Write a statistic of 0 to indicate no reboot is required
   write-host "Statistic: 0"
   # Exit the script with a code of 0 (status "Up" or OK for Orion SAM)
   exit 0
}

# Define a constant for the HKEY_LOCAL_MACHINE (HKLM) registry hive
# [uint32]'0x80000002' is the constant for HKLM
$hklm = [uint32]'0x80000002'

# Get the StdRegProv (Standard Registry Provider) class from WMI on the target machine
# The namespace 'root/default' contains the StdRegProv class
# '${IP}' is a placeholder for the target computer's IP, passed by Orion or defined locally
$reg = gwmi -list stdregprov -ns root/default -computer '${IP}'

# Use the CheckAccess method to check if the script has access to the registry path
# $hklm: Represents the HKEY_LOCAL_MACHINE hive
# 'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending': Registry key to check
# 1: Access mask (1 means "read access")
$r = $reg.CheckAccess($hklm, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending', 1)

# Check the result of the CheckAccess method
if ($r.bgranted -like 'True') {
   # If the script has access and the reboot-pending key exists, indicate a reboot is pending
   write-host "Message: Reboot Pending."
   write-host "Statistic: 1"
   exit 0
} else {
   # If the script does not have access or the key does not exist, no reboot is required
   write-host "Message: Reboot not required."
   write-host "Statistic: 0"
   exit 0
}

# (Optional section for credentialed access)
# Get the StdRegProv class using alternate credentials if required
# '${CREDENTIAL}' is a placeholder for the credentials object provided by Orion or defined locally
$reg = gwmi -list stdregprov -ns root/default -computer '${IP}' -Credential '${CREDENTIAL}'
Explanation of Each Section:
Registry Path Check (Test-Path):

Checks if the registry path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending exists.
If it exists, it indicates that a reboot is pending, so the script outputs a corresponding message and statistic.
Using StdRegProv (Standard Registry Provider):

If the direct Test-Path check fails or if the script requires additional permissions, the StdRegProv WMI class is used.
This allows for more complex operations, such as checking access rights to registry keys or querying remote machines.
Access Check (CheckAccess Method):

Verifies whether the script has sufficient permissions to read the target registry key.
Returns a boolean ($r.bgranted) indicating whether access is granted.
Credentialed Access:

If the script requires alternate credentials to access the remote registry, it can pass them via the -Credential parameter when calling gwmi.
Output and Exit:

The script outputs a Message (human-readable) and a Statistic (numeric value) for SolarWinds SAM.
The exit codes and statistics provide feedback to the monitoring system about the script's findings.
Simplified Flow:
Check if the registry key exists.
If not, use WMI to check access to the registry key.
Depending on the result, output the message and statistic, then exit the script.
This script is a comprehensive way to monitor the reboot-pending status, with fallback mechanisms and support for different execution environments.

########################################################################################################


if you update your $WMI_Reg line to this if that fixes it.

Fullscreen

The ${IP} should pass in the IP of the node the template is assigned too and ${Credential} should pass in the assigned credential on that component monitor.


##########################################################################################################


Got it to work by setting the "Trusted Host" also on the "WINRM Client" GPO portion.
Computer Configuration > Policies > Administrative Templates: Policy definitions > Windows Components > Windows Remote Management (WinRM) -> WINRM Client







######################## activating a script call in SW ################################
#  set the RemoteSigned execution policy for scripts

A Network Operations Center (NOC) team is a group of IT professionals responsible for monitoring, managing, and maintaining an organization's IT infrastructure, networks, and systems. The NOC acts as a centralized hub where specialists use tools and technologies to ensure the health, performance, and security of the IT environment.

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "C:\scripts\SomeScript.ps1 '${NodeName}'"


The Alert Manager triggered the 32-bit version of powershell.exe.  I needed to set the RemoteSigned execution policy for scripts in the 32-bit environment and change my powershell.exe path.

(in an elevated CMD prompt) C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" set-executionpolicy remotesigned -force



And then change the action to:

C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -Command "C:\scripts\SomeScript.ps1 '${NodeName}'"















