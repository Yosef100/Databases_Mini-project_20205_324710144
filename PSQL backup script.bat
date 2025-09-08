@echo off
REM --- Configuration ---
SET PSQL_USER=postgres
REM Avoid embedding quotes in the variable value; use quoted expansion when calling commands:
SET PSQL_DB=travel agency - personnel
SET BACKUP_FILE=backupPSQL.sql
SET LOG_FILE=backupPSQL.log

REM --- Start logging ---
echo Backup started at %DATE% %TIME% > "%LOG_FILE%"

REM Step 1: Create a plain-text SQL backup
echo Creating plain-text SQL backup... >> "%LOG_FILE%"
pg_dump -U %PSQL_USER% -d "%PSQL_DB%" -F p -f "%BACKUP_FILE%" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Backup failed! Check log. >> "%LOG_FILE%"
    exit /b %ERRORLEVEL%
) ELSE (
    echo Backup completed successfully. >> "%LOG_FILE%"
)

REM Step 2: Clear the database (drop and recreate public schema)
echo Dropping all tables (drop schema public and recreate)... >> "%LOG_FILE%"
psql -U %PSQL_USER% -d "%PSQL_DB%" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Clearing database failed! >> "%LOG_FILE%"
    exit /b %ERRORLEVEL%
) ELSE (
    echo Database cleared successfully. >> "%LOG_FILE%"
)

REM Step 3: Restore the plain-text SQL backup with psql
echo Restoring backup via psql -f "%BACKUP_FILE%"... >> "%LOG_FILE%"
psql -U %PSQL_USER% -d "%PSQL_DB%" -f "%BACKUP_FILE%" >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Restore failed! >> "%LOG_FILE%"
    exit /b %ERRORLEVEL%
) ELSE (
    echo Restore completed successfully. >> "%LOG_FILE%"
)

REM Finish logging
echo Process completed at %DATE% %TIME% >> "%LOG_FILE%"
