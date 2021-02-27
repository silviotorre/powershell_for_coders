<#########################################################
#               Esempio di MVC pattern                   #
#                   in Powershell                        #
##########################################################
#                                                        #
#      MVC   : VIEW                                      #
#      Review: Silvio                                    #
#      Date  : march 2021                                #
#                                                        #
#########################################################>



function Test-Node {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory, ParameterSetName = "Nodes", ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string[]] $Node,
    [Parameter(Mandatory, ParameterSetName = "File")]
    [ValidateSet( { Test-Path $_ })]
    [ValidateNotNullOrEmpty()]
    [string] $Path
  )

  begin {
    if ($PSCmdlet.ParameterSetName -eq "File") {
      $Node = Get-Content $Path
    }
  }

  process {
    testNode $_
  }
}

function Start-Troubleshooter {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  [CmdletBinding(SupportsShouldProcess)]
  Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Service
  )

  Write-Host "Welcome! Let's start troubleshooting issues with '$Service'"
  $comfortable = readPromptOption "Are you comfortable troubleshooting this issue?" @("y", "n")
  switch ($comfortable) {
    "y" {
      Write-Host "Good.  Let's start finding bad nodes..."
      $nodes = Get-Content $env:NodeListPath | ? { $_ -like "*$Service*" }
      $auditResults = $nodes | % { testNode $_ }
      Write-Host "Audit complete.`nResults:"
      $auditResults `
      | Sort-Object "Id"  `
      | % { Write-Host $_.Id -ForegroundColor (if ($_.Healthy) { "Green" } else { "Red" }) }
      $badNodes = $auditResults | ? { -not $_.Health }
      if ($badNodes) {
        Write-Host "Found some bad nodes!" -ForegroundColor Red
        $proceed = readPromptOption "Fix all?" @("y", "n")
        if ($proceed) {
          $badNodes | % {
            Invoke-RestMethod -Method Get -Uri "$env:AutohealWebhookUri&computer=$($_.Id)"
          }
          Write-Host "Successfully completed" -ForegroundColor Green
        }
        else {
          Write-Host "Ending without taking action." -ForegroundColor Yellow
        }
      }
      else {
        Write-Host "All clear! This is probably an application layer issue" -ForegroundColor Green
      }
    }
    "n" {
      if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
        Invoke-RestMethod -Method Get -Uri $env:EscalationWebHookUri
      }
      Write-Host "Don't worry.  We've escalated the issue to avoid preventable accidents."
    }
  }

}
