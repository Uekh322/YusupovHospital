param(
    [string]$Server = '(localdb)\MSSQLLocalDB',
    [string]$Database = 'HospitalBD'
)
$ErrorActionPreference = 'Stop'
$accounts = [ordered]@{
    Registrar_Login = 'Registrar_User'
    Doctor_Login = 'Doctor_User'
    ChiefDoctor_Login = 'ChiefDoctor_User'
}
$settings = [System.Data.SqlClient.SqlConnectionStringBuilder]::new()
$settings['Data Source'] = $Server
$settings['Initial Catalog'] = 'master'
$settings['Integrated Security'] = $true
$settings['TrustServerCertificate'] = $true
$connection = [System.Data.SqlClient.SqlConnection]::new($settings.ConnectionString)
try {
    $connection.Open()
    $connection.ChangeDatabase($Database)
    $command = $connection.CreateCommand()
    try {
        $command.CommandText = "SELECT COUNT(*) FROM sys.database_principals WHERE type = 'R' AND name IN (N'RegistrarRole', N'DoctorRole', N'ChiefDoctorRole');"
        if ($command.ExecuteScalar() -ne 3) { throw 'Run the database setup script first.' }
        foreach ($login in $accounts.Keys) {
            $connection.ChangeDatabase('master')
            $command.Parameters.Clear()
            [void]$command.Parameters.AddWithValue('@login', $login)
            $command.CommandText = 'SELECT COUNT(*) FROM sys.sql_logins WHERE name = @login;'
            if ($command.ExecuteScalar() -eq 0) {
                $secure = Read-Host "New password for $login" -AsSecureString
                try {
                    if ($secure.Length -eq 0 -or $secure.Length -gt 128) {
                        throw 'Enter a password between 1 and 128 characters.'
                    }
                    $buffer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
                    try {
                        $command.CommandText = "DECLARE @sql nvarchar(600) = N'CREATE LOGIN ' + QUOTENAME(@login) + N' WITH PASSWORD = ' + QUOTENAME(@password, N'''') + N', CHECK_POLICY = ON;'; EXEC sys.sp_executesql @sql;"
                        [void]$command.Parameters.AddWithValue('@password', [Runtime.InteropServices.Marshal]::PtrToStringBSTR($buffer))
                        [void]$command.ExecuteNonQuery()
                    } finally {
                        $command.Parameters.Clear()
                        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($buffer)
                    }
                } finally { $secure.Dispose() }
            }
            $connection.ChangeDatabase($Database)
            $command.Parameters.Clear()
            $user = $accounts[$login]
            $role = $login.Replace('_Login', 'Role')
            $command.CommandText = @"
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DECLARE @user sysname = N'$user';
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @user AND authentication_type = 0)
    SET @user = N'$login';
DECLARE @principal nvarchar(258) = QUOTENAME(@user);
DECLARE @login sysname = N'$login';
DECLARE @statement nvarchar(600);
IF DATABASE_PRINCIPAL_ID(@user) IS NULL
    SET @statement = N'CREATE USER ' + @principal + N' FOR LOGIN ' + QUOTENAME(@login);
ELSE
    SET @statement = N'ALTER USER ' + @principal + N' WITH LOGIN = ' + QUOTENAME(@login);
EXEC sys.sp_executesql @statement;
IF IS_ROLEMEMBER(N'$role', @user) <> 1
BEGIN
    SET @statement = N'ALTER ROLE [$role] ADD MEMBER ' + @principal;
    EXEC sys.sp_executesql @statement;
END;
SET @statement = N'GRANT CONNECT TO ' + @principal;
EXEC sys.sp_executesql @statement;
COMMIT TRANSACTION;
"@
            [void]$command.ExecuteNonQuery()
            Write-Output "Ready: $login"
        }
    } finally { $command.Dispose() }
} finally { $connection.Dispose() }
