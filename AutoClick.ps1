param( [int]$Duration, [int]$Count, [int]$Pause = 20, [switch]$Force )

## TODO: Add comments

$Helptext=@'
  Usage: AutoClick [duration_in_seconds] [-p ]
     OR: AutoClick -c [number of clicks to send]
'@

if (!($Duration -gt 0 -or $Count -gt 0)) {
  write-host $Helptext
  exit
} 

elseif(($Duration -gt 120 -or $Count -gt 6000) -and ! $Force) {
  write-host "Will not click more than 6000 times or for more than 120 seconds without -Force option"
  exit
}


else {
  # Init some globals
  $tally = 0
  $signature=@' 
    [DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
    public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

  $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru
  $StartTime = $Now = Get-Date 
  $EndTime = $Now + $(New-Timespan -seconds $Duration)
}

function Main {
  if ($Duration -gt 0) {
    while ($Now -lt $EndTime) {
      DoClick
    }
  }
  else {
    while ($tally -lt $Count) {
      DoClick
    }
  }
  $elapsed = $(New-Timespan $StartTime $Now).TotalSeconds
  write-host "Sent $tally clicks in $elapsed seconds"
}


function DoClick() {
  $SCRIPT:SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0)
  $SCRIPT:SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0)
  Start-Sleep -m $SCRIPT:Pause
  $SCRIPT:Now = Get-Date
  $SCRIPT:tally++
  ##$SCRIPT:tally
}

. Main
