@echo off
echo Starting...

setlocal disabledelayedexpansion
set startPath=%~dp0


for /d %%B in (.\*) do (
	if %%B NEQ .\jit (
		MD ..\%%B
		for %%i in ("%%B\*.lua") do (
			call :CompileFunction %%i "true"
		)
	)
)

for %%i in (*.lua) do (
	call :CompileFunction %%i "false"
)
goto :DONE


:CompileFunction
set subPath=%1


if %2 EQU "true" (
	set srcPath=%startPath%%subPath:~2%
) else (
	set srcPath=%startPath%%1
)
set destPath=%startPath%..\%subPath:~0,-4%

echo Converting %srcPath%

cd /d "c:\LuaJIT\" 
c:\LuaJIT\luajit.exe -bs "%srcPath%" "%destPath%.luac"
IF %ERRORLEVEL% NEQ 0 (
  goto :ERROR
)
cd /d %startPath%

exit /b



:ERROR
echo \\\
echo Compiling error
echo \\\
goto :EXIT

:DONE
echo Done

:EXIT
pause

endlocal