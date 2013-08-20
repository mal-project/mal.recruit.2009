@ECHO OFF
REM --------------------------------------------------------------------
REM make.cmd v 5.4.6
REM --------------------------------------------------------------------
SET FILENAME=user32
SET FILERES=rsrc

REM --------------------------------------------------------------------
SET SYNTAX_CHECK_ONLY=FALSE
SET COMPILE_RES=false
SET BUILD_ASM=TRUE
SET LINK_OBJ=TRUE

SET BUILD_DLL=TRUE
SET BUILD_LIB=FALSE
SET USE_COMMON_PATH=FALSE

REM --------------------------------------------------------------------
REM Fixing up AsmPad bugs
FOR /L %%i IN (1, 1, 5) DO (
	IF NOT EXIST %FILENAME%.asm. (
		CD ..
	) ELSE (
		GOTO ENDLOOP
	)
)
:ENDLOOP
IF NOT EXIST %FILENAME%.asm. (
    ECHO NO %FILENAME%.asm found!
    PAUSE>NUL
    EXIT
)

REM --------------------------------------------------------------------
SET COMMON_PATH=..\..\common
SET PROJECT_PATH=%CD%
SET MASM_PATH=\Programs\Development\RCE\Assemblers\MASM
SET UPX_PATH=\Programs\Development\RCE\Tools\Packers

REM --------------------------------------------------------------------
IF EXIST %COMMON_PATH%. (
    cd  %COMMON_PATH%
)
SET COMMON=%CD%
SET COMMON_BIN=%COMMON%\binaries
SET COMMON_INC=%COMMON%\includes
SET COMMON_LIB=%COMMON%\libraries
SET COMMON_RES=%COMMON%\resources

REM --------------------------------------------------------------------
cd  %PROJECT_PATH%
SET PROJECT=%CD%
SET PROJECT_BIN=%PROJECT%\bin
SET PROJECT_INC=%PROJECT%\include
SET PROJECT_LIB=%PROJECT%\lib
SET PROJECT_RES=%PROJECT%\res
SET LOG=%PROJECT%\bak\make.log

IF %USE_COMMON_PATH% == TRUE (
    REM SET PROJECT_BIN=%COMMON_BIN%\bin
    SET PROJECT_INC=%COMMON_INC%
    SET PROJECT_LIB=%COMMON_LIB%
    REM SET PROJECT_RES=%COMMON_RES%
    SET LOG=%COMMON%\bak\make.log
)

REM --------------------------------------------------------------------
IF NOT EXIST %PROJECT%\bak. MD %PROJECT%\bak
IF NOT EXIST %PROJECT%\bin. MD %PROJECT%\bin
ECHO %DATE% - %TIME%>%LOG%

REM --------------------------------------------------------------------
SET ML_ARGS=/I"%PROJECT%\include\core" /I"%PROJECT%\include\gui" /I"%PROJECT%\include\stub" /I"%PROJECT%\include\com" /c /coff /nologo /Fo"%PROJECT_BIN%\%FILENAME%.obj" "%PROJECT%\%FILENAME%.asm" 

IF  %COMPILE_RES%==TRUE (
    SET RC_ARGS=/l0 "%PROJECT_RES%\%FILERES%.rc"
    SET CVTRES_ARGS=/nologo /machine:ix86 "%PROJECT_RES%\%FILERES%.res"
    SET RSRC_PARAM="%PROJECT_RES%\%FILERES%.res"
)

IF %BUILD_DLL%==TRUE (
    SET EXT=dll
    SET LINK_ARGS=/nologo /DLL /NOENTRY /DEF:%FILENAME%.def /SUBSYSTEM:WINDOWS /OUT:"%PROJECT_BIN%\%FILENAME%.dll" "%PROJECT_BIN%\%FILENAME%.obj" %RSRC_PARAM%

) ELSE (
    IF %BUILD_LIB%==TRUE (
        SET EXT=lib
        SET LINK_ARGS=/nologo /LIB /SUBSYSTEM:WINDOWS /DEF:%FILENAME%.def /OUT:"%PROJECT_BIN%\%FILENAME%.%EXT%" "%PROJECT_BIN%\%FILENAME%.obj" %RSRC_PARAM%

    ) ELSE (
        SET EXT=exe
        SET LINK_ARGS= /libpath:"%PROJECT%\lib\core" /libpath:"%PROJECT%\lib\stub" /libpath:"%PROJECT%\lib\com" /libpath:"%PROJECT%\lib\gui" /nologo /SUBSYSTEM:WINDOWS /OUT:"%PROJECT_BIN%\%FILENAME%.exe" "%PROJECT_BIN%\%FILENAME%.obj" %RSRC_PARAM%
    )
)

REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM Masm32 directories...
SET MASM=%MASM_PATH%
SET CHECK_DRIVES=C Y Z
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM Checking for masm32 directories
FOR %%i IN (%CHECK_DRIVES%) DO (
    IF EXIST %%i:%MASM%. SET MASM=%%i:%MASM%
)

IF NOT EXIST %MASM%. (
    ECHO NO MASM DIRECTORY FOUND! CHECK PATH IN MAKE.CMD
    ECHO MASM=%MASM%
    GOTO ERROR_CONFIG
)
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
SET MASM_BIN=%MASM%\bin
REM You may experiment problems with compiled libraries, leave it blank if so...
SET MASM_LIB=%MASM%\lib
REM SET MASMLIB=
SET MASM_INC=%MASM%\include
SET MASM_MACROS=%MASM%\macros
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM upx directories...
SET UPXPATH=%UPX_PATH%
SET CHECK_DRIVES=C Y Z
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM Checking for upx directories
FOR %%j IN (%CHECK_DRIVES%) DO (
    IF EXIST %%j:%UPXPATH%. SET UPXPATH=%%j:%UPXPATH%
)

