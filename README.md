# YusupovHospital

Учебный проект WPF на .NET Framework 4.7.2, Entity Framework 6 и SQL Server LocalDB.

1. В SSMS подключитесь к `(localdb)\MSSQLLocalDB` и запустите [YusupovHospitalDB_Script.sql](YusupovHospitalDB_Script.sql) на экземпляре, где ещё нет базы `HospitalBD`.
2. Откройте `YusupovHospital.slnx` в Visual Studio, восстановите пакеты NuGet и запустите проект.
3. Для другого экземпляра SQL Server измените `data source` в `YusupovHospital/App.config`.

Скрипт создаёт таблицы, загружает учебные данные, включая вымышленные реквизиты 25 пациентов, и добавляет роли базы. Пользователи этих ролей создаются без привязки к серверным логинам. Приложение подключается с проверкой подлинности Windows.
