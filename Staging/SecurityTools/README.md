# SecurityTools

## Decription

A PowerShell module with tools for information security, digital forensics, and
reporting tasks. Most functions were developed for Windows, however, an effort
was made to support multiple platforms where possible.

Functions range in functionality from conversion and reporting to getting
information from local (Windows Registry, patches, etc.) or remote (IP or domain
registration info) systems.

Several functions were written specifically for organizing and reporting on
vulnerabilities. This includes looking up CVSSv3 scores and Known Exploted
Vulnerability (KEV) lists.

Other functions were written to help review and triage web traffic.

## Lastest Version Notes

### v0.8.9

- Renamed function from Get-RandomAlphanumericString to Get-RandomString
- Added parameters for excluding character types to Get-RandomString
- Added inclusion of special characters to Get-RandomString

### v0.8.8

- Added function Get-AlternateDataStream

### v0.8.7

- Added function Get-KEVList

## Disclaimer

Feel free to create issues or pull requests, however, this project is developed
for use by a specific team of engineers, not for broad use.
