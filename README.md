# Office365Tools

Most of the tools in this repository are designed to be run as automations. One of the most reliable ways to do this is via a scheduled task 
that calls Powershell.exe and passes the script location and execution policy as arguments. For anything that connects to Exchange Online using
a Self-Signed Certificate, the account that is used to run the automation must have the certificate installed to that accounts personal Certificate store.
If you miss this step, your automation will not run.

This repository is for all of my Powershell Active Directory tools. If you like them, great! If not and I suck, thanks for stopping by!
