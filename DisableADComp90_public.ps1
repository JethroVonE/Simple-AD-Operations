#The purpose of this script is to find computers that have NOT been logged in for more than 90 days. This will disable the computer account and move it to the disabled computers group.
#The user that runs the script MUST have permissions to work with the computer object at the level of being able to disable and move. A standard user will NOT be able to run this script.
#You will need to modify the if state below. This is put in place as a safety to keep from running operations where they shouldn't be. You an -And more than one and it will work just as well.
#Importing Needed Modules.
import-module ActiveDirectory
import-module Microsoft.PowerShell.Utility
#First we need the date that is 90 days prior to today. In this case today is whenever the script is ran. All we are doing is pulling 90 days from todays date.
$DateDisable = (get-date).adddays(-90)
#We will be using Get-ADComputer to get the properties from AD that is required for the purposes of this script. 
#CN will give us the hostname, DistinguishedName will give us the Object name and location, with respect to AD, and LastLogonDate will give us the last time the computer was logged on.
$Computer = Get-ADComputer -Filter * -Properties CN,DistinguishedName,LastLogonDate
Foreach($Comp in $Computer) #This just sets up the loop. Eveything else will be done inside this loop.
{
#First we need to establish the date the computer was logged into last. To do this we will pull the lastlongonDate property from the loop.
$DateLastLog = $Comp.LastLogonDate
#We also need the hostname of the computer in question. Again we will pull a property from the loop, this time we need CN.
$ComputerName = $Comp.CN
#Finally, we need the DistinguishedName
$ComputerDistName = $Comp.DistinguishedName
#So we have the DN of the computer, but really don't need the hostname attached to it. I'm sure there are other ways to do this, but why make 30 lines of code when you can make 1
$ComputerThrowaway,$ComputerOU = $ComputerDistName -Split ',',2 #All we are doing is returning the DN split into 2 vars. The first we don't need. The Second we do.
#Now we can start to if ourselves into oblivion.
#We are compairing the date we want to use as a frame of reference to the date of the last logon of the computer. If the computer has logged on for 90 days
#The disable date will be greater than teh last logon date. 
if($DateDisable -gt $DateLastLog) {    
#Just making sure the loop is giving the data we need.
#Second if. We dont need to do anything to the computers that are already in the correct OU. So we are just going to do a quick check here.
#Modify the IF here 
if($ComputerOU -ne "Distinguished Name Required" ) { 
    Write-Output "$ComputerName"
    $Continue = Read-Host -Prompt "Press y to disable this computer" #All we are doing here is to making the script pause to make sure the computer is where it should be. After a few runs
    #This will be taken out and the script can run fully automated.
   If($Continue -eq "y") {
        #Disable computers
        Get-ADComputer -Identity $ComputerName | Set-ADComputer -Enabled $false
        #Move computers
        Get-ADComputer -Identity $ComputerName | Move-ADObject -TargetPath  "OU=Computer Disabled,DC=pine,DC=pbmhr,DC=intra"
        Write-Output "Computer Disabled"
    } 
} #IF 1
} #IF 2
} #ForEach