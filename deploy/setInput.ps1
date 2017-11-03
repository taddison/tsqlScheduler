# setInput
param(
    [boolean][parameter(mandatory=$true)] $agMode
) 

$global:server=Read-Host "Enter the local server name"
$global:database=Read-Host "Enter the local database name"
$global:notifyOperator=Read-Host "Enter the name of the operator"

if($agMode){$global:agName=Read-Host "Enter the AG name"}else{$global:agName="x"}
if($agMode){$global:agDatabase="Enter the name of the HIGHLY AVAILABLE database"}else{$global:agDatabase="x"}
# TODO
# parse replicas from servers/AG.json
if($agMode){
    $global:replica="x"
}else{$global:replica="x"}