IF NOT EXIST %UPXPATH%. (
    ECHO NO UPX DIRECTORY FOUND! CHECK PATH IN MAKE.CMD
    ECHO.
)
REM --------------------------------------------------------------------
REM Logging some useful hints when problems occurs...
ECHO MASM=%MASM%>> "%LOG%"
ECHO UPXPATH=%UPXPATH%>> "%LOG%"
ECHO PROJECT=%PROJECT%>> "%LOG%"
ECHO COMMON=%COMMON%>> "%LOG%"

REM --------------------------------------------------------------------
ECHO Make.cmd version 5.4
ECHO Saturday, May 17, 2009

REM --------------------------------------------------------------------
IF %SYNTAX_CHECK_ONLY%==TRUE (
    ECHO.
    ECHO Syntax check only...
    ECHO ...................................................................
    "%MASM_BIN%\ml.exe" /I"%MASM_INC%" /I"%MASM_MACROS%" /I"%PROJECT_INC%" /I"%COMMON_INC%" %ML_ARGS% /Zs >> "%LOG%"
    GOTO _EXIT
)

REM --------------------------------------------------------------------
IF %COMPILE_RES%==TRUE (
    ECHO.
    ECHO Compiling resources...
    ECHO ...................................................................
    "%MASM_BIN%\rc.exe" /i %MASM_INC% /i %MASM_MACROS% /i %PROJECT_INC% %RC_ARGS% >> "%LOG%"
    "%MASM_BIN%\cvtres.exe" %CVTRES_ARGS% >> "%LOG%"
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR_BUILD
)

REM --------------------------------------------------------------------
IF %BUILD_ASM%==TRUE (
    ECHO.
    ECHO Building...
    ECHO ..................................................................   
    "%MASM_BIN%\ml.exe" /I"%MASM_INC%" /I"%MASM_MACROS%" /I"%PROJECT_INC%" /I"%COMMON_INC%" %ML_ARGS% >> "%LOG%"
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR_BUILD
)

REM --------------------------------------------------------------------
IF %LINK_OBJ%==TRUE (
    ECHO.
    ECHO Linking...
    ECHO ..................................................................
    IF %BUILD_LIB%==TRUE (
        
        "%MASM_BIN%\polib.exe" "bin\%FILENAME%.obj" /out:"bin/%FILENAME%.lib"
            
    ) ELSE (
        IF EXIST "%MASM_LIB%\kernel32.lib". (
            "%MASM_BIN%\link.exe" /libpath:"%MASM_LIB%" /libpath:"%PROJECT_LIB%" /libpath:"%COMMON_LIB%" %LINK_ARGS% >> "%LOG%"
        ) ELSE (
            "%MASM_BIN%\link.exe" %LINK_ARGS% >> "%LOG%"
        )
    )
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR_BUILD

    IF NOT EXIST "%PROJECT_BIN%\%FILENAME%.%EXT%". GOTO ERROR_BUILD

    IF EXIST "%PROJECT_BIN%\*.obj" DEL "%PROJECT_BIN%\*.obj"
    IF EXIST "%PROJECT_RES%\*.res" DEL "%PROJECT_RES%\*.res"
    IF EXIST "%PROJECT_RES%\*.obj" DEL "%PROJECT_RES%\*.obj"
)

REM --------------------------------------------------------------------
:END
ECHO.
ECHO Ok. Everything seems fine. What you wanna do now?
SET /P CHOISE=Compress/Launch/Debug/Exit? (c/l/cl/d/e)

IF %CHOISE%==c (
	ECHO.
	ECHO Compressing...
	START /D"%UPXPATH%" upx.exe -9 "%PROJECT_BIN%\%FILENAME%.exe"
	GOTO FINISH
)

IF %CHOISE%==l (
	ECHO.
	ECHO Executing...
	START /D"%PROJECT_BIN%" "" "%FILENAME%.exe"
	GOTO FINISH
)

IF %CHOISE%==cl (
    ECHO.
	ECHO Compressing and launching...
	START /WAIT /D"%UPXPATH%" upx.exe -9 "%PROJECT_BIN%\%FILENAME%.exe"
	START /D"%PROJECT_BIN%" "" "%FILENAME%.exe"
)

IF %CHOISE%==d (
	ECHO.
	ECHO Launching debugger...
	START /D"%CD%" debug.cmd
)
GOTO FINISH
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
:ERROR_BUILD
    ECHO.
    ECHO AN ERROR HAS OCCURRED! CHECK LOG FOR DETAILS.
    ECHO.
    SET /P CHOISE=Open log in notepad? (y/n)
    IF %CHOISE%==y START notepad.exe "%LOG%"
    EXIT

:ERROR_CONFIG
    PAUSE>nul

:FINISH
    IF EXIST "%LOG%" DEL "%LOG%"
    IF EXIST "%PROJECT%\*.obj" DEL "%PROJECT%\*.obj"
    IF EXIST "%PROJECT_RES%\*.res" DEL "%PROJECT_RES%\*.res"
    IF EXIST "%PROJECT_RES%\*.obj" DEL "%PROJECT_RES%\*.obj"

:_EXIT
    EXIT