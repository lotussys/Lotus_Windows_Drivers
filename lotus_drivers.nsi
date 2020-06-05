# Lotus Board Driver NSIS Install Script
# Author: Timothy Luo

# Import some useful functions.
!include WinVer.nsh   # Windows version detection.
!include x64.nsh      # X86/X64 version detection.

!define VERSION 6.5.0.0

# Set attributes that describe the installer.
Icon "Assets\lotus.ico"
Caption "Lotus Board Drivers"
Name "Lotus board drivers"
Outfile "lotus_drivers_${VERSION}.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

# Install driver files to a temporary location (then dpinst will handle the real install).
InstallDir "$TEMP\lotus_drivers"

# Set properties on the installer exe that will be generated.
VIAddVersionKey /LANG=1033 "ProductName" "Lotus Board Drivers"
VIAddVersionKey /LANG=1033 "CompanyName" "Lotus Communication Systems"
VIAddVersionKey /LANG=1033 "LegalCopyright" "Lotus Communication Systems"
VIAddVersionKey /LANG=1033 "FileDescription" "All in one installer for Lotus board drivers."
VIAddVersionKey /LANG=1033 "FileVersion" "6.5.0.0"
VIProductVersion ${VERSION}
VIFileVersion ${VERSION}

# Define variables used in sections.
Var dpinst   # Will hold the path and name of dpinst being used (x86 or x64).


# Define the standard pages in the installer.
# License page shows the contents of license.rtf.
PageEx license
  LicenseData "license.rtf"
PageExEnd

# Components page allows user to pick the drivers to install.
PageEx components
  ComponentText "Check the board drivers below that you would like to install.  Click install to start the installation." \
    "" "Select board drivers to install:"
PageExEnd

# Instfiles page does the actual installation.
Page instfiles


# Sections define the components (drivers) that can be installed.
# The section name is displayed in the component select screen and if selected
# the code in the section will be executed during the install.
# Note that /o before the name makes the section optional and not selected by default.

# This first section is hidden and always selected so it runs first and bootstraps
# the install by copying all the files and dpinst to the temp folder location.
Section
  # Copy all the drivers and dpinst exes to the temp location.
  SetOutPath $INSTDIR
  File /r "Drivers"
  File "dpinst-x64.exe"
  File "dpinst-x86.exe"
  # Set dpinst variable based on the current OS type (x86/x64).
  ${If} ${RunningX64}
    StrCpy $dpinst "$INSTDIR\dpinst-x64.exe"
  ${Else}
    StrCpy $dpinst "$INSTDIR\dpinst-x86.exe"
  ${EndIf}
SectionEnd

Section "All other Lotus boards" USBSER_BOARDS
  # Use dpinst to install the driver.
  # Note the following options are specified:
  #  /sw = silent mode, hide the installer but NOT the OS prompts (critical!)
  #  /path = path to directory with driver data
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Drivers\Lotus_usbser"'
SectionEnd

# Unselect, disable, and hide the given section.
!macro HideSectionMacro SectionId
  SectionSetFlags ${SectionId} ${SF_RO}
  SectionSetText ${SectionId} ""
!macroend

!define HideSection '!insertMacro HideSectionMacro'

Function .onInit
  # Hide all drivers that aren't needed in Windows 10.
FunctionEnd
