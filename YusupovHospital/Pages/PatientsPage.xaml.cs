using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
namespace YusupovHospital {
 public partial class PatientsPage:Page {
  List<PatientCard> all=new List<PatientCard>(),filtered=new List<PatientCard>();int page;bool ready,busy;const int Size=10;
  public PatientsPage(){
   InitializeComponent();AddButton.IsEnabled=HospitalSession.CanEditPatients;
   MedicalFilters.Visibility=HospitalSession.CanReadMedical?Visibility.Visible:Visibility.Collapsed;
   SearchLabel.Text=HospitalSession.CanReadMedical?"Поиск: ФИО, телефон, документы, диагноз":"Поиск: ФИО, телефон, документы, адрес";
   var sorts=new List<string>{"ФИО: А → Я","ФИО: Я → А"};
   if(HospitalSession.CanReadMedical)sorts.AddRange(new[]{"Начало лечения: сначала новые","Начало лечения: сначала ранние"});
   SortBox.ItemsSource=sorts;SortBox.SelectedIndex=0;
  }
  async void Page_Loaded(object s,RoutedEventArgs e){await Reload();}
  async Task Reload(){if(busy)return;busy=true;ready=false;RefreshButton.IsEnabled=false;StatusText.Text="Загрузка…";
   try{
    int department=(DepartmentBox.SelectedItem as DepartmentOption)?.Id??-1;
    all=await Task.Run(()=>PatientService.Load());
    var options=new List<DepartmentOption>{new DepartmentOption{Id=-1,Name="Все отделения"}};
    options.AddRange(all.SelectMany(p=>p.Histories).GroupBy(h=>h.DepartmentId).Select(g=>new DepartmentOption{Id=g.Key,Name=g.First().Department}).OrderBy(d=>d.Name));
    DepartmentBox.ItemsSource=options;DepartmentBox.SelectedItem=options.FirstOrDefault(d=>d.Id==department)??options[0];
    ready=true;Apply(false);StatusText.Text="";
   }catch(Exception ex){all.Clear();filtered.Clear();PatientsList.ItemsSource=null;CountText.Text="Данные не загружены";StatusText.Text="Ошибка: "+ex.GetBaseException().Message;}
   finally{busy=false;RefreshButton.IsEnabled=true;}
  }
  void Filter_Changed(object s,RoutedEventArgs e){Apply(true);}
  void Apply(bool reset){if(!ready)return;if(reset)page=0;string treatment=(TreatmentBox.SelectedItem as ComboBoxItem)?.Content.ToString();int department=(DepartmentBox.SelectedItem as DepartmentOption)?.Id??-1;filtered=PatientRules.Query(all,SearchBox.Text,HospitalSession.CanReadMedical?StatusBox.SelectedIndex:0,HospitalSession.CanReadMedical?treatment:null,HospitalSession.CanReadMedical?department:-1,SortBox.SelectedIndex);Render();}
  void Render(){int pages=Math.Max(1,(filtered.Count+Size-1)/Size);page=Math.Max(0,Math.Min(page,pages-1));var rows=filtered.Skip(page*Size).Take(Size).ToList();PatientsList.ItemsSource=rows;CountText.Text="Найдено: "+filtered.Count+" из "+all.Count+" • на странице: "+rows.Count;PageText.Text=(page+1)+" / "+pages;PreviousButton.IsEnabled=page>0;NextButton.IsEnabled=page<pages-1;EmptyText.Visibility=filtered.Count==0?Visibility.Visible:Visibility.Collapsed;}
  void Previous_Click(object s,RoutedEventArgs e){page--;Render();}void Next_Click(object s,RoutedEventArgs e){page++;Render();}
  async void Refresh_Click(object s,RoutedEventArgs e){await Reload();}
  void Reset_Click(object s,RoutedEventArgs e){SearchBox.Text="";StatusBox.SelectedIndex=0;TreatmentBox.SelectedIndex=0;DepartmentBox.SelectedIndex=0;SortBox.SelectedIndex=0;Apply(true);}
  void Add_Click(object s,RoutedEventArgs e){if(HospitalSession.CanEditPatients)Manager.Show(new PatientEditPage(null,this));}
  void Edit_Click(object s,RoutedEventArgs e){Manager.Show(new PatientEditPage(((Button)s).DataContext as PatientCard,this));}
  void History_Click(object s,RoutedEventArgs e){if(!HospitalSession.CanReadMedical){MessageBox.Show("Регистратору недоступны медицинские записи.");return;}Manager.Show(new MedicalPage(((Button)s).DataContext as PatientCard,this));}
  void References_Click(object s,RoutedEventArgs e){Manager.Show(new ReferencesPage(this));}
 }
}
