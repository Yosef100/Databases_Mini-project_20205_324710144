@echo off
REM Backup PostgreSQL database with logging and timestamps

set PGUSER=postgres
set PGPASSWORD=admin
set PGHOST=localhost
set PGPORT=5432
set PGDATABASE="travel agency - personnel"

set SQLFILE=backupSQL.sql
set LOGFILE=backupSQL.log

echo Backup started at %DATE% %TIME% >> %LOGFILE%

powershell -Command "Measure-Command { pg_dump --username=%PGUSER% --host=%PGHOST% --port=%PGPORT% --dbname='%PGDATABASE%' --format=plain --clean --create --no-owner --no-privileges --verbose -f '%SQLFILE%' } | ForEach-Object { 'Elapsed Time: ' + $_.TotalSeconds + ' seconds' }" >> %LOGFILE% 2>&1

echo Backup finished at %DATE% %TIME% >> %LOGFILE%
pause
