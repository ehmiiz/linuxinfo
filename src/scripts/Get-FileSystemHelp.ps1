$JsonData = @'
{
    "root": "The root filesystem should generally be small, since it contains very critical files and a small, infrequently modified filesystem has a better chance of not getting corrupted. A corrupted root filesystem will generally mean that the system becomes unbootable except with special measures (e.g., from a floppy), so you dont want to risk it.",
    "etc": "The /etc maintains a lot of files. You should determine which program they belong to and read the manual page for that program. Many networking configuration files are in /etc as well, and are described in the Networking Administrators' Guide.",
    "boot": "This directory contains everything required for the boot process except for configuration files not needed at boot time (the most notable of those being those that belong to the GRUB boot-loader) and the map installer. Thus, the /boot directory stores data that is used before the kernel begins executing user-mode programs. This may include redundant (back-up) master boot records, sector/system map files, the kernel and other important boot files and data that is not directly edited by hand.",
    "dev": "The /dev directory contains the special device files for all the devices. The device files are created during installation, and later with the /dev/MAKEDEV script. The /dev/MAKEDEV.local is a script written by the system administrator that creates local-only device files or links (i.e. those that are not part of the standard MAKEDEV, such as device files for some non-standard device driver).",
    "home": "Linux is a multi-user environment so each user is also assigned a specific directory that is accessible only to them and the system administrator. These are the user home directories, which can be found under '/home/$USER' (~/). It is your playground: everything is at your command, you can write files, delete them, install programs, etc.... Your home directory contains your personal configuration files, the so-called dot files (their name is preceded by a dot). Personal configuration files are usually 'hidden', if you want to see them, you either have to turn on the appropriate option in your file manager or run ls with the -a switch. If there is a conflict between personal and system wide configuration files, the settings in the personal file will prevail.",
    "lib": "The /lib directory contains kernel modules and those shared library images (the C programming code library) needed to boot the system and run the commands in the root filesystem, ie. by binaries in /bin and /sbin. Libraries are readily identifiable through their filename extension of *.so. Windows equivalent to a shared library would be a DLL (dynamically linked library) file. They are essential for basic system functionality. Kernel modules (drivers) are in the subdirectory /lib/modules/'kernel-version'. To ensure proper module compilation you should ensure that /lib/modules/'kernel-version'/kernel/build points to /usr/src/'kernel-version' or ensure that the Makefile knows where the kernel source itself are located.",
    "lost+found": "Linux should always go through a proper shutdown. Sometimes your system might crash or a power failure might take the machine down. Either way, at the next boot, a lengthy filesystem check (the speed of this check is dependent on the type of filesystem that you actually use. ie. ext3 is faster than ext2 because it is a journalled filesystem) using fsck will be done. Fsck will go through the system and try to recover any corrupt files that it finds. The result of this recovery operation will be placed in this directory.",
    "media": "This directory contains subdirectories which are used as mount points for removeable media such as floppy disks, cdroms and zip disks.",
    "mnt": "This is a generic mount point under which you mount your filesystems or devices. Mounting is the process by which you make a filesystem available to the system. After mounting your files will be accessible under the mount-point. This directory usually contains mount points or sub-directories where you mount your floppy and your CD. You can also create additional mount-points here if you wish. Standard mount points would include /mnt/cdrom and /mnt/floppy. There is no limitation to creating a mount-point anywhere on your system but by convention and for sheer practicality do not litter your file system with mount-points. It should be noted that some distributions like Debian allocate /floppy and /cdrom as mount points while Redhat and Mandrake puts them in /mnt/floppy and /mnt/cdrom respectively.", 
    "opt": "This directory is reserved for all the software and add-on packages that are not part of the default installation. For example, StarOffice, Kylix, Netscape Communicator and WordPerfect packages are normally found here. To comply with the FSSTND, all third party applications should be installed in this directory. Any package to be installed here must locate its static files (ie. extra fonts, clipart, database files) must locate its static files in a separate /opt/'package' or /opt/'provider' directory tree (similar to the way in which Windows will install new software to its own directory tree C:/Windows/Progam Files/'Program Name'), where 'package' is a name that describes the software package and 'provider' is the provider's LANANA registered name.",
    "proc": "/proc is very special in that it is also a virtual filesystem. It's sometimes referred to as a process information pseudo-file system. It doesn't contain 'real' files but runtime system information (e.g. system memory, devices mounted, hardware configuration, etc). For this reason it can be regarded as a control and information centre for the kernel. In fact, quite a lot of system utilities are simply calls to files in this directory. For example, 'lsmod' is the same as 'cat /proc/modules' while 'lspci' is a synonym for 'cat /proc/pci'. By altering files located in this directory you can even read/change kernel parameters (sysctl) while the system is running.",
    "run": "This directory contains system information data describing the system since it was booted. Files under this directory must be cleared (removed or truncated as appropriate) at the beginning of the boot process.",
    "sbin": "/sbin should contain only binaries essential for booting, restoring, recovering, and/or repairing the system in addition to the binaries in /bin. ",
    "srv": "/srv contains site-specific data which is served by this system. This main purpose of specifying this is so that users may find the location of the data files for particular service, and so that services which require a single tree for readonly data, writable data and scripts (such as cgi scripts) can be reasonably placed.",
    "sys": "Modern Linux distributions include a /sys directory as a virtual filesystem, which stores and allows modification of the devices connected to the system.",
    "tmp": "This directory contains mostly files that are required temporarily. Many programs use this to create lock files and for temporary storage of data. Do not remove files from this directory unless you know exactly what you are doing! Many of these files are important for currently running programs and deleting them may result in a system crash. Usually it won't contain more than a few KB anyway. On most systems, this directory is cleared out at boot or at shutdown by the local system.",
    "usr":  "/usr is shareable, read-only data. /usr usually contains by far the largest share of data on a system. Hence, this is one of the most important directories in the system as it contains all the user binaries, their documentation, libraries, header files, etc.... X and its supporting libraries can be found here. User programs like telnet, ftp, etc.... are also placed here. In the original Unix implementations, /usr was where the home directories of the users were placed (that is to say, /usr/someone was then the directory now known as /home/someone). In current Unices, /usr is where user-land programs and data (as opposed to 'system land' programs and data) are. The name hasn't changed, but it's meaning has narrowed and lengthened from 'everything user related' to 'user usable programs and data'. As such, some people may now refer to this directory as meaning 'User System Resources' and not 'user' as was originally intended.",
    "var": "Contains variable data like system logging files, mail and printer spool directories, and transient and temporary files. Some portions of /var are not shareable between different systems",
    "bin": "Unlike /sbin, the bin directory contains several useful commands that are of use to both the system administrator as well as non-privileged users. It usually contains the shells like bash, csh, etc.... and commonly used commands like cp, mv, rm, cat, ls. For this reason and in contrast to /usr/bin, the binaries in this directory are considered to be essential. The reason for this is that it contains essential system programs that must be available even if only the partition containing / is mounted. This situation may arise should you need to repair other partitions but have no access to shared directories (ie. you are in single user mode and hence have no network access). It also contains programs which boot scripts may depend on."
}
'@
class directorys : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        # Store the data inside the class
        $directoryNames = @{
            "bin"        = "essential user binaries"
            "boot"       = "boot loader files"
            "dev"        = "device files for hardware access"
            "etc"        = "system-global configuration files"
            "home"       = "users home directories"
            "lib"        = "system libraries and kernel modules"
            "lost+found" = "stores corrupted filesystem files"
            "media"      = "mount point for external / removable devices"
            "mnt"        = "temporary mount points" 
            "opt"        = "optional application software packages"
            "proc"       = "procfs - process and kernel information"
            "root"       = "root users home directory"
            "run"        = "stores runtime information"
            "sbin"       = "essential system binaries"
            "srv"        = "services data directories"
            "sys"        = "sysfs - devices and kernel information"
            "tmp"        = "temporary files" 
            "usr"        = "user utilities and applications"
            "var"        = "variable files"
        }

        # Expose variable for the function
        $Script:directorysExplained = $directoryNames

        # return only the names of the hashtable
        return $directoryNames.Keys
    }
}

