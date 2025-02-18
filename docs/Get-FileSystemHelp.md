---
Module Name: linuxinfo
online version: https://github.com/ehmiiz/linuxinfo
schema: 2.0.0
---

# Get-FileSystemHelp

## SYNOPSIS

## SYNTAX

### Name (Default)
```
Get-FileSystemHelp [-Name] <Object> [-Go] [-Full] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-FileSystemHelp [-All] [-Full] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Will display helpful information regarding the linux root directorys

## EXAMPLES

### EXAMPLE 1
```
ldexplain bin
    Uses the alias "ldexplain" and the mandatory parameter "Name" to display
    information regarding the bin directory
```

### EXAMPLE 2
```
ldexplain etc -go
    Uses the alias "ldexplain" and the mandatory parameter "Name" to display
    information regarding the etc directory, uses switch paramter "go" to set
    the location to \etc
```

### EXAMPLE 3
```
ldexplain -all
    Uses the alias "ldexplain" and the switch paramter "all" to display information
    regarding all root directorys in the linux filesystem
```

### EXAMPLE 4
```
ldexplain root -f
    Uses the alias "ldexplain" and the switch paramter "Full" to display the full
    information regarding all root directorys in the linux filesystem
```

## PARAMETERS

### -Name
{{ Fill Name Description }}

```yaml
Type: Object
Parameter Sets: Name
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Go
{{ Fill Go Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
{{ Fill All Description }}

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Full
{{ Fill Full Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
