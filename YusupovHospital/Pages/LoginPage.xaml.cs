using System;
using System.Data.SqlClient;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
namespace YusupovHospital {
 public partial class LoginPage:Page {
  public LoginPage(){InitializeComponent();}
  async void Login_Click(object s,RoutedEventArgs e){
   string login=LoginBox.Text.Trim(),password=PasswordBox.Password;
   if(login.Length==0 || password.Length==0){ErrorText.Text="Введи логин и пароль.";return;}
   LoginButton.IsEnabled=false;ErrorText.Text="Вход…";
   try{
    // Catch expected connection errors in the worker itself, before crossing the Task boundary.
    string error=await Task.Run(()=>{
     try{HospitalSession.Login(login,password);return (string)null;}
     catch(Exception ex){HospitalSession.Logout();WriteLoginLog(ex);return LoginError(ex);}
    });
    if(error!=null){ErrorText.Text=error;return;}
    PasswordBox.Clear();((MainWindow)Application.Current.MainWindow).ShowPatients();
   }
   catch(Exception ex){HospitalSession.Logout();WriteLoginLog(ex);ErrorText.Text="Не удалось открыть приложение. Повтори попытку.";}
   finally{LoginButton.IsEnabled=true;}
  }
  static string LoginError(Exception error){
   var sql=error.GetBaseException() as SqlException;
   if(sql!=null && sql.Number==18456)return "Неверный логин или пароль.";
   if(sql!=null && sql.Number==4060)return "База больницы недоступна для этой учётной записи.";
   if(error is InvalidOperationException && error.Message.StartsWith("Учётная запись"))return "У этой учётной записи нет доступа к приложению.";
   return "Не удалось подключиться к базе больницы. Повтори попытку.";
  }
  static void WriteLoginLog(Exception error){
   try{
    string directory=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"YusupovHospital","Logs");Directory.CreateDirectory(directory);
    var cause=error.GetBaseException();
    File.AppendAllText(Path.Combine(directory,"startup.log"),DateTimeOffset.Now.ToString("o")+" • "+(Environment.Is64BitProcess?"x64":"x86")+" • "+cause.GetType().Name+": "+cause.Message+Environment.NewLine);
   }catch(IOException){}catch(UnauthorizedAccessException){}
  }
 }
}
