@echo off
chcp 65001
setlocal EnableDelayedExpansion

rem Configuration variables
set "VERSION=3.1"
set "MANUFACTURER=Rikor"
set "PRODUCT_NAME=Nino 201.1 15"
set "AMIDE_PATH=%~dp0AMIDEWINx64.EXE"
set "LOG_FILE=%~dp0script.log"
set "MAX_RETRIES=3"
set "TITLE=Инструмент обновления BIOS v%VERSION%"
set "DELAY=2"
set "SHOW_DELAY=10"
set "PAUSE_DELAY=3"
set "AUTO_RESTART=1"
set "RESTART_FLAG=%~dp0restart.flag"
set "SUCCESS_FLAG=%~dp0success.flag"
set "VERIFY_DELAY=5"
set "VERIFY_WAIT=5"
set "SERIAL_PREFIX=RiNi-124567000"
set "SKU_NUMBER=6B5888A8"    REM Add this line
set "FAMILY_NAME=NINO" REM Add this line

rem Logo definition (use only one)
set "LOGO=^
echo.&^
echo.&^
echo.&^
echo    ██████╗ ██╗██╗  ██╗ ██████╗ ██████╗                      &^
echo    ██╔══██╗██║██║ ██╔╝██╔═══██╗██╔══██╗                     &^
echo    ██████╔╝██║█████╔╝ ██║   ██║██████╔╝                     &^
echo    ██╔══██╗██║██╔═██╗ ██║   ██║██╔══██╗                     &^
echo    ██║  ██║██║██║  ██╗╚██████╔╝██║  ██║                     &^
echo    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝                     &^
echo.&^
echo              Made with ^<3 by Kuzz                            &^
echo."

:INITIALIZE
REM Подготовка данных BIOS перед отображением
set "bios_vendor_name=Не определено"
set "bios_version=Не определено"
set "bios_release_date=Не определено"
set "bios_info_SS=Не определено"
set "bios_info_SM=Не определено"
set "bios_info_SP=Не определено"
set "bios_info_SK=Не определено"
set "bios_info_SF=Не определено"
set "bios_info_SU=Не определено"
set "bios_info_BS=Не определено"
set "bios_info_CS=Не определено"
set "mac_addr=Не доступен"

REM Измененная логика парсинга для получения только последнего слова
for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /IVN 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_vendor_name=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /IV 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_version=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /ID 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_release_date=%%b"
    )
)

REM Получение системной информации с корректным парсингом
for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /SS 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_SS=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /SM 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_SM=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /SP 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_SP=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /SK 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_SK=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /SF 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_SF=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /SU 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_SU=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /BS 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_BS=%%b"
    )
)

for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /CS 2^>nul') do (
    if not "%%a"=="Read >> Done." (
        for %%b in (%%a) do set "bios_info_CS=%%b"
    )
)

REM Получение MAC-адреса
for /f "tokens=2 delims== " %%a in ('wmic nic where "NetEnabled=True" get MACAddress /value 2^>nul') do (
    if not "%%a"=="" set "mac_addr=%%a"
)

REM Удаление ведущих и завершающих пробелов
for %%v in (bios_vendor_name bios_version bios_release_date bios_info_SS
            bios_info_SM bios_info_SP bios_info_SK bios_info_SF bios_info_SU
            bios_info_BS bios_info_CS mac_addr) do (
    for /f "tokens=* delims= " %%a in ("!%%v!") do set "%%v=%%a"
)

goto :START

:START
goto :CHECK_PRIVILEGES

:CHECK_PRIVILEGES
REM Check admin rights silently
REM Раскомментируйте следующие строки для проверки прав администратора
REM fsutil dirty query %systemdrive% >nul 2>&1
REM if %ERRORLEVEL% NEQ 0 (
REM     cls
REM     echo ### Требуются права администратора. Перезапуск с повышенными привилегиями... ###
REM     start "" "%~f0" --elevated
REM     exit /b
REM )
goto :MAIN_MENU

:TranslateAndEcho
set "input=%~1"
set "command="
set "value="
for /f "tokens=1,2 delims==" %%a in ("%input%") do (
    set "command=%%a"
    set "value=%%b"
)
if "!value!"=="" (
    echo  %input%
) else (
    set "value=!value: =!"
    echo  %-30s!value!
)
goto :eof

:MAIN_MENU
cls
color 1F
echo %TITLE%
echo =============================================
echo Текущие значения BIOS:
echo.

