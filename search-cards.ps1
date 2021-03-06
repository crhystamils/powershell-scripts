if($args[0]){
    $directorio = $args[0]
}else{
    $directorio = "."
}
$date = $(Get-Date )
$head = "-------------------- file --------------------"
if((Get-Item result.log) -eq $False){
New-Item -ItemType file -Path . -Name result.log
}

function files($directorio){
    foreach ($item in Get-ChildItem $directorio -ErrorAction silentlycontinue){
        #write-host $item.fullname
        if($item.mode.substring(0,1) -eq "d"){
            files($item.fullname)
        }else{
            if (Get-Item $item.fullname -exclude *.exe, *.msi, *.ps1, *.dll, *.xsd, *.mui,*.ecf, *.ttf, *.db, *.ini, *.inf, *.acw, *.bat, *.jpg, *.png,*.bmp, *.gif, *.psd, *.ai, *.svg, *.mpg, *.bkf, *.grp, *.mp3, *.wma, *.mid, *.wsh, *.wav, *.aac, *.ac3, *.ogg, *.tmp,*.log, *.cnf, *.lnk, *.jar, *.class , *.java, *.jsa){
                if (Select-String -Path $item.fullname -Pattern "[0-9]{16}","[0-9]{4}[-| ][0-9]{4}[-| ][0-9]{4}[-| ][0-9]{4}"){           
                $head >> result.log 
                $date >> result.log
                $item.fullname >> result.log
                Select-String -Path $item.fullname -Pattern "[0-9]{16}","[0-9]{4}[-| ][0-9]{4}[-| ][0-9]{4}[-| ][0-9]{4}" -allmatche |foreach{if(LuhnValidation(parser($_.matches[0].value))){$_ >> result.log }} 
                
                }
            }
        }
    }
}

function LuhnValidation($numero){
    $Number = $numero
   
    if(($Number.Length % 2) -ne 0){
        $Number = $Number.Insert(0, 0)
    }
    
    $Length = $Number.Length
    $Regex = "(\d)" * $Length
    
    if($Number -match $Regex){
        $Sum = 0
        $OrigMatches = $Matches
    
        for($i = 1; $i -lt $OrigMatches.Count; $i++){
            if(($i % 2) -ne 0){
                $digit = ([int]::Parse($OrigMatches[$i]) * 2)
                if($digit.ToString() -match '(\d)(\d)'){
                   $digit = [int]::Parse($Matches[1]) + [int]::Parse($Matches[2])
                }
            }else {
                $digit = [int]::Parse($OrigMatches[$i])
            }
            $Sum += $digit
        }
        if(($Sum % 10) -eq 0){
          return $True
        }else {
           return $False
        }
    } else{
        return $False
    }
}

function parser($numcard){
    $number = $numcard
    $salida = "";
    #write-host $number
    if($number -match "-"){
        $salida = $number.split("-") -join ''
    }elseif($number -match " "){        
        $salida = $number.split() -join ''
    }else{
        $salida = $number
    }    
    return $salida
}

files($directorio);

