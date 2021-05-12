Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$WidthBox = 60
$HeightBox = 24
$XLabels = 10
$XBoxes = 270
$Y = 15
$YOffset = 24

$Form = New-Object system.Windows.Forms.Form
$Form.FormBorderStyle = "FixedDialog"
$Form.Size = '360,410'
$Form.MinimumSize = '360,410'
$Form.MaximumSize = '360,410'
$Form.text = "Pinch Point Tool"
$Form.TopMost = $true
$Form.StartPosition = "CenterScreen" #loads the window in the center of the screen

#$Calendar = New-Object System.Windows.Forms.

$Items = "ECO Inlet Feedwater Temperature  [°C]",
"Live Steam Massflow  [kg/s]",
"Live Steam Temperature (at turbine inlet)  [°C]",
"Live Steam Pressure (at Turbine inlet)  [bar]",
"Continuous Blow Down of Input Mass Flow  [%]",
"RH Inlet Steam Temperature  [°C]",
"RH Inlet Steam Pressure  [bar]",
"RH Inlet Steam Enthalpy  [kJ/kg]",
"RH Inlet Steam Massflow  [kg/s]",
"RH Outlet Steam Pressure  [bar]",
"HTF HEX inlet temperature  [°C]"

foreach ($Item in $Items) {
  $TextBox = New-Object system.Windows.Forms.TextBox
  $TextBox.multiline = $false
  $TextBox.width = $WidthBox
  $TextBox.height = $HeightBox
  $TextBox.location = New-Object System.Drawing.Point($XBoxes, $Y)

  $label = New-Object system.Windows.Forms.Label
  $label.text = $Item

  $label.AutoSize = $true
  $label.location = New-Object System.Drawing.Point($XLabels, ($Y + 3))
  $Y = $Y + $YOffset
  $Form.controls.AddRange(@($TextBox, $label))
}

$Combobox1 = New-Object 'System.Windows.Forms.ComboBox'
$Combobox1.width = $WidthBox
$Combobox1.Items.AddRange(@("ThVP1", "Hel5a"))
$Combobox1.SelectedIndex = 0
$Combobox1.location = New-Object System.Drawing.Point($XBoxes, $Y)
$label1 = New-Object system.Windows.Forms.Label
$label1.text = "HTF Fluid"
$label1.AutoSize = $true
$label1.location = New-Object System.Drawing.Point($XLabels, ($Y + 3))
$Y = $Y + $YOffset
$Form.controls.AddRange(@($Combobox1, $label1))

$Combobox2 = New-Object 'System.Windows.Forms.ComboBox'
$Combobox2.width = $WidthBox
$Combobox2.Items.AddRange(@("1", "2", "3"))
$Combobox2.SelectedIndex = 0
$Combobox2.location = New-Object System.Drawing.Point($XBoxes, $Y)
$label2 = New-Object system.Windows.Forms.Label
$label2.text = "HEX CASE"
$label2.AutoSize = $true
$label2.location = New-Object System.Drawing.Point($XLabels, ($Y + 3))
$Y = $Y + $YOffset
$Form.controls.AddRange(@($Combobox2, $label2))
$Y = $Y + 10

$Button1 = New-Object system.Windows.Forms.Button
$Button1.text = "Calculate"
$Button1.width = 100
$Button1.height = 25
$Button1.location = New-Object System.Drawing.Point(10, $Y)

$Button2 = New-Object system.Windows.Forms.Button
$Button2.text = "PDF"
$Button2.width = 100
$Button2.height = 25
$Button2.location = New-Object System.Drawing.Point(120, $Y)

$Button3 = New-Object system.Windows.Forms.Button
$Button3.text = "Excel"
$Button3.width = 100
$Button3.height = 25
$Button3.location = New-Object System.Drawing.Point(230, $Y)

$Form.controls.AddRange(@($Button1, $Button2, $Button3))

$Button1.Add_Click({
   Run-Tool
 # $Form.Close()
})