echo Информация о BIOS:
echo  Производитель BIOS:            %bios_vendor_name:"=%
echo  Версия BIOS:                   %bios_version:"=%
echo  Дата выпуска BIOS:            %bios_release_date:"=%
echo.

echo Информация о системе:
echo  Серийный номер:               %bios_info_SS:"=%
echo  Производитель:                %bios_info_SM:"=%
echo  Продукт:                      %bios_info_SP:"=%
echo  Номер SKU:                    %bios_info_SK:"=%
echo  Семейство:                    %bios_info_SF:"=%
echo  UUID системы:                 %bios_info_SU:"=%
echo  MAC Address:                  %mac_addr%
echo.

echo Информация о материнской плате:
echo  Серийный номер:               %bios_info_BS:"=%
echo.

echo Информация о корпусе:
echo  Серийный номер:               %bios_info_CS:"=%
echo.

echo =============================================
echo 1. ЗАПИСАТЬ СЕРИЙНЫЙ НОМЕР
echo 2. Обновить данные BIOS
echo 3. Просмотреть последний журнал операций
echo 4. Показать бинарные файлы
echo 5. Выход
echo =============================================
set /p "choice=Выберите опцию (1-5): "

if "%choice%"=="1" goto WRITE_SERIAL_NUMBER
if "%choice%"=="2" goto FETCH_BIOS_DATA
if "%choice%"=="3" goto VIEW_LOG
if "%choice%"=="4" goto SHOW_BINARIES
if "%choice%"=="5" goto CLEAN_EXIT
goto MAIN_MENU

:FETCH_BIOS_DATA
cls
%LOGO%
echo Обновление значений BIOS...
echo =============================================
    
REM Обновление всех значений BIOS с корректным парсингом
for %%I in (SS SM SP SK SF SU BS CS) do (
    for /f "tokens=*" %%a in ('"%AMIDE_PATH%" /%%I 2^>nul') do (
        if not "%%a"=="Read >> Done." (
            set "value=%%a"
            for %%b in (!value!) do set "value=%%b"
            if "%%I"=="SS" (set "label=Серийный номер:         ")
            if "%%I"=="SM" (set "label=Производитель:          ")
            if "%%I"=="SP" (set "label=Продукт:                ")
            if "%%I"=="SK" (set "label=Номер SKU:              ")
            if "%%I"=="SF" (set "label=Семейство:              ")
            if "%%I"=="SU" (set "label=UUID системы:           ")
            if "%%I"=="BS" (set "label=Серийный номер материнской платы: ")
            if "%%I"=="CS" (set "label=Серийный номер корпуса:    ")
            echo (/%%I)!label!!value!
            set "bios_info_%%I=!value!"
        )
    )
    ping -n 2 127.0.0.1 >nul
)

echo.
echo =============================================
echo Значения BIOS обновлены.
echo Возврат в главное меню...
timeout /t 3 >nul
goto :MAIN_MENU

:VIEW_LOG
cls
%LOGO%
echo %TITLE%
echo =============================================
if exist "%LOG_FILE%" (
    echo Последний журнал операций:
    echo.
    type "%LOG_FILE%" 2>nul || echo Ошибка чтения журнала
) else (
    echo Журнал отсутствует.
)
echo.
echo =============================================
echo Нажмите любую клавишу для возврата в меню...
pause >nul
goto MAIN_MENU

:SHOW_BINARIES
cls
%LOGO%
echo %TITLE%
echo =============================================
echo Список бинарных файлов в текущей папке:
echo.

set "FOUND_FILES=0"
for %%F in (*.BIN *.bin) do (
    set /a "FOUND_FILES+=1"
    echo !FOUND_FILES!. %%F
)

if %FOUND_FILES%==0 (
    echo  Бинарные файлы не найдены.
    echo.
    echo =============================================
    echo Нажмите любую клавишу для возврата в меню...
    pause >nul
    goto MAIN_MENU
)

echo.
echo =============================================
set /p "file_choice=Выберите номер файла (1-%FOUND_FILES%): "

set "current_file=0"
for %%F in (*.BIN *.bin) do (
    set /a "current_file+=1"
    if !current_file!==!file_choice! (
        set "selected_file=%%F"
        goto :PROCESS_BINARY
    )
)

echo Неверный выбор.
timeout /t 2 >nul
goto SHOW_BINARIES

