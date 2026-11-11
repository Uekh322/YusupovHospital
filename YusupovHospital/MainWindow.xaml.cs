using System.Windows;
using System.Windows.Navigation;
namespace YusupovHospital {
 public partial class MainWindow : Window {
  public MainWindow(){ InitializeComponent(); Manager.MainFrame=MainFrame; ShowLogin(); }
  public void ShowLogin(){ HospitalSession.Logout(); SessionLabel.Text=""; ExitButton.Visibility=Visibility.Collapsed; Manager.Show(new LoginPage()); }
  public void ShowPatients(){ SessionLabel.Text=HospitalSession.UserName+" • "+HospitalSession.RoleTitle; ExitButton.Visibility=Visibility.Visible; Manager.Show(new PatientsPage()); }
  void Logout_Click(object s,RoutedEventArgs e){ if(MessageBox.Show("Завершить сеанс? Несохранённые изменения будут потеряны.","Выход",MessageBoxButton.YesNo)==MessageBoxResult.Yes) ShowLogin(); }
  void MainFrame_Navigating(object s,NavigatingCancelEventArgs e){ if(e.NavigationMode!=NavigationMode.New) e.Cancel=true; }
 }
}
