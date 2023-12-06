---
external help file: SecurityTools-help.xml
Module Name: SecurityTools
online version:
schema: 2.0.0
---

# Export-ScanReportAggregate

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### all
```
Export-ScanReportAggregate -SystemScan <String> -WebScan <String> -DatabaseScan <String> [<CommonParameters>]
```

### sysdb
```
Export-ScanReportAggregate -SystemScan <String> -DatabaseScan <String> [<CommonParameters>]
```

### sysweb
```
Export-ScanReportAggregate -SystemScan <String> -WebScan <String> [<CommonParameters>]
```

### sys
```
Export-ScanReportAggregate -SystemScan <String> [<CommonParameters>]
```

### webdb
```
Export-ScanReportAggregate -WebScan <String> -DatabaseScan <String> [<CommonParameters>]
```

### web
```
Export-ScanReportAggregate -WebScan <String> [<CommonParameters>]
```

### db
```
Export-ScanReportAggregate -DatabaseScan <String> [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -DatabaseScan
{{Fill DatabaseScan Description}}

```yaml
Type: String
Parameter Sets: all, sysdb, webdb, db
Aliases: DbPath, DbFile, DataBase, D

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemScan
{{Fill SystemScan Description}}

```yaml
Type: String
Parameter Sets: all, sysdb, sysweb, sys
Aliases: SystemPath, SystemFile, System

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WebScan
{{Fill WebScan Description}}

```yaml
Type: String
Parameter Sets: all, sysweb, webdb, web
Aliases: WebPath, WebFile, Web

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