:PROCESS_BINARY
echo.
echo Выбран файл: !selected_file!
cd /d "%~dp0"

REM Check if we came from WRITE_SERIAL_NUMBER
if "!PREV_MENU!"=="WRITE_SERIAL" (
    set "PREV_MENU="
    goto :WRITE_SERIAL_CONTINUE
)

REM Add comprehensive secure flash policy detection and handling
echo Проверка политики безопасного обновления...
set "secure_mode="
set "flash_policy="

REM Check BIOS Guard first
AFUWINx64.exe /D >nul 2>&1
if !ERRORLEVEL! EQU 0x120 (
    echo BIOS Guard включен
    set "secure_mode=BIOSGUARD"
    set "flash_policy=/capsule"
) else (
    REM Check Capsule support
    AFUWINx64.exe /CAPSULE >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo Поддерживается режим Capsule
        set "secure_mode=CAPSULE"
        set "flash_policy=/CAPSULE"
    ) else (
        REM Check Recovery support
        AFUWINx64.exe /RECOVERY >nul 2>&1
        if !ERRORLEVEL! EQU 0 (
            echo Поддерживается режим Recovery
            set "secure_mode=RECOVERY"
            set "flash_policy=/RECOVERY"
        ) else (
            REM Check ESP Recovery support
            AFUWINx64.exe /RECOVERY:ESP >nul 2>&1
            if !ERRORLEVEL! EQU 0 (
                echo Поддерживается режим ESP Recovery
                set "secure_mode=ESP_RECOVERY"
                set "flash_policy=/RECOVERY:ESP"
            ) else (
                echo Стандартный режим обновления
                set "secure_mode=STANDARD"
            )
        )
    )
)

REM Validate flash permissions based on policy
if defined secure_mode (
    if "!secure_mode!"=="BIOSGUARD" (
        REM Only allow /P /B /N operations with BIOS Guard
        set "allowed_ops=/P /B /N"
    ) else if "!secure_mode!"=="CAPSULE" (
        REM Only allow capsule operations
        set "allowed_ops=/P /B /N /E"
    ) else if "!secure_mode!"=="RECOVERY" (
        REM Only allow recovery operations
        set "allowed_ops=/P /B /N /E"
    )
    
    echo Режим безопасного обновления: !secure_mode!
    echo Разрешенные операции: !allowed_ops!
)

REM Add secure flash verification
if defined flash_policy (
    echo Проверка возможности безопасного обновления...
    AFUWINx64.exe /D !flash_policy! >nul 2>&1
    if !ERRORLEVEL! NEQ 0 (
        echo ### ОШИБКА: Режим безопасного обновления не поддерживается ###
        echo ### ОШИБКА: Код !ERRORLEVEL! ### >> "%LOG_FILE%"
        goto :ERROR
    )
    echo Безопасное обновление разрешено
)

REM Add rom verification for secure flash
if defined secure_mode (
    if not "!secure_mode!"=="STANDARD" (
        echo Проверка образа для безопасного обновления...
        AFUWINx64.exe /D "!selected_file!" !flash_policy! >nul 2>&1
        if !ERRORLEVEL! NEQ 0 (
            echo ### ОШИБКА: Образ не поддерживает безопасное обновление ###
            echo ### ОШИБКА: Код !ERRORLEVEL! ### >> "%LOG_FILE%"
            goto :ERROR
        )
        echo Образ подтвержден для безопасного обновления
    )
)

REM Modify flash command based on policy
set "flash_cmd=AFUWINx64.exe "!selected_file!" /P /B /N"
if defined flash_policy (
    set "flash_cmd=!flash_cmd! !flash_policy!"
)

REM Add AMD AM4 platform detection
echo Проверка платформы AMD AM4...
if exist "*AMD*.ROM" (
    echo Обнаружена платформа AMD AM4
    set "amd_platform=1"
    
    REM Check ROM size and region
    for %%F in ("!selected_file!") do set "rom_size=%%~zF"
    if !rom_size! EQU 33554432 (
        echo ROM размером 32MB - требуется выбор региона
        echo Выберите регион для прошивки:
        echo U - Верхние 16MB (TOP16M)
        echo D - Нижние 16MB (BOTTOM16M)
        choice /C UD /N /M "Выберите опцию (U/D): "
        
        if !ERRORLEVEL!==1 (
            set "amd_region=/ATR:U"
            set "amd_cmd=/CMD:{TOP16M}"
        )
        if !ERRORLEVEL!==2 (
            set "amd_region=/ATR:D"
            set "amd_cmd=/CMD:{BOTTOM16M}"
        )
    ) else (
        echo ROM не является 32MB AMD Combo AM4 образом
        set "amd_platform=0"
    )
) else (
    set "amd_platform=0"
)

