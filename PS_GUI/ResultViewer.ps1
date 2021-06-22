Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$global:Day = 1
$global:desktop = [Environment]::GetFolderPath("Desktop")
$form = new-object Windows.Forms.Form
$form.MaximizeBox = $false;
$form.MinimizeBox = $false;
$form.AutoSize = $true
$form.AutoSizeMode = "GrowOnly"
$form.StartPosition = 'CenterScreen'
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width = 1573
$pictureBox.Height =  960
$form.controls.add($pictureBox)

$FolderBrowser = new-object system.windows.forms.folderbrowserdialog
$FolderBrowser.StartPosition = 'CenterScreen'
$global:currentPath = "$global:desktop\Results\"
$global:otherPath = "$global:desktop\Results\"

Function Load-PNG() {
    $form.Text = "Day $global:Day"
    $Picture = Get-Item "$global:currentPath\*Summer$global:Day.png" -ErrorAction SilentlyContinue
    if ($Picture.Exists) {
        $img = [System.Drawing.Image]::Fromfile($Picture)
        $pictureBox.Image = $img
    }
}

$form.Add_KeyDown({
    if ($_.KeyCode -eq "Space") {
        if ($global:otherPath -eq $global:currentPath) {

            $FolderBrowser.ShowDialog()
            $global:otherPath = $global:currentPath
            $global:currentPath = $FolderBrowser.SelectedPath

        } else {
            $temp = $global:currentPath
            $global:currentPath = $global:otherPath
            $global:otherPath = $temp
        }
        Load-PNG
    }
}
)

$form.Add_KeyDown(
    {
        if ($_.KeyCode -eq "Home") {
            $global:Day = 1
            Load-PNG
        }
    }
)

$form.Add_KeyDown(
    {
        if ($_.KeyCode -eq "End") {
            $global:Day = 365
            Load-PNG
        }
    }
)

$form.Add_KeyDown(
    {
        if ($_.KeyCode -eq "Left" -and $global:Day -gt 1) {$global:Day -= 1}
        if ($_.KeyCode -eq "Right" -and $global:Day -lt 365) {$global:Day += 1}
        if ($_.KeyCode -eq "Down" -and $global:Day -gt 10) {$global:Day -= 10}
        if ($_.KeyCode -eq "Up" -and $global:Day -lt 355) {$global:Day += 10}
        Load-PNG
    }
)

$form.Add_KeyDown(
    {
        if ($_.KeyCode -eq "Escape" -and $global:Day -lt 355) {
            $FolderBrowser.ShowDialog()
            $global:currentPath = $FolderBrowser.SelectedPath
            Load-PNG
        }
    }
)

$FolderBrowser.ShowDialog()
$global:currentPath = $FolderBrowser.SelectedPath
$global:otherPath = $FolderBrowser.SelectedPath

Load-PNG
$form.Add_Shown( { $form.Activate() } )
$form.ShowDialog()
