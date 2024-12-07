####Powershell Scripts for use with Solarwinds#############

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


##eaxmple:
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command "& {& "D:\PS_SW_Alerts\omnibusPostEifMsg.ps1" -locale PROD -actionType triggerWarning -messageType Component -alertObjectID ${N=Alerting;M=AlertObjectID} -objectID ${N=SwisEntity;M=Application.ApplicationID} -alertName ${N=Alerting;M=AlertName} -node '${N=SwisEntity;M=Application.Node.Caption}' -sitOrigin '${N=SwisEntity;M=Application.ApplicationAlert.ApplicationName}' -sitDisplayItem '${N=SwisEntity;M=ComponentAlert.ComponentName}' -appName '${N=SwisEntity;M=Application.ApplicationAlert.ApplicationName}' -compAvailability ${N=SwisEntity;M=ComponentAlert.ComponentAvailability} }"

##########text####################

SolarWinds brings unparalleled automation and intelligence to IT operations, transforming how NOC teams respond to issues and optimize systems. Alerts can be delivered via email, dashboards, or SMS, ensuring timely notifications for critical events like service outages. Beyond notification, SolarWinds automation can proactively restart services if they stop, reducing downtime and eliminating the need for manual intervention. Advanced analytics enable root cause analysis, such as identifying why a server restarted, saving NOC teams 20-30 minutes of investigation time. Additionally, automation extends to patch management, configuration backups, and capacity forecasting, enabling teams to predict and prevent issues before they occur. SolarWinds’ intuitive dashboards provide actionable insights, allowing IT to focus on strategic tasks rather than reactive firefighting, ultimately boosting operational efficiency and ensuring business continuity.




#################################################

You are likely running the command as "nt authority\system", not as the user you think you are running it as.  The "Credential for Monitoring" setting is really only setting a variable called ${CREDENTIAL}. I get around this by:

$Creds = Get-Credential '${CREDENTIAL}'

Invoke-SqlCmd -Credential $Creds [and whatever else]


###########################################################################################################################################

https://documentation.solarwinds.com/en/success_center/sam/content/sam-windows-powershell-script-execution-mode.htm?

###########################################################################################################################################



The following script can be used in the SolarWinds Platform Web Console, or in the PowerShell console. It returns 0 as the exit code and the Hostname of the SolarWinds Platform server (Local Host) or the Hostname of the target machine (Remote Host).

In the PowerShell console, the script returns the local machine Hostname. If the script cannot get the hostname, it returns 1 as the exit code and a “Host not found” message.

$stat = $env:computername;
if ($stat -ne $null)
{
Write-Host "Statistic: 0";
Write-Host "Message: $stat";
}
else
{
Write-Host "Statistic: 1";
Write-Host "Message: Host not found";
}

#################################################################################################################################################################


How to Use ${IP} in a PowerShell Script?
Here’s an example for getting the Last Boot Time of a server (like ServerA, ServerB, or ServerC).

# SolarWinds provides the IP address of the target server via the ${IP} variable
$targetServer = "${IP}"

try {
    # Use Get-CimInstance to query Win32_OperatingSystem on the remote target server
    $uptime = Get-CimInstance -ComputerName $targetServer -ClassName Win32_OperatingSystem

    # Check if a result was returned
    if ($uptime) {
        Write-Host "Message: Last boot time for $targetServer is $($uptime.LastBootUpTime)"
        Write-Host "Statistic: 1"
    } else {
        Write-Host "Message: No data received from $targetServer"
        Write-Host "Statistic: 0"
    }
} catch {
    # Handle errors gracefully in case the connection to the remote server fails
    Write-Host "Message: ERROR: Could not retrieve boot time for $targetServer. Error: $($_.Exception.Message)"
    Write-Host "Statistic: 0"
}


Explanation of the Script
${IP}:

This variable is automatically replaced with the target server’s IP address at runtime (ServerA, ServerB, ServerC, etc.).
Get-CimInstance:

This cmdlet queries the Win32_OperatingSystem class on the remote server specified by $targetServer (which holds the value of ${IP}).
try...catch:

If something goes wrong (like the server is offline, or WinRM is not configured), the error is caught, and a helpful message is output.
Write-Host "Message:" and Write-Host "Statistic:":

These are required by SolarWinds to log the message and statistic for display on the dashboard.


##############################################################################################################################################################