REM Add AMD-specific flash options
if !amd_platform!==1 (
    echo Применение специальных параметров AMD AM4...
    set "flash_options=!amd_region! !amd_cmd!"
) else (
    set "flash_options="
)

REM Add PLDM capability detection and configuration 
echo Проверка поддержки PLDM...
AFUWINx64.exe /BCPALL >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo PLDM поддерживается, включение сохранения конфигурации
    set "pldm_enabled=1"
    set "preserve_config=/BCPALL"
    
    REM Create PLDM backup before flashing
    echo Создание резервной копии конфигурации PLDM...
    AFUWINx64.exe /BCPALL >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ### ПРЕДУПРЕЖДЕНИЕ: Не удалось создать резервную копию PLDM ### >> "%LOG_FILE%"
        echo ### ПРЕДУПРЕЖДЕНИЕ: Не удалось создать резервную копию PLDM ###
        set "pldm_enabled=0"
        goto :CHECK_STANDARD_PRESERVE
    )
) else (
    :CHECK_STANDARD_PRESERVE
    echo PLDM не поддерживается, проверка стандартного метода сохранения...
    set "pldm_enabled=0"
    AFUWINx64.exe /SP >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo Используется стандартный метод сохранения
        set "preserve_config=/SP"
    ) else (
        echo ### ПРЕДУПРЕЖДЕНИЕ: Настройки не будут сохранены ###
        set "preserve_config=/CLRCFG"
    )
)

REM Add ROM ID verification
echo Проверка ROM ID...
AFUWINx64.exe /U "!selected_file!" >nul 2>&1  
if %ERRORLEVEL% NEQ 0 (
    echo ### ОШИБКА: Несовместимый ROM ID ### >> "%LOG_FILE%"
    echo ### ОШИБКА: Несовместимый ROM ID ###
    goto :ERROR
)

REM Add secure flash policy check
echo Проверка политики безопасного обновления...
AFUWINx64.exe /CAPSULE >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "flash_policy=/CAPSULE"
) else (
    AFUWINx64.exe /RECOVERY >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "flash_policy=/RECOVERY"
    ) else (
        set "flash_policy="
    )
)

REM Verify power status first
echo Проверка источника питания...
AFUWINx64.exe /PW >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ### ОШИБКА: Требуется подключение к сети питания ###
    pause
    goto :MAIN_MENU
)

REM Verify ROM layout compatibility
echo Проверка совместимости ROM...
AFUWINx64.exe /D "!selected_file!" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ### ПРЕДУПРЕЖДЕНИЕ: Обнаружены изменения структуры ROM ###
    echo Выберите действие:
    echo E - Обновить весь BIOS (рекомендуется) 
    echo A - Отмена операции
    echo F - Принудительная запись
    echo M - Смешанный режим (BIOS + другие области)
    choice /C EAFM /N /M "Выберите опцию (E/A/F/M): "
    
    if !ERRORLEVEL!==1 set "flash_mode=/RLC:E"
    if !ERRORLEVEL!==2 goto :MAIN_MENU 
    if !ERRORLEVEL!==3 set "flash_mode=/RLC:F"
    if !ERRORLEVEL!==4 set "flash_mode=/RLC:M"
) else (
    set "flash_mode="
)

REM Enhanced flash command with PLDM support
echo Обновление BIOS...
if !amd_platform!==1 (
    echo Используется AMD Combo AM4 режи�� обновления
    AFUWINx64.exe "!selected_file!" /P /B /N !flash_options! %flash_policy% %preserve_config% %flash_mode% /Q
) else (
    AFUWINx64.exe "!selected_file!" /P /B /N %flash_policy% %preserve_config% %flash_mode% /Q
)