$Button2.Add_Click({
   Run-PDF
 # $Form.Close()
})

$Button3.Add_Click({
   Run-Excel
 # $Form.Close()
})

Function Read-Inputs {
  $P = new-object System.Diagnostics.Process
  $P.StartInfo.Filename = "C:\bin\PinchPointTool.exe"
  $P.StartInfo.Arguments = "-json"
  $P.StartInfo.RedirectStandardOutput = $true;
  $P.StartInfo.UseShellExecute = $false
  $P.start()
  $text = $P.StandardOutput.ReadToEnd()
  $start = $text.IndexOf("{")
  $length = $text.LastIndexOf("}") - $start + 1
  $text = $text.Substring($start, $length)
  $json = $text | ConvertFrom-Json
  $idx = 0
  $Array = @($json.economizerFeedwaterTemperature,
    $json.ws.massFlow, $json.ws.temperature, $json.ws.pressure,
    $json.blowDownOfInputMassFlow,
    $json.reheatInlet.temperature ,$json.reheatInlet.pressure ,$json.reheatInlet.enthalpy ,$json.reheatInlet.massFlow,
    $json.reheatOutletSteamPressure, $json.upperHTFTemperature
  )

  $Form.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
    $_.Text = $Array[$idx]
    $idx = $idx + 1
  })
}

Function Run-Tool {
    $P = new-object System.Diagnostics.Process
    $P.StartInfo.Filename = "C:\bin\PinchPointTool.exe"
    $P.StartInfo.RedirectStandardOutput = $true;
    $P.StartInfo.RedirectStandardInput = $true;
    $P.StartInfo.UseShellExecute = $false;
    [string[]] $Array = @("-html")
    $form.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
        $Array += $_.Text
    })
    $Array = $Array.Trim()
    $Array += "-htf"
    $Array += $ComboBox1.Text
    $Array += "-case"
    $Array += $ComboBox2.Text
    $P.StartInfo.Arguments = $Array
    $P.start()
    $P.WaitForExit()
    $html = $P.StandardOutput.ReadToEnd().Trim()
    $start = $html.LastIndexOf([Environment]::NewLine)
    if ($start -gt 0) {
      $path = $html.Substring($start).Trim()
    } else {
      $path = $html.Trim()
    }
    Start-Process ((Resolve-Path $path).Path)
}

Function Run-PDF {
    $P = new-object System.Diagnostics.Process
    $P.StartInfo.Filename = "C:\bin\PinchPointTool.exe"
    $P.StartInfo.RedirectStandardOutput = $true;
    $P.StartInfo.RedirectStandardInput = $true;
    $P.StartInfo.UseShellExecute = $false;
    [string[]] $Array = @("-pdf")
    $form.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
        $Array += $_.Text
    })
    $Array = $Array.Trim()
    $Array += "-htf"
    $Array += $ComboBox1.Text
    $Array += "-case"
    $Array += $ComboBox2.Text
    $P.StartInfo.Arguments = $Array
    $P.start()
    $P.WaitForExit()
    Start-Process ((Resolve-Path ".\diagram.pdf").Path)
    Start-Process ((Resolve-Path ".\plot.pdf").Path)
}

Function Run-Excel {
    $P = new-object System.Diagnostics.Process
    $P.StartInfo.Filename = "C:\bin\PinchPointTool.exe"
    $P.StartInfo.RedirectStandardOutput = $true;
    $P.StartInfo.RedirectStandardInput = $true;
    $P.StartInfo.UseShellExecute = $false;
    [string[]] $Array = @("-excel")
    $form.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
        $Array += $_.Text
    })
    $Array = $Array.Trim()
    $Array += "-htf"
    $Array += $ComboBox1.Text
    $Array += "-case"
    $Array += $ComboBox2.Text
    $P.StartInfo.Arguments = $Array
    $P.start()
    $P.WaitForExit()
    Start-Process ((Resolve-Path ".\pinchpoint.xlsx").Path)
}


Read-Inputs

[void]$Form.ShowDialog()
