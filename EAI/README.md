## EAI Onboarding Powershell Script
### Main Functionality
1. Mounting FSx
2. Checks validity of AD account provided
3. Creates main folder with project name as title
4. Creates subfolders within the main folder with name: Inbox, Inbox-Src, Inbox-logs, Outbox, Outbox-Src, Outbox-logs
5. Grants the AD account permissions: CreateFiles, WriteExtendedAttributes, WriteAttributes, Delete, ReadAndExecute, Synchronize

> Note: Should one step in the script fail or is unsuccessfully executed, the script will delete created folders and subfolders.


## Troubleshooting:
### Mounting FSx: Unsuccessful
This means that the FSx Path is not found. <br>
Check if FSx command in AWS is correct for the right environment.<br>
Check if username and password is pulled correctly from AWS.<br>

### Checking AD Account: $ADAccount Not Found 
This means that the AD account provided cannot be found.<br>
Check if the AD account provided is valid (Not sure how to check if you cannot access console)<br>
<br>
For other errors, do check for typos in script.

## Testing:
### Local Machine Testing:
1. Create a localuser
```
New-LocalUser 'TestUser' -NoPassword
```
2. Replace values
<br>
$username = ''
<br>
$password = ''
<br>
$FSxPath = 'C:\Users\Administrator\Desktop'
<br>
$ADAccount = 'TestUser'
<br>
$ProjectName = 'TestProject'
