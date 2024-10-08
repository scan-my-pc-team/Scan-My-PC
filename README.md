# scan-my-pc
Just a simple PowerShell script to check your PC's specs. It will list your:

* General PC Info
    * Hostname
    * Serial Number
    * Operating System
    * OS Version
    * Build Number
    * Registered User 
    * OS Architecture
* CPU
    * Name
    * Manufacturer
    * Description
    * Number of Cores
    * Number of Logical Processors
    * Max Clock Speed
* GPU
    * Manufacturer
    * Model
    * VRAM
* RAM
    * Total Capacity
    * Speed
    * Manufacturer
    * Serial Number
* Motherboard
    * Manufacturer
    * Model
    * Serial Number
    * Version
* Storage (Includes all drives)
    * Model
    * Size
    * Serial Number
    * Interface Type
* All Active USB Devices
    * Name
    * PNPClass
* Mapped Network Drives
    * Local Name
    * Remote Path
    * Description
    * Status
* Installed Applications
    * Application Name
    * Version
    * Publisher

## How to Run

1. Clone the repo or download the `scanmypc.ps1` file.
2. Right-click on the file.
3. Select "**_Run with PowerShell_**".
4. Done!

**NOTE:** A `.txt` file should appear in a folder named `PCScan` on your Desktop containing your PC's specs.

## What Should I Do If It Doesn't Run?

1. You need to run it as **admin**.
2. Ensure you can execute scripts on the device with:
    ```powershell
    Set-ExecutionPolicy Unrestricted
    ```
3. Press `YES` to all prompts.

**NOTE:** Don't forget to set it back to `Restricted` once finished:
```powershell
Set-ExecutionPolicy Restricted
```
---
## Possible Issues:
### Directory doesn't exist
If it can't find a directory to save a `.txt` file, you need to **change path** to **desktop** in the script.
Make sure to use **absolute** path for that. The variable for the path called `$outputFile`. Don't forget to 
keep `\system_info.txt` at the end of the path. Example:
```cmd
"path\to\Desktop\system_info.txt"
```
### A lot of active USB devices?
It displays all active drivers/USBs ports as I understand. This is why you might see some weird stuff. It also displays 
integrated cameras on laptops, so just take a note of that.

Usually keyboards and mice have weird names like `DSJDS345` or sometimes it can display them properly 
like: `Razer Hunstman Mini`. Don't be scared to see that :)
 
## Authors
[ArtemKech](https://github.com/ArtemKech)
[DeadDove13](https://github.com/DeadDove13)  