SolarWinds PowerShell Script Documentation - Clarified Version
Overview
This document explains how SolarWinds executes PowerShell scripts under Local Host and Remote Host execution modes. It clarifies when to use $env:COMPUTERNAME and ${IP}, and explains how to query remote servers like ServerA, ServerB, and ServerC correctly.

Key Concepts
Concept	Local Host Mode	Remote Host Mode
Where does the script run?	On the SolarWinds polling engine	Directly on the target node (ServerA, ServerB)
Does it run on the target server?	No - It runs on the polling server	Yes - It runs directly on the target server
How does it get the target server's name?	Must use ${IP} to reference target	Uses $env:COMPUTERNAME, no ${IP} required
Do I need to use ${IP}?	Yes, if you want to reference a remote server	No, the script is already running on the server
How does SolarWinds know which node to target?	It doesn’t unless you use ${IP}	SolarWinds runs it directly on the target server
Common cmdlets used	Get-CimInstance -ComputerName ${IP} or Invoke-Command -ComputerName ${IP}	$env:COMPUTERNAME, local WMI or PowerShell
When to Use $env:COMPUTERNAME vs ${IP}
Use Case	Use $env:COMPUTERNAME	Use ${IP}
Get the name of the server where the script is running	Yes (only in Remote Host mode)	No
Query a remote server from the polling engine	No	Yes (required)
Run WMI commands on the assigned node	Yes (Remote Host only)	No (SolarWinds binds the node context)
Query remote server from Local Host execution	No	Yes (required)
Run locally on the SolarWinds polling server	Yes	No
Key Variables in SolarWinds PowerShell
Variable	Description	Where is it used?
${IP}	The IP address of the target server assigned to the script	Use it when querying remote servers via WMI, WinRM, or network protocols.
$env:COMPUTERNAME	The hostname of the system where the script is running	Use it when running Remote Host execution directly on the assigned node.
$TargetServer	Variable you define (could be set to ${IP})	Use it to make the script more readable.
1️⃣ Example 1: Remote Host Mode (No ${IP} Required)
Objective: Get the hostname of the assigned node (ServerA, ServerB, or ServerC).
Execution Mode: Remote Host (SolarWinds runs the script directly on the assigned node).
Why No ${IP}?: Because the script runs on the target server, $env:COMPUTERNAME returns the hostname of that server.
powershell
Copy code
# This script runs directly on the target server
$stat = $env:COMPUTERNAME;

if ($stat -ne $null) {
    Write-Host "Statistic: 0"; # Success
    Write-Host "Message: The hostname of this server is $stat";
} else {
    Write-Host "Statistic: 1"; # Failure
    Write-Host "Message: Hostname not found";
}
Explanation
Where the script runs: Directly on ServerA, ServerB, or ServerC.
What $env:COMPUTERNAME returns: The hostname of the server (ServerA, ServerB, or ServerC).
When to use this: Use this method if you don't want to query remotely but instead run the script directly on the target server.
No ${IP} needed: SolarWinds knows which node it's running on.
2️⃣ Example 2: Local Host Mode (Using ${IP})
Objective: Get the hostname of ServerA, ServerB, or ServerC.
Execution Mode: Local Host (SolarWinds runs the script on the polling engine).
Why Use ${IP}?: Because the script is not running on the target server; it's running on the polling server. Therefore, you must explicitly tell it which server to query.
powershell
Copy code
# Get the IP address of the assigned node from SolarWinds
$targetServer = "${IP}";

try {
    # Remotely query the target server to get its hostname
    $stat = Invoke-Command -ComputerName $targetServer -ScriptBlock {
        $env:COMPUTERNAME
    }

    if ($stat -ne $null) {
        Write-Host "Statistic: 0"; # Success
        Write-Host "Message: The hostname of $targetServer is $stat";
    } else {
        Write-Host "Statistic: 1"; # Failure
        Write-Host "Message: Hostname not found on $targetServer";
    }
} catch {
    Write-Host "Message: ERROR: Could not retrieve hostname for $targetServer. Error: $($_.Exception.Message)";
    Write-Host "Statistic: 1";
}
Explanation
Where the script runs: On the SolarWinds polling server.
How it knows which server to query: It uses ${IP} to know the IP of the assigned node (ServerA, ServerB, or ServerC).
What $env:COMPUTERNAME returns: This would return the hostname of the polling engine, not ServerA, so we must use ${IP} to target ServerA.
When to use this: Use this method if you are polling the target server remotely from the polling server.
${IP} is required: Without ${IP}, you will only get information about the polling server.
3️⃣ Example 3: Local Host Mode (No ${IP}, No Remote Query)
Objective: Get the hostname of the polling server.
Execution Mode: Local Host (runs on the polling server, no remote query).
Why No ${IP}?: Since this script runs only on the polling server, you don't need to reference any remote IP.
powershell
Copy code
# Get the hostname of the polling engine
$stat = $env:COMPUTERNAME;

