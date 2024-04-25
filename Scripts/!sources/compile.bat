@setlocal enableextensions enabledelayedexpansion
@echo off
echo Starting...

for /d %%B in (.\*) do (
	if %%B NEQ .\jit (
		MD ..\%%B
		for %%i in ("%%B\*.lua") do (
			set nam=%%i
			echo Converting %%i
			luajit.exe -b "%%i" "..\!nam:~0,-4!.luac" 
		)
	)
)

for %%i in (*.lua) do (
	set nam=%%i
	echo Converting %%i
	luajit.exe -b "%%i" "../!nam:~0,-4!.luac" 
)

echo Done
pause