function Get-FileSystemHelp {
    <#

    .DESCRIPTION
        Will display helpful information regarding the linux root directorys

    .EXAMPLE
        ldexplain bin
            Uses the alias "ldexplain" and the mandatory parameter "Name" to display
            information regarding the bin directory

    .EXAMPLE
        ldexplain etc -go
            Uses the alias "ldexplain" and the mandatory parameter "Name" to display
            information regarding the etc directory, uses switch paramter "go" to set
            the location to \etc
    .EXAMPLE
        ldexplain -all
            Uses the alias "ldexplain" and the switch paramter "all" to display information
            regarding all root directorys in the linux filesystem
    .EXAMPLE
        ldexplain root -f
            Uses the alias "ldexplain" and the switch paramter "Full" to display the full
            information regarding all root directorys in the linux filesystem

    .NOTES
    #>
[CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Name',
            Position = 0)]
        [ValidateSet([directorys], ErrorMessage = "Incorrect directory name: '{0}'Give this a try: {1}")]
        $Name,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Name')]
        [switch]$Go,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'All')]
        [switch]$All,
        [switch]$Full
        
    )

    if ($go) {
        if ($IsLinux) {
            Set-Location /$name
        }
        else {
            Write-Warning 'the "Go" parameter is only supported on Linux'
        }
    }

    if (($All) -or ( -not $Name)) {
        return $Script:directorysExplained
    }
    elseif ($Name -and $Full) {
        $FullInfo = ($JsonData | ConvertFrom-Json).$name
        $return = $Script:directorysExplained | Select-Object $name,@{l='Full';e={$FullInfo}} | Format-Table -Wrap -ErrorAction SilentlyContinue
        return $return
    }
    elseif ($Name) {
        $return = $Script:directorysExplained | Select-Object $name -ErrorAction SilentlyContinue
        return $return
    }
    # The last line of code initilizes the functions param section and generates the script-scoped variables
    Get-FileSystemHelp -All | out-null
}