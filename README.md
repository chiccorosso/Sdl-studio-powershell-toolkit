PowerShell Toolkit
=============

## Introduction
The SDL PowerShell Toolkit allows you to script the [Project Automation API](http://producthelp.sdl.com/SDK/ProjectAutomationApi/3.0/html/b986e77a-82d2-4049-8610-5159c55fddd3.htm) that is available with SDL Trados Studio Professional.  In order to use the Project Automation API via the SDL PowerShell Toolkit , a Professional license for SDL Trados Studio is required.
PowerShell 2.0 comes pre-installed on Windows 7. On Windows XP, you may need to manually install PowerShell if it is not already installed.
## PowerShell Toolkit Structure
The PowerShell Toolkit consists of 4 modules and a sample script:

•	**GetGuids**

•	**PackageHelper**

•	**ProjectHelper**

•	**TMHelper**

A sample script has been provided; Sample_Roundtrip.ps1 which contains examples to create translation memories, projects and packages.

## Installation of PowerShell Toolkit
1.	Ensure SDL Trados Studio with a professional license is installed.
2.	Create the following 2 folders:

    a.	C:\users\{your_user_name}\Documents\windowspowershell
    
    b.	C:\users\{your_user_name}\Documents\windowspowershell\modules
  
3.	Copy the Sample_Roundtrip.ps1 into \windowspowershell.
4.	Copy the four PowerShell module folders into \modules:

    a.	\windowspowershell\modules\GetGuids
  
    b.	\windowspowershell\modules\PackageHelper
    
    c.	\windowspowershell\modules\ProjectHelper
    
    d.	\windowspowershell\modules\TMHelper
  
5.	Please note, the modules are set up for a 32-bit system as SDL Trados Studio runs as a 32-bit application.  Please run the (x86) version of the PowerShell command prompt.
6.	To run on a 64-bit system, the paths in the modules must be changed from **C:\Program Files\SDL\SDL Trados Studio\Studio2\ to C:\Program Files (x86)\SDL\SDL Trados Studio\Studio2\** before running any script. 

## Using the sample script

1.	In the script, ensure the paths to the files to be processed match your directory structure.

2.	Open a PowerShell command prompt as Administrator.

3.	Change to the directory where your script is located:
E.g. C:\users\{your_user_name}\Documents\windowspowershell

4.	Ensure you have rights to run the script. You may first need to enter the following command:
“Set-ExecutionPolicy remotesigned”.

5.	Run your script as follows: Type “.\Sample_Roundtrip” and press enter.

##Contribution

You want to add a new functionality or you spot a bug please fill free to create a [pull request](https://guides.github.com/activities/contributing-to-open-source/) with your changes.

##Issues

If you find an issue you report it [here](https://github.com/sdl/Sdl-studio-powershell-toolkit/issues).

