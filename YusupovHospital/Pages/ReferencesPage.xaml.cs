using System;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
namespace YusupovHospital {
 public partial class ReferencesPage:Page {
  readonly PatientsPage previous;
  public ReferencesPage(PatientsPage previous){InitializeComponent();this.previous=previous;}
  async void Page_Loaded(object s,RoutedEventArgs e){try{DoctorsGrid.ItemsSource=await Task.Run(()=>{using(var db=HospitalSession.Open())return db.Doctors.AsNoTracking().OrderBy(d=>d.Фамилия).ToList();});}catch(Exception ex){StatusText.Text="Врачи: "+ex.GetBaseException().Message;}
   try{DepartmentsGrid.ItemsSource=await Task.Run(()=>{using(var db=HospitalSession.Open())return db.Departments.AsNoTracking().OrderBy(d=>d.Название).ToList();});}catch(Exception ex){StatusText.Text+=" Отделения: "+ex.GetBaseException().Message;}}
  void Back_Click(object s,RoutedEventArgs e){Manager.Show(previous);}
 }
}
