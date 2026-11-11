using System;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
namespace YusupovHospital {
 public sealed class HistoryRow{public int Id{get;set;}public string Diagnosis{get;set;}public string Doctor{get;set;}public DateTime Start{get;set;}public DateTime? End{get;set;}public string Treatment{get;set;}}
 public partial class MedicalPage:Page {
  readonly PatientCard card;readonly PatientsPage previous;int request;
  public MedicalPage(PatientCard card,PatientsPage previous){if(!HospitalSession.CanReadMedical)throw new InvalidOperationException("Нет доступа к медицинским записям.");InitializeComponent();this.card=card;this.previous=previous;TitleText.Text=card.FullName;}
  async void Page_Loaded(object s,RoutedEventArgs e){try{var rows=await Task.Run(()=>{using(var db=HospitalSession.Open())return db.MedicalHistories.AsNoTracking().Where(h=>h.Id_пациента==card.Id).OrderByDescending(h=>h.Дата_заболевания).Select(h=>new HistoryRow{Id=h.Id_истории,Diagnosis=h.Диагноз,Doctor=h.Doctors.Фамилия+" "+h.Doctors.Имя,Start=h.Дата_заболевания,End=h.Дата_вылечивания,Treatment=h.Вид_лечения}).ToList();});HistoriesGrid.ItemsSource=rows;StatusText.Text="Историй болезни: "+rows.Count+" • выбери строку для просмотра листов лечения";}catch(Exception ex){StatusText.Text=ex.GetBaseException().Message;}}
  async void History_Changed(object s,SelectionChangedEventArgs e){int version=++request;TreatmentsGrid.ItemsSource=null;var row=HistoriesGrid.SelectedItem as HistoryRow;if(row==null)return;try{var rows=await Task.Run(()=>{using(var db=HospitalSession.Open())return db.TreatmentSheets.AsNoTracking().Where(t=>t.Id_истории==row.Id).OrderByDescending(t=>t.Дата_лечения).ToList();});if(version==request)TreatmentsGrid.ItemsSource=rows;}catch(Exception ex){StatusText.Text=ex.GetBaseException().Message;}}
  void Back_Click(object s,RoutedEventArgs e){request++;Manager.Show(previous);}
 }
}
