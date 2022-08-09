# Microsoft Developer Studio Project File - Name="mb2gen" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=mb2gen - Win32 Bytecode
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mb2gen.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mb2gen.mak" CFG="mb2gen - Win32 Bytecode"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mb2gen - Win32 Bytecode" (based on "Win32 (x86) External Target")
!MESSAGE "mb2gen - Win32 Native code" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "mb2gen - Win32 Bytecode"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ""
# PROP BASE Intermediate_Dir ""
# PROP BASE Cmd_Line "ocamake mb2gen.dsp"
# PROP BASE Rebuild_Opt "-all"
# PROP BASE Target_File "mb2gen.exe"
# PROP BASE Bsc_Name ""
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ""
# PROP Intermediate_Dir ""
# PROP Cmd_Line "ocamake mb2gen.dsp -g"
# PROP Rebuild_Opt "-all"
# PROP Target_File "mb2gen.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "mb2gen - Win32 Native code"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ""
# PROP BASE Intermediate_Dir ""
# PROP BASE Cmd_Line "ocamake -opt mb2gen.dsp -o mb2gen_opt.exe"
# PROP BASE Rebuild_Opt "-all"
# PROP BASE Target_File "mb2gen_opt.exe"
# PROP BASE Bsc_Name ""
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ""
# PROP Intermediate_Dir ""
# PROP Cmd_Line "ocamake -opt mb2gen.dsp -o mb2gen.exe"
# PROP Rebuild_Opt "-all"
# PROP Target_File "mb2gen.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "mb2gen - Win32 Bytecode"
# Name "mb2gen - Win32 Native code"

!IF  "$(CFG)" == "mb2gen - Win32 Bytecode"

!ELSEIF  "$(CFG)" == "mb2gen - Win32 Native code"

!ENDIF 

# Begin Group "ML Files"

# PROP Default_Filter "ml;mly;mll"
# Begin Source File

SOURCE=.\assemble.ml
# End Source File
# Begin Source File

SOURCE=..\..\ext\class\util\bitCodec.ml
# End Source File
# Begin Source File

SOURCE=.\dungeon.ml
# End Source File
# Begin Source File

SOURCE=.\level.ml
# End Source File
# End Group
# Begin Group "MLI Files"

# PROP Default_Filter "mli"
# End Group
# End Target
# End Project
