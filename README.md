# PowerShell-Array-Speed-Test
Test the speed of creating various array types in PowerShell
By default this script gathers a listing of the ~/Documents folder.
Then it creates an array of the desired type and returns the elapsed
time in Milliseconds that the operating took to complete.


## EXAMPLE
```
# First, import the module. Adjust path as needed
import-Module ~/Downloads/Invoke-PSArraySpeedTest.ps1 -Force -Verbose

# run the default test which creates an array using PSCustomObject
Invoke-PSArraySpeedTest
```
## EXAMPLE

```
Invoke-PSArraySpeedTest -ArrayType All
```