REM Enhanced error handling for AMD
if %ERRORLEVEL% NEQ 0 (
    set "error_code=%ERRORLEVEL%"
    
    REM AMD-specific error handling
    if !amd_platform!==1 (
        if !error_code!==0x83 (
            echo ### ОШИБКА: Неверный регион ROM для AMD AM4 ###
            goto :ERROR
        )
        if !error_code!==0x84 (
            echo ### ОШИБКА: Несовместимый размер ROM для AMD AM4 ###
            goto :ERROR
        )
    )
    
    REM Try standard recovery if PLDM fails
    if !pldm_enabled!==1 (
        echo Попытка восстановления стандартным методом...
        set "preserve_config=/SP"
        goto :RETRY_FLASH
    )
)

REM Enhanced PLDM settings preservation
echo Сохранение настроек BIOS...
AFUWINx64.exe /BCPALL >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "preserve=/BCPALL"
    echo Используется PLDM для сохранения настроек
) else (
    AFUWINx64.exe /SP >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "preserve=/SP"
        echo Используется стандартный метод сохранения
    ) else (
        set "preserve=/CLRCFG"
        echo ### ПРЕДУПРЕЖДЕНИЕ: Настройки не будут сохранены ###
    )
)

REM Create backup before flashing
echo Creating BIOS backup...
set "backup_file=bios_backup_%date:~-4,4%%date:~-7,2%%date:~-10,2%.bin"
AFUWINx64.exe /O "%backup_file%"

REM Enhanced flash command with all safety options
echo Обновление BIOS...
AFUWINx64.exe "!selected_file!" /P /B /N %flash_policy% %preserve% %flash_mode% /Q

REM Improved error handling
if %ERRORLEVEL% NEQ 0 (
    set "error_code=%ERRORLEVEL%"
    echo ### ОШИБКА: Код %error_code% ### >> "%LOG_FILE%"
    
    REM Handle specific error codes
    if %error_code%==0x04 echo Несовместимый ROM ID
    if %error_code%==0x15 echo Secure Flash не поддерживается
    if %error_code%==0x4C echo Несовместимая структура ROM
    if %error_code%==0x48 echo Требуется подключение питания
    
    REM Try recovery if appropriate
    if %error_code% GEQ 0x40 (
        echo Попытка восстановления...
        AFUWINx64.exe "!selected_file!" /P /B /N /RECOVERY
    )
    
    REM Restore from backup if recovery failed
    if %ERRORLEVEL% NEQ 0 (
        if exist "%backup_file%" (
            echo Восстановление из резервной копии...
            AFUWINx64.exe "%backup_file%" /P /B /N /RECOVERY
        )
    )
    goto :ERROR
)

REM Verify flash success
echo Проверка результатов обновления...
AFUWINx64.exe /D >nul 2>&1

echo.
echo Обновление BIOS завершено успешно.
echo Нажмите любую клавишу для возврата в меню...
pause >nul
goto :MAIN_MENU

:WRITE_SERIAL_NUMBER
cls
%LOGO%
echo Запись информации BIOS
color 1F

rem Check prerequisites
if not exist "%AMIDE_PATH%" (
    echo ### ОШИБКА: AMIDEWINx64.EXE не найден ### >> "%LOG_FILE%"
    echo ### ОШИБКА: AMIDEWINx64.EXE не найден ###
    pause
    goto :ERROR
)

rem Verify power status (AC adapter + battery)
if not "%JBC%"=="1" (
    echo Проверка источника питания...
    "%AMIDE_PATH%" /PW >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ### ОШИБКА: Подключите блок питания ### >> "%LOG_FILE%" 
        echo ### ОШИБКА: Подключите блок питания ###
        pause
        goto :ERROR
    )
)

rem Backup current BIOS
echo Создание резервной копии BIOS...
set "BACKUP_FILE=%~dp0bios_backup_%date:~-4,4%%date:~-7,2%%date:~-10,2%.bin"
"%AMIDE_PATH%" /O "%BACKUP_FILE%" >nul 2>&1

rem Simple serial input with validation
:INPUT_SERIAL
set "serial_suffix="
set /p "serial_suffix=Введите суффикс серийного номера (0-9999): "
echo %serial_suffix%| findstr /r "^[0-9][0-9]*$" >nul
if %ERRORLEVEL% NEQ 0 (
    echo Неверный формат! Введите только цифры.
    goto :INPUT_SERIAL
)
set "serial=%SERIAL_PREFIX%%serial_suffix%"

