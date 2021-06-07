Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$Expert = false
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

$Items1 = "Pinch-Point-dT  [°C]",
"Approach  [°C]",
"ECO Pressure Drop  [bar]",
"Pressure Drop betw. ECO & SG  [bar]",
"SG Pressure Drop  [bar]",
"Pressure Drop betw. SG & SH  [bar]",
"SH Pressure Drop  [bar]",
"Pressure Drop betw. SH_out and Turbine_in  [bar]",
"SG Steam Quality Outlet  [%]",
"Required Reheater LMTD  [°C]"

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
$Combobox1.Items.AddRange(@("ThVP1", "Hel_XLP"))
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

$Combobox2.Add_SelectedIndexChanged({ if ($Form1.Visible) { Read-Inputs2 } })

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
$Button3.text = "Expert"
$Button3.width = 100
$Button3.height = 25
$Button3.location = New-Object System.Drawing.Point(230, $Y)

$Form.controls.AddRange(@($Button1, $Button2, $Button3))

$Y = 15
$YOffset = 24
$Form1 = New-Object system.Windows.Forms.Form
$Form1.FormBorderStyle = "FixedDialog"
$Form1.Size = '360,300'
$Form1.MinimumSize = '360,300'
$Form1.MaximumSize = '360,300'
$Form1.text = "Expert values"
$Form1.TopMost = $true
$Form1.StartPosition = "WindowsDefaultLocation" #loads the window in the center of the screen

foreach ($Item in $Items1) {
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
  $Form1.controls.AddRange(@($TextBox, $label))
}

$Button1.Add_Click({
   Run-HTML
 # $Form.Close()
})

$Button2.Add_Click({
   Run-PDF
 # $Form.Close()
})

$Button3.Add_Click({
  if ($Form1.Visible) {
    $Form1.Hide()
  } else {
    $Form1.Show()
    Read-Inputs2
    $Expert = true
  }
})

Function New-Process {
    $P = new-object System.Diagnostics.Process
    $P.StartInfo.Filename = "C:\bin\PinchPointTool.exe"
    $P.StartInfo.RedirectStandardOutput = $true;
    $P.StartInfo.RedirectStandardInput = $true;
    $P.StartInfo.UseShellExecute = $false;
    return $P;
}

Function Read-Inputs {
    $P = New-Process;
    $P.StartInfo.Arguments = "-json", "-case 1"
    $P.start()
    $text = $P.StandardOutput.ReadToEnd()
    $start = $text.IndexOf("{")
    $length = $text.LastIndexOf("}") - $start + 1
    $text = $text.Substring($start, $length)
    $json = $text | ConvertFrom-Json
    $Array = @($json.economizerFeedwaterTemperature,
        $json.turbine.massFlow, $json.turbine.temperature, $json.turbine.pressure,
        $json.blowDownOfInputMassFlow,
        $json.reheatInlet.temperature ,$json.reheatInlet.pressure ,$json.reheatInlet.enthalpy ,$json.reheatInlet.massFlow,
        $json.reheatOutletSteamPressure, $json.upperHTFTemperature
    )
    $idx = 0
    $Form.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
        $_.Text = $Array[$idx]
        $idx = $idx + 1
    })
}

Function Read-Inputs2 {
    $Selected = @()
    $Form.Controls.where{$_ -is [System.Windows.Forms.ComboBox]}.ForEach({
    $Selected += , ($_.SelectedIndex+1)
    })
    $P = New-Process;
    $P.StartInfo.Arguments = "-json", "-case", $Selected[1]
    $P.start()
    $text = $P.StandardOutput.ReadToEnd()
    $start = $text.IndexOf("{")
    $length = $text.LastIndexOf("}") - $start + 1
    $text = $text.Substring($start, $length)
    $json = $text | ConvertFrom-Json
    $Array = @($json.parameter.temperatureDifferenceHTF, $json.parameter.temperatureDifferenceWater,
        $json.parameter.pressureDrop.economizer ,
        $json.parameter.pressureDrop.economizer_steamGenerator ,
        $json.parameter.pressureDrop.steamGenerator ,
        $json.parameter.pressureDrop.steamGenerator_superHeater ,
        $json.parameter.pressureDrop.superHeater ,
        $json.parameter.pressureDrop.superHeater_turbine ,
        $json.parameter.steamQuality , $json.parameter.requiredLMTD)
    $idx = 0
    $Form1.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
        $_.Text = $Array[$idx]
        $idx = $idx + 1
    })
}

Function Run-HTML {
    $P = New-Process;
    [string[]] $Arguments = @()
    $form.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
        $Arguments += $_.Text
    })
    if ($Expert) {
        $Form1.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
         $Arguments += $_.Text
        })
        $Arguments += "-hex"
    } else {
        $Arguments += "-case"
        $Arguments += $ComboBox2.Text
    }
    $Arguments += "-htf"
    $Arguments += $ComboBox1.Text

    $Arguments += "-html"
    $Arguments = $Arguments.Trim()
    $P.StartInfo.Arguments = $Arguments
    $P.start()
    $P.WaitForExit()
    write-host $P.TotalProcessorTime
    $html = $P.StandardOutput.ReadToEnd().Trim()
    $start = $html.LastIndexOf([Environment]::NewLine)
    if ($start -gt 0) {
      $path = $html.Substring($start).Trim()
    } else {
      $path = $html.Trim()
    }
    write-host $html
    Start-Process ((Resolve-Path $path).Path)
}

Function Run-PDF {
    $P = New-Process;
    [string[]] $Arguments = @()
    $form.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
        $Arguments += $_.Text
    })
    if ($Expert) {
        $Form1.Controls.where{$_ -is [System.Windows.Forms.TextBox]}.ForEach({
         $Arguments += $_.Text
        })
        $Arguments += "-hex"
    } else {
        $Arguments += "-case"
        $Arguments += $ComboBox2.Text
    }
    $Arguments += "-htf"
    $Arguments += $ComboBox1.Text

    $Arguments += "-pdf"
    $Arguments = $Arguments.Trim()
    $P.StartInfo.Arguments = $Arguments
    $P.start()
    $P.WaitForExit()
    write-host $P.TotalProcessorTime
    Start-Process ((Resolve-Path ".\diagram.pdf").Path)
    Start-Process ((Resolve-Path ".\plot.pdf").Path)
}

Read-Inputs

[void]$Form.ShowDialog()
