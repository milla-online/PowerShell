#!/usr/local/bin/pwsh

<# 
.SYNOPSIS
    Short description of what the script does.

.DESCRIPTION 
    Long description of the script.

.NOTES 
    Additional notes.

.LINK 
    Links to useful websites or more information.

.PARAMETER firstParameter 
    Mandatory string parameter. Please provide a text or a variable of type string.
    
    Usage:
    template.ps1 -firstParameter "myText"
    template.ps1 -firstParameter $stringVariable

.PARAMETER secondParameter
    Mandatory switch parameter. Use it to set it. Don't use it to not set it.

    Usage:
    template.ps1 -secondParameter

.EXAMPLE
    Example how to execute and use the script.

    Usage:
    
    template.ps1 -firstParameter "test"

    Set first parameter to the text "test". Provide no second parameter.


    template.ps1 -firstParameter "test" -secondParameter

    Set first parameter to the text "test". Provide second parameter.

    
    template.ps1 -firstParameter $myVariable -secondParameter -Debug:$true

    Set first parameter to a variable. Provide second parameter. Activate debug output.
#>

# Makes the script operate like compiled cmdlets written in C#. It provides access to the features of cmdlets.
# Additionally define own parameters.
[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)] [string]$firstParameter,
        [Parameter(Mandatory=$false,Position=1)] [switch]$secondParameter
    )


##############################
# Debug and verbose messages #
##############################

# Output of parameter values only if "-Debug" was set
Write-Debug -Message "firstParameter: $firstParameter"
Write-Debug -Message "secondParameter: $secondParameter"

# Output of additional text only if "-Verbose" was set
Write-Verbose -Message "Verbose Message"

# write new line for nicer output
Write-Host

#########################################
# customize the behaviour of PowerShell #
#########################################

# Documentation of possible variables and values:
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables

$ErrorActionPreference = "Stop" # Change default behaviour and stop on script errors.
$VerbosePreference = "Continue" # Stop supressing writing verbose messages to the console. This allows the use of Write-Verbose.
$DebugPreference = "Continue"   # Stop supressing writing debug messages to the console. This allows the use of Write-Debug.


#######################################    
# secure store and load of a password #
#######################################

# secure store of password in a file
"MySecureP@55w.rd" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File -FilePath ./password.crypt

# secure load of password
$encrypted = Get-Content -Path ./password.crypt | ConvertTo-SecureString
$credential = New-Object -TypeName System.Management.Automation.PSCredential("username", $encrypted)
$password = $credential.GetNetworkCredential().Password

# display loaded password
Write-Host -Object "Password:" -ForegroundColor Yellow
Write-Host "This is my password: $password."

# cleanup: delete created password file
Remove-Item -Path ./password.crypt

# write new line for nicer output
Write-Host

##############################
# loops and how to exit them #
##############################

# display start message for loop example
Write-Host -Object "Loops:" -ForegroundColor Yellow

# definiton of arrays to loop through
$outerArray = @("one","two","three","four")
$innerArray = @(1,2,3,4)

# outer loop
:outerloop foreach ($outerDataset in $outerArray)
{

    Write-Host "$outerDataset - start" -ForegroundColor DarkBlue

    :innerloop foreach ($innerDataset in $innerArray)
    {
        
        Write-Host "  $innerDataset - start" -ForegroundColor DarkYellow


        ####################
        # break conditions #
        ####################

        # continue inner loop at second pass so it never goes to the end of processing '2'
        if ($innerDataset -eq 2)
        {
            Write-Host "  $innerDataset - continue" -ForegroundColor Cyan
            continue innerloop
        }

        # break inner loop at third pass so it never goes to '4'
        if ($innerDataset -eq 3)
        {
            Write-Host "  $innerDataset - break" -ForegroundColor Red
            break innerloop
        }

        # continue outer loop at second pass so it never goes to the end of processing 'three"
        if ( $outerDataset -eq "two")
        {
            Write-Host "$outerDataset - continue" -ForegroundColor Cyan
            continue outerloop
        }

        # break outer loop at third pass so it never goes to "four"
        if ($outerDataset -eq "three")
        {
            Write-Host "$outerDataset - break" -ForegroundColor Red
            break outerloop
        }
        Write-Host "  $innerDataset - end" -ForegroundColor DarkYellow

    }

    Write-Host "$outerDataset - end" -ForegroundColor DarkBlue
}

# write some new lines
Write-Host

#################
# write logfile #
#################

# define a function for writing in a logfile
# Source: https://www.script-example.com/powershell-logging
function Write-Log
{

    Param
    (
        $text
    )

    # build log text line. Generate timestamp and add text, then write to logfile.
    "$(get-date -format "yyyy-MM-dd HH:mm:ss") : $($text)" | out-file ./log.txt -Append

}

