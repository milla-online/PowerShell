$vlans=@();
Get-VDPortgroup | Where-Object -FilterScript { $_.IsUplink -eq $false } | 
%{if ($_.VlanConfiguration.VlanType -like "*Vlan*") 
{ $vlans+=$_.VlanConfiguration.VlanId } 
else 
{ foreach ($range in $_.VlanConfiguration.Ranges) 
{ for ($i=$range.StartVlanId; $i -le $range.EndVlanId;$i++) 
{$vlans+=$i}
}
}
};
$vlans | Sort-Object -Unique