rem Verify ROM layout compatibility
echo Проверка совместимости ROM...
"%AMIDE_PATH%" /D >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ### ПРЕДУПРЕЖДЕНИЕ: Обнаружены изменения структуры ROM ###
    echo Выберите действие:
    echo E - Обновить весь BIOS (рекомендуется)
    echo A - Отмена операции
    echo F - Принудительная запись
    choice /C EAF /N /M "Выберите опцию (E/A/F): "
    if !ERRORLEVEL!==1 set "RLC=E"
    if !ERRORLEVEL!==2 goto :MAIN_MENU
    if !ERRORLEVEL!==3 set "RLC=F"
)

rem Try PLDM for settings preservation first
echo Попытка сохранения настроек через PLDM...
"%AMIDE_PATH%" /BCPALL >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "PRESERVE_METHOD=PLDM"
) else (
    echo Использование стандартного метода сохранения...
    set "PRESERVE_METHOD=STANDARD"
    "%AMIDE_PATH%" /SP >nul 2>&1
)

REM Display current and new values for info
cls
%LOGO%
echo =============================================
echo           Запись новых значений
echo =============================================
echo.
echo Серийный номер: %serial%
echo Производитель: %MANUFACTURER%
echo Продукт: %PRODUCT_NAME%"
echo SKU: %SKU_NUMBER%"
echo Семейство: %FAMILY_NAME%"
echo UUID: (будет сгенерирован)"
echo.
echo Выполняется запись..."
echo =============================================

REM Start logging
if not exist "%LOG_FILE%" (
    echo Запуск скрипта... > "%LOG_FILE%"
) else (
    echo Запуск скрипта... >> "%LOG_FILE%"
)

rem Check if AMIDEWINx64.EXE is available
echo Проверка наличия AMIDEWINx64.EXE... >> "%LOG_FILE%"
if not exist "%AMIDE_PATH%" (
    echo ### AMIDEWINx64.EXE не найден. Убедитесь, что AMIDEWINx64.EXE находится в той же папке, что и этот скрипт. ### >> "%LOG_FILE%"
    echo ### AMIDEWINx64.EXE не найден. Убедитесь, что AMIDEWINx64.EXE находится в той же папке, что и этот скрипт. ###
    pause
    goto :ERROR
)
echo AMIDEWINx64.EXE доступен. >> "%LOG_FILE%"

rem Backup current BIOS values
echo Создание резервной копии BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /SS > "%~dp0bios_backup.txt" 2>nul
call "%AMIDE_PATH%" /SU >> "%~dp0bios_backup.txt" 2>nul

rem Set Manufacturer to Rikor
echo Запись производителя в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /SM "%MANUFACTURER%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать производителя в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать производителя в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo Производитель успешно записан в BIOS. >> "%LOG_FILE%"

rem Set Product Name to Rikor R-N-15
echo Запись названия продукта в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /SP "%PRODUCT_NAME%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать название продукта в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать название продукта в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo Название продукта успешно записано в BIOS. >> "%LOG_FILE%"

rem Write SKU to BIOS
echo Запись SKU в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /SK "%SKU_NUMBER%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать SKU в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать SKU в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo SKU успешно записан в BIOS. >> "%LOG_FILE%"

rem Write Family to BIOS
echo Запись семейства в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /SF "%FAMILY_NAME%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать семейство в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать семейство в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo Семейство успешно записано в BIOS. >> "%LOG_FILE%"

rem Write system serial number to BIOS
echo Запись серийного номера системы в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /SS "%serial%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать серийный номер системы в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать серийный номер системы в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo Серийный номер системы успешно записан в BIOS. >> "%LOG_FILE%"

REM Replace the existing UUID generation block with the following code

REM Generate a new UUID without using WMIC or PowerShell
echo Генерация UUID... >> "%LOG_FILE%"
set "newUUID="
set "chars=0123456789abcdef"

for /L %%i in (1,1,32) do (
    set /A "index=!RANDOM! %% 16"
    call set "digit=%%chars:~!index!,1%%"
    set "newUUID=!newUUID!!digit!"
)

if not defined newUUID (
    echo ### Не удалось сгенерировать UUID. ### >> "%LOG_FILE%"
    echo ### Не удалось сгенерировать UUID. ###
    pause
    goto :ERROR
)
echo Сгенерированный UUID: %newUUID% >> "%LOG_FILE%"
echo Сгенерированный UUID: %newUUID%

