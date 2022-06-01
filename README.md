xampp-control-panel-windows
===========================

The XAMPP control panel is a little Delphi application that helps on the daily usage of XAMPP on Windows. Apart from starting and stopping services, it provides extended features like installing the component as a Windows service, checking the logs or launching a cmd console with a preloaded environment in which you can run maintenance commands.

This tool was originally created by Steffen Strueber.

## Building XAMPP control panel for Windows

The XAMPP control panel for Windows is currently built using the [Delphi 10 software](https://downloads.embarcadero.com/Item/30352) trial version. The basic workflow for building the XAMPP control panel is listed below:

- Open with Delphi 10 (or double click) the `/path_to_xampp/src/xampp-control-panel/xampp_control3.dproj` project.
- Click Project > Compile `xampp_control3`.
- Click Project > Build `xampp_control3`.

You will find the executable inside `/path_to_xampp/src/xampp-control-panel`

### Manual installation of requirements for building the XAMPP Control panel

Requirements:

- .NET Framework 3.5.
- Delphi 10 Seattle (Trial)
- JEDI Code Library
- XAMPP Control Panel source code

#### .NET framework 3.5

Download and install the official installer from [Windows downloads site](https://www.microsoft.com/en-us/download/details.aspx?id=25150)

#### Install Delphi 10 Seattle (Trial)

Download the ISO from the official site at [Embarcadero downloads](https://downloads.embarcadero.com/Item/30352). Simply mount the ISO and then install it. Neither the "Additional Platform Support" nor the "ThirdParty Addons" are needed.

#### Compile JEDI Code Library dependency (2.7.0.5676)

This is a set of utility funcitions for Delphi and C++ projects. You can read more information on this in [the official Wiki entry](https://wiki.delphi-jedi.org/wiki/JEDI_Code_Library). Since the trial version of Delphi doesn't allow compilations from the command line, that should be done manually using the UI.

Download the latest version from its [Sourceforge project](https://sourceforge.net/projects/jcl/files/JCL%20Releases/), and open the file at `/path_to_jcl/packages/JclPackagesD230` with Delphi 10 (or double click). Follow the next steps to compile it.

* Click the `Project` > `Compile All Projects` menu option
* Click the `Project` > `Build All Projects` menu

Finally check the `/path_to_jcl/lib/d23/win32` directory is not empty and contains .dcu files.

##### Compile XAMPP Control Panel

Open with Delphi 10 (or double click) the `/path_to_xampp/src/xampp-control-panel/xampp_control3.dproj` project, and follow the next steps to generate the XAMPP control panel executable:

* Click the `Tools` > `Options…` menu option.
* Go to `Delphi Options` > `Library` section.
* Click the `[…]` button of `Library path`.
* Add the following paths.
  * `/path_to_jcl/source/common`
  * `/path_to_jcl/source/windows`
  * `/path_to_jcl/source/include`
  * `/path_to_jcl/lib/d23/win32`
* Click `Project` > `Compile xampp_control3`.
* Click `Project` > `Build xampp_control3`.

You will find the executable inside the `/path_to_xampp/src/xampp-control-panel` folder.

## Testing the new version

You can replace the new control panel in any XAMPP installation and run it from there to verify your changes. Stop the running XAMPP services and processes (if any) before replacing the executable.

## Distributing the new XAMPP control panel version

The XAMPP control panel is packed in the XAMPP Windows installer during the installer generation process. For the new version to be used, please upload a tarball including the source code and the generated binary to the `s3://apachefriends/tarballs/xampp-control-panel/` bucket.

The name of the tarball should be `xampp-control-panel-windows-{SET_VERSION_HERE}.tar.gz` and the next folder structure

```bash
/
├── xampp-control.exe
└── src/ # place the updated source code here
```
