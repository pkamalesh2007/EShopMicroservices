@echo off
REM Captures the full state of the Catalog database setup into diagnose-output.txt.
REM Run from anywhere:  tools\diagnose.cmd
setlocal
set OUT=%~dp0diagnose-output.txt
set SRC=%~dp0..\src

echo ===== 1. RUNNING CONTAINERS =====> "%OUT%"
docker ps -a >> "%OUT%" 2>&1

echo.>> "%OUT%"
echo ===== 2. PORTS IN USE (5432-5439) =====>> "%OUT%"
netstat -ano | findstr LISTENING | findstr ":543" >> "%OUT%" 2>&1
tasklist | findstr /I postgres >> "%OUT%" 2>&1

echo.>> "%OUT%"
echo ===== 3. COMPOSE FILES =====>> "%OUT%"
type "%SRC%\docker-compose.yml" >> "%OUT%" 2>&1
echo.>> "%OUT%"
type "%SRC%\docker-compose.override.yml" >> "%OUT%" 2>&1

echo.>> "%OUT%"
echo ===== 4. CONNECTION STRING =====>> "%OUT%"
findstr /I "MartenConnection" "%SRC%\Services\Catalog\Catalog.API\appsettings.json" >> "%OUT%" 2>&1

echo.>> "%OUT%"
echo ===== 5. MARTEN REGISTRATION =====>> "%OUT%"
findstr /I /C:"AddMarten" /C:"Schema.For" /C:"ApplyAll" /C:"UseLightweightSessions" "%SRC%\Services\Catalog\Catalog.API\Program.cs" >> "%OUT%" 2>&1

echo.>> "%OUT%"
echo ===== 6. DATABASES AND TABLES IN THE CONTAINER =====>> "%OUT%"
for /f "tokens=1" %%i in ('docker ps -q --filter "ancestor=postgres:18"') do (
  echo --- container %%i --->> "%OUT%"
  docker exec %%i psql -U postgres -c "SELECT current_setting('data_directory') AS datadir;" >> "%OUT%" 2>&1
  docker exec %%i psql -U postgres -c "SELECT datname FROM pg_database WHERE datistemplate = false;" >> "%OUT%" 2>&1
  docker exec %%i psql -U postgres -d CatalogDb -c "SELECT table_schema, table_name FROM information_schema.tables WHERE table_name LIKE 'mt_%%';" >> "%OUT%" 2>&1
)

echo.>> "%OUT%"
echo ===== 7. POST A PRODUCT =====>> "%OUT%"
curl -s -i -X POST http://localhost:5000/products -H "Content-Type: application/json" -d "{\"name\":\"Diag\",\"category\":[\"A\"],\"price\":1,\"description\":\"d\",\"imageFile\":\"i.png\"}" >> "%OUT%" 2>&1

echo.>> "%OUT%"
echo ===== 8. TABLES AFTER THE POST =====>> "%OUT%"
for /f "tokens=1" %%i in ('docker ps -q --filter "ancestor=postgres:18"') do (
  docker exec %%i psql -U postgres -d CatalogDb -c "SELECT table_schema, table_name FROM information_schema.tables WHERE table_name LIKE 'mt_%%';" >> "%OUT%" 2>&1
)

echo.
echo Done. Output written to:
echo   %OUT%
echo Open it and paste the contents.
endlocal
