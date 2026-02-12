# PowerShell-Array-Speed-Test
Test the speed of creating various array types in PowerShell.

By default this script gathers a listing of the `~/Documents` folder.
Then it creates an array of the desired type and returns the elapsed time in Milliseconds that the operation took to complete.


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

## Motivation

After watching the video below by user `Adeel Automates` discussing dotnet arrays in PowerShell, I was inspired to test the results.
This is a great video showing off how fast dotnet arrays are in PowerShell, but see if you can spot how to make his example more efficient based on your testing of various array creation speeds using my `InvokePSArraySpeedTest` function herein.

## Link to related third party video:
[https://youtu.be/IKMoYV7dR-A?si=EHky4bEx0Mo4B1Lp](https://youtu.be/IKMoYV7dR-A?si=EHky4bEx0Mo4B1Lp)