rem Write new UUID to BIOS
echo Запись нового UUID в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /SU "%newUUID%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать UUID в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать UUID в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo UUID успешно записан в BIOS. >> "%LOG_FILE%"

rem Write baseboard serial number to BIOS
echo Запись серийного номера материнской платы в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /BS "%serial%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать серийный номер материнской платы в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать серийный номер материнской платы в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo Серийный номер материнской платы успешно записан в BIOS. >> "%LOG_FILE%"

rem Write chassis serial number to BIOS
echo Запись серийного номера корпуса в BIOS... >> "%LOG_FILE%"
call "%AMIDE_PATH%" /CS "%serial%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ### Не удалось записать серийный номер корпуса в BIOS. Код ошибки: %ERRORLEVEL% ### >> "%LOG_FILE%"
    echo ### Не удалось записать серийный номер корпуса в BIOS. Код ошибки: %ERRORLEVEL% ###
    pause
    goto :ERROR
)
echo Серийный номер корпуса успешно записан в BIOS. >> "%LOG_FILE%"

REM Proceed to verification
goto :VERIFY

:VERIFY
cls
%LOGO%
echo Проверка записанных значений...
echo =============================================
timeout /t 6 >nul

set "verify_success=0"
set "retry_count=0"

:VERIFY_RETRY
REM Получаем серийный номер системы непосредственно
for /f "tokens=* delims=" %%a in ('"%AMIDE_PATH%" /SS 2^>nul') do (
    set "line=%%a"
    if defined line (
        set "found_serial=!line!"
    )
)

REM Извлекаем серийный номер из строки
for /f "tokens=6 delims= " %%a in ("!found_serial!") do (
    set "found_serial=%%~a"
)

REM Добавляем подробный лог
echo [DEBUG] Raw line: [!line!] >> "%LOG_FILE%"
echo [DEBUG] Found Serial After Parsing: [!found_serial!] >> "%LOG_FILE%"
echo [DEBUG] Expected Serial: [!serial!] >> "%LOG_FILE%"

if /i "!found_serial!"=="!serial!" (
    set "verify_success=1"
    echo Проверка успешна - серийные номера совпадают >> "%LOG_FILE%"
    goto :REPORT_VALUES
)

set /a "retry_count+=1"
if !retry_count! lss !MAX_RETRIES! (
    echo Попытка !retry_count! из !MAX_RETRIES!...
    timeout /t 4 >nul
    goto :VERIFY_RETRY
)

echo ### Проверка не удалась после !MAX_RETRIES! попыток ### >> "%LOG_FILE%"
echo ### Ожидалось: [!serial!] Получено: [!found_serial!] ### >> "%LOG_FILE%"
echo ### Проверка не удалась - нажмите любую клавишу для продолжения... ###
pause >nul
goto :ERROR

:REPORT_VALUES
cls
%LOGO%
echo Отчет о новых значениях...
echo =============================================
echo Производитель: %MANUFACTURER%
echo Название продукта: %PRODUCT_NAME%"
echo SKU: %SKU_NUMBER%"
echo Семейство: %FAMILY_NAME%"
echo Серийный номер системы: %serial%"
echo Серийный номер материнской платы: %serial%"
echo Серийный номер корпуса: %serial%"
echo Новый UUID: %newUUID%"
echo =============================================
echo ========== Скрипт успешно завершен в %date% %time% ========== >> "%LOG_FILE%"

ping -n 4 127.0.0.1 >nul
goto :SHOW_BINARIES

:HELP
echo BIOS Update Tool v%VERSION%
echo Использование: %~nx0 [-h^|--help]
echo Опции:
echo   -h, --help    Показать это справочное сообщение
echo.
pause
goto :EXIT

:ERROR
color 4F
set "ERROR_CODE=%ERRORLEVEL%"
echo ### ОШИБКА ### >> "%LOG_FILE%"
echo Код ошибки: %ERROR_CODE% >> "%LOG_FILE%"

