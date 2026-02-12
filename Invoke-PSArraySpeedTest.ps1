Function Invoke-PSArraySpeedTest{

    <#
        .DESCRIPTION
            Test the speed of creating various array types in PowerShell.
            By default this script gathers a listing of the ~/Documents folder.
            Then it creates an array of the desired type.

        .EXAMPLE
        #Import the module. Adjust path as needed
        import-Module ~/Downloads/Invoke-PSArraySpeedTest.ps1 -Force -Verbose

        # run the default test which creates an array using PSCustomObject
        Invoke-PSArraySpeedTest

        .EXAMPLE
        Invoke-PSArraySpeedTest -ArrayType All

    #>

    [CmdletBinding()]
    Param(

        #String. Optionally provide the path to gather file list from. This file object listing will be used when creating arrays.
        [ValidateScript({Test-Path $_})]
        [string]$path = "~/Documents",

        #String. Type or tab-complete the desired type of test to run.
        [ValidateSet('All','PSCustomObject','DotNet','PlusEquals','DotNetSlow')]
        [string]$ArrayType = 'PSCustomObject'
    )

    Process{

        ## Handle gathering of some object
        Write-Verbose -Message ('Getting list of files from {0}' -f $path)
        $list = Get-ChildItem -Path $Path -Recurse
        
        ## helper function to create PSCusomtObject array
        Function New-ArrayAsPSCustomObject{

            [CmdletBinding()]
            param(
                [object]$InputObject
            )
            Process{

                ## Describe the array type
                $strArrayType = 'PSCustomObject'

                $ElapsedTime = Measure-Command {
                    $objTest = foreach($item in $InputObject){
                        [PSCustomObject]@{
                            Name = $item.Name
                            FullName = $item.FullName
                            CreationTimeUtc = $item.CreationTimeUtc
                        }
                    }

                    if(-not $objTest){
                        Write-Warning -Message ('Problem running test with an array type of {0}.' -f $ArrayType)
                    }
                } | Select-Object -ExpandProperty Milliseconds
                
                if($objTest){
                    Write-Verbose -Message ('Elapsed time was {0} Milliseconds using an array type of "{1}" containing {2} objects.' -f $ElapsedTime, $strArrayType, $objTest.Count)
                    [PSCustomObject]@{
                        ArrayType = $strArrayType
                        ElapsedTimeMilliseconds = $ElapsedTime
                        ObjectCount = $objTest.Count
                    }
                }
            }#End Process
        }#End helper function create PSCustomObject array

        ## helper function to create DotNet array
        Function New-ArrayAsDotNetObject{

            [CmdletBinding()]
            param(
                [object]$InputObject
            )
            Process{

                ## Describe the array type
                $strArrayType ='DotNet'

                ## Create the dotnet array
                $objTest = [System.Collections.Generic.List[object]]::new()

                ## Perform the test using what is argued as the best technique
                ##
                ## Note: You should compare to an "ArrayType" of "PSCustomObject" which is likely even faster. 
                $ElapsedTime = Measure-Command {
                    foreach($item in $list){
                        $null = $objTest.Add([PSCustomObject]@{
                            Name = $item.Name
                            FullName = $item.FullName
                            CreationTimeUtc = $item.CreationTimeUtc
                        })
                    }
                } | Select-Object -ExpandProperty Milliseconds

                if($objTest){
                    Write-Verbose -Message ('Elapsed time was {0} Milliseconds using an array type of "{1}" containing {2} objects.' -f $ElapsedTime, $strArrayType, $objTest.Count)
                    [PSCustomObject]@{
                        ArrayType = $strArrayType
                        ElapsedTimeMilliseconds = $ElapsedTime
                        ObjectCount = $objTest.Count
                    }
                }
            }#End Process
        }#End helper function create DotNet array

        ## helper function to create the += style array
        Function New-ArrayAsPlusEqualsObject{

            [CmdletBinding()]
            param(
                [object]$InputObject
            )
            Process{

                ## Describe the array type
                $strArrayType = 'PlusEquals'

                ## Arguably the most picked on technique. It is traditionally slow, but is better in PowerShell Core.
                $ObjTest = @()
                $ElapsedTime = Measure-Command {
                    foreach($item in $list){      
                        $info = [PSCustomObject]@{
                            Name = $item.Name
                            FullName = $item.FullName
                            CreationTimeUtc = $item.CreationTimeUtc
                        }
                        $objTest += $info
                    }
                } | Select-Object -ExpandProperty Milliseconds
                
                if($objTest){
                    Write-Verbose -Message ('Elapsed time was {0} Milliseconds using an array type of "{1}" containing {2} objects.' -f $ElapsedTime, $strArrayType, $objTest.Count)
                    [PSCustomObject]@{
                        ArrayType = $strArrayType
                        ElapsedTimeMilliseconds = $ElapsedTime
                        ObjectCount = $objTest.Count
                    }
                }
            }#End Process
        }#End helper function create the += style array

        ## helper function to create DotNetSlow array (slow only beacuse it uses "Out-Null")
        Function New-ArrayAsDotNetSlowObject{

            [CmdletBinding()]
            param(
                [object]$InputObject
            )

            Process{

                ## Describe the array type
                $strArrayType = 'DotNetSlow'

                ## Create the dotnet array.
                $objTest = [System.Collections.Generic.List[object]]::new()
                
                ## This section may result in a slower than expected result due to piping to "Out-Null". This is intentional for this test. 
                $ElapsedTime = Measure-Command {
                    foreach($item in $list){
                        $objTest.Add([PSCustomObject]@{
                            Name = $item.Name
                            FullName = $item.FullName
                            CreationTimeUtc = $item.CreationTimeUtc
                        }) | Out-Null
                    }
                } | Select-Object -ExpandProperty Milliseconds
                
                if($objTest){
                    Write-Verbose -Message ('Elapsed time was {0} Milliseconds using an array type of "{1}" containing {2} objects.' -f $ElapsedTime, $strArrayType, $objTest.Count)
                    [PSCustomObject]@{
                        ArrayType = $strArrayType
                        ElapsedTimeMilliseconds = $ElapsedTime
                        ObjectCount = $objTest.Count
                    }
                }
            }#End Process
        }#End helper function create DotNetSlow array

        ## Announce
        if($ArrayType -eq 'All'){
            Write-Verbose -Message 'Performing "All" array tests..'
        }
        Else{
            Write-Verbose -Message ('Performing {0} array test...' -f $ArrayType)
        }

        ## Do the action to create the desired array type
        switch($ArrayType){
            'PSCustomObject'{
                New-ArrayAsPSCustomObject -InputObject $list
            }
            'DotNet'{
                New-ArrayAsDotNetObject -InputObject $list
            }
            'PlusEquals'{
                New-ArrayAsPlusEqualsObject -InputObject $list
            }
            'DotNetSlow'{
                New-ArrayAsDotNetSlowObject -InputObject $list
            }
            'All'{
                New-ArrayAsPSCustomObject -InputObject $list
                New-ArrayAsDotNetObject -InputObject $list
                New-ArrayAsPlusEqualsObject -InputObject $list
                New-ArrayAsDotNetSlowObject -InputObject $list
            }
            'Default'{
                ## technically cannot land here due to ValidateSet in the param section.
                Write-Warning -Message 'Cannot determine "ArrayType".'
                exit 1
            }
        }#End Switch
    }#End Process
}#End Function