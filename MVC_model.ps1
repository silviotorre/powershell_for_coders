class Computer {
  [string] $Service
  [string] $ClusterId
  [string] $DatacenterId
  [string] $Id
  Computer([string]$Id) {
    $this.Id = $Id
    if ($Id -notmatch "(\w+)(\d+)(\w+\d+)") {
      throw "Invalid Computer ID '$Id'"
    }
    $_, $this.Namespace, $this.ClusterId, $this.DatacenterId = $Matches
  }
}

class AuditResult {
  [boolean] $Healthy
  [Computer] $Computer
}