if ($stat -ne $null) {
    Write-Host "Statistic: 0"; # Success
    Write-Host "Message: The hostname of the polling server is $stat";
} else {
    Write-Host "Statistic: 1"; # Failure
    Write-Host "Message: Hostname not found";
}
Explanation
Where the script runs: On the SolarWinds polling server.
What $env:COMPUTERNAME returns: It returns the hostname of the polling engine.
When to use this: Use this method if you only care about the polling server’s information.
No ${IP} needed: You are not referencing any other servers in this scenario.
Summary
Scenario	Where the script runs?	What does $env:COMPUTERNAME return?	Do you need ${IP}?
Remote Host Mode (runs on ServerA)	ServerA, ServerB, ServerC	Returns the hostname of the server	No
Local Host Mode (query remote server)	Polling engine	Returns hostname of polling engine	Yes (to target ServerA)
Local Host Mode (get polling server info)	Polling engine	Returns hostname of polling engine	No


####################################################################################################################################################################################################

A NOC (Network Operations Center) team is a group of IT professionals responsible for monitoring, managing, and maintaining an organization’s IT infrastructure to ensure system availability, performance, and security. The NOC acts as the centralized command center for network, server, and application monitoring, often operating 24/7.


Scenario: The NOC team receives an alert that "ServerA memory usage exceeded 90% at 3:15 PM."
Problem: SolarWinds only shows total memory usage and doesn’t tell you which process caused it.
Solution:

The NOC team opens the PerfMon log file from C:\PerfLogs.
They load the blg file into PerfMon and see that at 3:15 PM, the process app.exe was using 2 GB of memory, which was 80% of total memory.
The NOC team flags this process for review and submits it to the application support team to review the application memory leak.




Management-Friendly Explanation
"To reduce system resource usage and maintain high visibility, we track per-process CPU and memory usage directly on each server using Windows Performance Monitor (PerfMon). This method runs locally, without relying on external monitoring tools like SolarWinds. By logging process activity every 1 minute and automatically deleting logs older than 24 hours, we maintain visibility into which processes caused spikes in usage without creating unnecessary load on the server or network. This strategy provides detailed, actionable insights into memory spikes and CPU bottlenecks, allowing for faster root cause analysis and fewer unnecessary alerts.
Configure log file rollover based on time (24 hours) or file size (e.g., 1GB).


Alert fatigue in SolarWinds occurs when NOC teams are overwhelmed with excessive, repetitive, or low-priority alerts, leading to missed critical issues. To prevent it, you can fine-tune alert thresholds, use intelligent alert suppression (like time-based conditions or dependencies), and prioritize critical alerts while filtering out noise through alert escalation policies and custom alert actions.




A 24-hour PerfMon log with 50 processes, 3 counters, and a 1-minute interval will be about 100-103 MB per day.
If you track more processes, reduce intervals, or add more counters, log size increases.
Auto-delete logs older than 24 hours to keep disk usage low.
Use binary log files (.blg) to save disk space.
Management-Friendly Summary
"To efficiently track per-process memory and CPU usage, we log metrics every 1 minute for 24 hours, resulting in an average log size of 100 MB per server per day. To conserve disk space, we configure servers to automatically delete logs older than 24 hours, ensuring a continuous rolling 24-hour window for analysis. This method balances visibility, disk usage, and performance impact, ensuring we capture critical information without excessive overhead."




This strategy provides a comprehensive, low-impact monitoring solution by combining SolarWinds alerts and graphs for real-time issue detection with 24-hour PerfMon process-level logs for deep-dive root cause analysis. SolarWinds detects spikes, sends alerts, and shows high-level trends, while PerfMon fills the visibility gap by capturing per-process memory and CPU usage at 1-minute intervals. This seamless integration allows NOC teams to quickly identify and resolve issues without alert fatigue, ensuring faster troubleshooting and better system performance.





