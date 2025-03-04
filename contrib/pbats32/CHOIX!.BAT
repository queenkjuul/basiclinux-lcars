@echo off
cls

echo.
echo.
echo.
echo            ----------------------------------------
echo            (1) first choice        (4) forth choice
echo            (2) second choice       (5) fifth choice
echo            (3) third choice
echo            ---------------------------------------
echo            Please click on menu item or enter number

choix /c:12345 /M( /N

for %%a in (1 2 3 4 5) do if errorlevel %%a set item=%%a

echo.
echo.
echo.
echo  You selected item# %item%
echo.
set item=
