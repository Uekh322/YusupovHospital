# YusupovHospital

Учебная система больницы на WPF, .NET Framework 4.7.2, Entity Framework 6.5.2 и SQL Server. В приложении есть карточки пациентов, поиск, фильтрация, истории болезни, листы лечения и справочники.

1. В SSMS подключитесь к `(localdb)\MSSQLLocalDB` с проверкой подлинности Windows. Выполните [YusupovHospitalDB_Script.sql](YusupovHospitalDB_Script.sql), чтобы создать `HospitalBD` с учебными данными. Если база уже развёрнута, пропустите этот шаг.
2. Из папки репозитория запустите `powershell -ExecutionPolicy Bypass -File .\Initialize-HospitalLogins.ps1`. Задайте пароли для новых SQL-логинов. Для существующих логинов используйте их текущие пароли.
3. Откройте `YusupovHospital.sln` в Visual Studio, восстановите NuGet и нажмите F5. Войдите с заданным паролем.

| Логин | Роль |
|---|---|
| `ChiefDoctor_Login` | Главный врач |
| `Doctor_Login` | Врач |
| `Registrar_Login` | Регистратор |

Для другого экземпляра SQL Server укажите его в `data source` в `YusupovHospital/App.config` и передайте тот же адрес параметром `-Server` в скрипт настройки. Для обычного SQL Server требуется смешанный режим аутентификации.
