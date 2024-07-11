@echo off
echo Starting...

setlocal disabledelayedexpansion
set startPath=%~dp0

for /d %%B in (.\*) do (
	if %%B NEQ .\jit (
		MD ..\%%B
		for %%i in ("%%B\*.lua") do (
			call :CompileFunction %startPath% %%i
		)
	)
)

for %%i in (*.lua) do (
	call :CompileFunction %startPath% %%i
)
goto :EXIT


:CompileFunction
set subPath=%2
set srcPath=%1\%2
set destPath=%1..\%subPath:~0,-4%

echo Converting %2

cd /d "c:\LuaJIT\x86\" 
c:\LuaJIT\x86\luajit.exe -bg "%srcPath%" "%destPath%.luac.x86"
cd /d "c:\LuaJIT\x64\" 
c:\LuaJIT\x64\luajit.exe -bg "%srcPath%" "%destPath%.luac.x64"
cd /d %startPath%

exit /b



:EXIT
echo Done
pause
endlocal