REM Enhanced error handling with specific error codes
set "err_msg="
if !ERROR_CODE!==0x04 set "err_msg=Несовместимый ROM ID"
if !ERROR_CODE!==0x15 set "err_msg=Secure Flash не поддерживается"
if !ERROR_CODE!==0x4C set "err_msg=Несовместимая структура ROM"
if !ERROR_CODE!==0x48 set "err_msg=Требуется подключение питания"
if !ERROR_CODE!==0x120 set "err_msg=BIOS Guard отключен"
if !ERROR_CODE!==0x126 set "err_msg=Ошибка очистки flash - проверьте защищенные регионы"
if !ERROR_CODE!==0x127 set "err_msg=Ошибка загрузки образа в память"
if !ERROR_CODE!==0x51 set "err_msg=Размер PLDM файла превышает размер FV"
if !ERROR_CODE!==0x52 set "err_msg=Ошибка сохранения конфигурации"
if !ERROR_CODE!==0x53 set "err_msg=BIOS не поддерживает сохранение конфигурации"
if !ERROR_CODE!==0x54 set "err_msg=Ошибка инициализации PLDM"
if !ERROR_CODE!==0x83 set "err_msg=Неверный регион ROM для AMD AM4"
if !ERROR_CODE!==0x84 set "err_msg=Несовместимый размер ROM для AMD AM4"

if defined err_msg (
    echo !err_msg! >> "%LOG_FILE%"
    echo !err_msg!
)

REM Add recovery attempt logic based on error type
if !ERROR_CODE! GEQ 0x40 (
    if !ERROR_CODE! LSS 0x50 (
        REM Flash operation errors - try recovery
        echo Попытка восстановления через Recovery...
        AFUWINx64.exe "!selected_file!" /P /B /N /RECOVERY
    ) else if !ERROR_CODE! GEQ 0x50 (
        if !ERROR_CODE! LSS 0x60 (
            REM PLDM errors - try standard preserve
            echo Попытка восстановления через стандартное сохранение...
            AFUWINx64.exe "!selected_file!" /P /B /N /SP
        )
    )
)

REM Try backup restoration if recovery failed
if exist "%BACKUP_FILE%" (
    echo Попытка восстановления из резервной копии...
    AFUWINx64.exe "%BACKUP_FILE%" /P /B /N
    
    REM Verify backup restoration
    if !ERRORLEVEL! NEQ 0 (
        echo ### КРИТИЧЕСКАЯ ОШИБКА: Восстановление из резервной копии не удалось ### >> "%LOG_FILE%"
        echo ### КРИТИЧЕСКАЯ О��ИБКА: Восстановление из резервной копии не удалось ###
    ) else (
        echo Восстановление из резервной копии успешно >> "%LOG_FILE%"
        echo Восстановление из резервной копии успешно
    )
)

REM Try to restore settings based on preservation method
if "%PRESERVE_METHOD%"=="PLDM" (
    echo Восстановление настроек PLDM...
    AFUWINx64.exe /BCPALL >nul 2>&1
    if !ERRORLEVEL! NEQ 0 (
        echo ### Ошибка восстановления настроек PLDM ### >> "%LOG_FILE%"
        
        REM Try standard method as fallback
        echo Попытка стандартного восстановления...
        AFUWINx64.exe /SP >nul 2>&1
    )
) else if "%PRESERVE_METHOD%"=="STANDARD" (
    echo Восстановление стандартных настроек...
    AFUWINx64.exe /SP >nul 2>&1
)

REM Log final error status
echo ============================= >> "%LOG_FILE%"
echo Итоговый статус ошибки: >> "%LOG_FILE%"
echo Код: !ERROR_CODE! >> "%LOG_FILE%"
if defined err_msg echo Описание: !err_msg! >> "%LOG_FILE%"
echo Время: %date% %time% >> "%LOG_FILE%"
echo ============================= >> "%LOG_FILE%"

echo.
echo Нажмите любую клавишу для возврата в главное меню...
pause >nul
goto :MAIN_MENU

:END
cls
color 2F
%LOGO%
echo ========== Скрипт успешно завершен в %date% %time% ========== >> "%LOG_FILE%"
@echo.
@echo =============================================
@echo          Обновление BIOS завершено
@echo =============================================
@echo.
@echo Результаты сохранены в: %LOG_FILE%"
@echo.
ping -n 4 127.0.0.1 >nul
goto :MAIN_MENU

:CLEAN_EXIT
cls
color 1F
%LOGO%
if exist "%RESTART_FLAG%" del "%RESTART_FLAG%" >nul 2>&1
if exist "%SUCCESS_FLAG%" del "%SUCCESS_FLAG%" >nul 2>&1
echo.
echo Спасибо за использование %TITLE%"
echo.
pause >nul
endlocal
endlocal
exit /b 0

:EXIT
exit /b 0

exit /b 0

:EXIT
exit /b 0
