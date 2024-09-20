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
goto :EXIT


:CompileFunction
set subPath=%1


if %2 EQU "true" (
	set srcPath=%startPath%%subPath:~2%
) else (
	set srcPath=%startPath%%1
)
set destPath=%startPath%..\%subPath:~0,-4%

echo Converting %srcPath%

cd /d "c:\LuaJIT\x86\" 
c:\LuaJIT\x86\luajit.exe -bs "%srcPath%" "%destPath%.luac.x86"
cd /d "c:\LuaJIT\x64\" 
c:\LuaJIT\x64\luajit.exe -bs "%srcPath%" "%destPath%.luac.x64"
cd /d %startPath%

exit /b



:EXIT
echo Done
pause
endlocal