# create log entries using the above function
Write-Log -text "myLogEntry1"
Write-Log -text "myLogEntry2"

# display content of logfile
Write-Host -Object "Content of logfile:" -ForegroundColor Yellow
Get-Content -Path ./log.txt
Write-Host

# cleanup: delete created logfile file
Remove-Item -Path ./log.txt


##############################
# create custom table object #
##############################

# --- Version 1 with DataTable object ---

# create an empty DataTable object
$tableDatatable = New-Object system.Data.DataTable "MyTestTable"

# define columns
$col1 = New-Object system.Data.DataColumn Name,([string])
$col2 = New-Object system.Data.DataColumn ZIPCode,([decimal])
$col3 = New-Object system.Data.DataColumn DateOfBirth,([datetime])

# add columns to table
$tableDatatable.columns.add($col1)
$tableDatatable.columns.add($col2)
$tableDatatable.columns.add($col3)

# create new row object with the defined columns
$rowDatatable = $tableDatatable.NewRow()

# fill the values of the row object
$rowDatatable.Name = „Michael“
$rowDatatable.ZIPCode = 12345
$rowDatatable.DateOfBirth = [datetime](Get-Date -Year 1900 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0)

# add row object to table
$tableDatatable.Rows.Add($rowDatatable)

# display table
Write-Host "Datatable:" -ForegroundColor Yellow -NoNewline
Write-Host ($tableDatatable | Out-String) -NoNewline

# --- Version 2 with PowerShell array ---

# create empty array
$tableArray = @()

# create new row object with headers.
$rowArray = "" | Select-Object -Property Name,ZIPCode,DateOfBirth

# fill the values of the row object
$rowArray.Name = „Michael“
$rowArray.ZIPCode = 12345
$rowArray.DateOfBirth = Get-Date -Year 2000 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0

# add row object to table
$tableArray += $rowArray

# display table
Write-Host "Array:" -ForegroundColor Yellow -NoNewline
Write-Host ($tableArray | Out-String) -NoNewline


####################################
# Arrays - add and remove elements #
####################################

# source: https://pscustomobject.github.io/powershell/Add-Remove-Items-From-Array/

# Version 1 - normal array

# create an array
$myArray = @()

# add elements
$myArray += "first"
$myArray += "second"
$myArray += "third"

# display array
Write-Host "Array with all values:" -ForegroundColor Yellow
Write-Host $myArray
Write-Host

# you cannot remove element easily. You have to filter the array and create a new one instead.
$myNewArray = $myArray -ne "second"

# display filtered array
Write-Host "Array with filtered values:" -ForegroundColor Yellow
Write-Host $myNewArray
Write-Host


# Version 2 - use more dynamic arraylist

# create an arraylist
$myArrayList = New-Object System.Collections.ArrayList($null)

# add elements to list
[void]($myArrayList.Add("first"))
[void]($myArrayList.Add("second"))
[void]($myArrayList.Add("third"))

# display arraylist
Write-Host "ArrayList with all values:" -ForegroundColor Yellow
Write-Host $myArrayList
Write-Host

# remove item by index
$myArrayList.RemoveAt(1)

# display filtered arraylist
Write-Host "ArrayList with filtered values:" -ForegroundColor Yellow
Write-Host $myArrayList
Write-Host


##############
# export csv #
##############

# export running processes as csv
Get-Process | Where-Object -FilterScript { $_.ProcessName -ne "" } | Select-Object -Property ProcessName,CPU  | Export-Csv -Path ./table.csv -Encoding utf8

# same as above, but use ";" as delimiter for easier opening the file with Microsoft Excel on a german language system.
Get-Process | Where-Object -FilterScript { $_.ProcessName -ne "" } | Select-Object -Property ProcessName,CPU  | Export-Csv -Path ./table.csv -Encoding utf8 -Delimiter ";"

# display content of table.csv. Only first 5 lines.
Write-Host -Object "Content of csv file:" -ForegroundColor Yellow
Get-Content -Path ./table.csv -TotalCount 5

# cleanup: delete created csv file
Remove-Item -Path ./table.csv

# write new line for nicer output
Write-Host

############
# cleanups #
############

# delete a variable from memory
Remove-Variable -Name password


############################
# write multiple new lines #
############################

Write-Host -Object "Multiple new lines:" -ForegroundColor Yellow
Write-Host -Object "----------------"
Write-Host -Object ("`n`n`n") -NoNewline
Write-Host -Object "----------------"
Write-Host


#######
# end #
#######

# end of script
Write-Host "end of script" -ForegroundColor Yellow