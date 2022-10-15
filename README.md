## EAI Onboarding Powershell Script
1. Mounting FSx
2. Checks validity of AD account provided
3. Creates main folder with project name as title
4. Creates subfolders within the main folder with name: Inbox, Inbox-Src, Inbox-logs, Outbox, Outbox-Src, Outbox-logs
5. Grants the AD account permissions: CreateFiles, WriteExtendedAttributes, WriteAttributes, Delete, ReadAndExecute, Synchronize
6. Transfers the ownership of the folder to the AD account

Note: Should one step in the script fail or is unsuccessfully executed, the script will delete created folders and subfolders.


## Troubleshooting:
### Mounting FSx: Unsuccessful
This means that the FSx Path is not found. \n
Check if FSx command in AWS is correct for the right environment. \n
Check if username and password is pulled correctly from AWS. \n

### Checking AD Account: $ADAccount Not Found 
This means that the AD account provided cannot be found. \n
Check if the AD account provided is valid (Not sure how to check if you cannot access console) \n
\n
For other errors, do check for typos in script.
