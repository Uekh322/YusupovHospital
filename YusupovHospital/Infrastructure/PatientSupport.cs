using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
namespace YusupovHospital {
 public sealed class PatientHistoryInfo {
  public int Id {get;set;}
  public string Diagnosis {get;set;}
  public string Doctor {get;set;}
  public int DepartmentId {get;set;}
  public string Department {get;set;}
  public string Treatment {get;set;}
  public DateTime Start {get;set;}
  public DateTime? End {get;set;}
 }
 public sealed class DepartmentOption {
  public int Id {get;set;}
  public string Name {get;set;}
  public override string ToString(){return Name;}
 }
 public sealed class PatientCard {
  public PatientCard(){Histories=new List<PatientHistoryInfo>();}
  public Patients Patient {get;set;}
  public bool ClinicalAvailable {get;set;}
  public List<PatientHistoryInfo> Histories {get;set;}
  public int Id {get{return Patient.Id_пациента;}}
  public string FullName {get{return (Patient.Фамилия+" "+Patient.Имя+" "+Patient.Отчество).Trim();}}
  public int Age {get{return PatientRules.Age(Patient.Дата_рождения,DateTime.Today);}}
  public string Details {get{return "Дата рождения: "+Patient.Дата_рождения.ToString("dd.MM.yyyy")+" • Возраст: "+Age+" • Пол: "+(Patient.Пол=="М"?"мужской":"женский");}}
  public string Address {get{return PatientRules.FormatAddress(Patient.Город,Patient.Адрес);}}
  public ImageSource Photo {get{return PatientPhotos.Load(Id);}}
  public string PhoneLine {get{return "Телефон: "+(Patient.Телефон??"не указан");}}
  public string PassportLine {get{return "Паспорт: "+(Patient.Паспорт??"не указан");}}
  public string PolicyLine {get{return "Полис ОМС: "+(Patient.Полис_ОМС??"не указан");}}
  public string InnLine {get{return "ИНН: "+(Patient.ИНН??"не указан");}}
  public string SnilsLine {get{return "СНИЛС: "+(Patient.СНИЛС??"не указан");}}

  public Visibility ClinicalVisibility {get{return ClinicalAvailable?Visibility.Visible:Visibility.Collapsed;}}
  public PatientHistoryInfo PrimaryHistory {get{return ClinicalAvailable?Histories.OrderBy(h=>h.End.HasValue).ThenByDescending(h=>h.Start).ThenByDescending(h=>h.Id).FirstOrDefault():null;}}
  public int TreatmentStatus {get{return !ClinicalAvailable?-1:Histories.Count==0?3:Histories.Any(h=>!h.End.HasValue)?1:2;}}
  public string Status {get{return TreatmentStatus==1?"На лечении":TreatmentStatus==2?"Лечение завершено":TreatmentStatus==3?"Без историй болезни":"";}}
  public DateTime? CaseStart {get{return PrimaryHistory==null?(DateTime?)null:PrimaryHistory.Start;}}
  public string CaseHeading {get{return PrimaryHistory==null?"Лечение":PrimaryHistory.End.HasValue?"Последний случай лечения":"Текущий случай лечения";}}
  public string HistoriesLine {get{return "Историй болезни: "+Histories.Count+" • Незавершённых: "+Histories.Count(h=>!h.End.HasValue);}}
  public string DiagnosisLine {get{return "Диагноз: "+(PrimaryHistory==null?"—":PrimaryHistory.Diagnosis);}}
  public string DoctorLine {get{return "Лечащий врач: "+(PrimaryHistory==null?"—":PrimaryHistory.Doctor);}}
  public string DepartmentLine {get{return "Отделение: "+(PrimaryHistory==null?"—":PrimaryHistory.Department);}}
  public string TreatmentLine {get{return "Вид лечения: "+(PrimaryHistory==null?"—":PrimaryHistory.Treatment);}}
  public string DatesLine {get{return PrimaryHistory==null?"Даты лечения: —":"Начало: "+PrimaryHistory.Start.ToString("dd.MM.yyyy")+" • Завершение: "+(PrimaryHistory.End.HasValue?PrimaryHistory.End.Value.ToString("dd.MM.yyyy"):"лечение продолжается");}}
 }
 public static class PatientRules {
  public static int Age(DateTime birth,DateTime today){int age=today.Year-birth.Year;return birth.Date>today.Date.AddYears(-age)?age-1:age;}
  public static string Validate(Patients p){
   NormalizeIdentityFields(p);
   var errors=new List<string>();
   if(string.IsNullOrWhiteSpace(p.Фамилия))errors.Add("Укажи фамилию.");
   if(string.IsNullOrWhiteSpace(p.Имя))errors.Add("Укажи имя.");
   if(string.IsNullOrWhiteSpace(p.Адрес))errors.Add("Укажи адрес.");
   if(string.IsNullOrWhiteSpace(p.Город))errors.Add("Укажи город.");
   if(p.Дата_рождения==DateTime.MinValue || p.Дата_рождения.Date>DateTime.Today)errors.Add("Укажи дату рождения не позднее сегодняшнего дня.");
   if(p.Пол!="М" && p.Пол!="Ж")errors.Add("Выбери пол.");
   if((p.Фамилия??"").Length>100 || (p.Имя??"").Length>100 || (p.Отчество??"").Length>100 || (p.Город??"").Length>100 || (p.Адрес??"").Length>255) errors.Add("Превышена допустимая длина поля.");

   CheckDocument(p.Паспорт,@"^[0-9]{4} [0-9]{6}$","Паспорт должен содержать серию из 4 и номер из 6 цифр.",false,errors);
   CheckDocument(p.Полис_ОМС,@"^[0-9]{16}$","Полис ОМС должен содержать 16 цифр.",true,errors);
   CheckDocument(p.ИНН,@"^[0-9]{12}$","ИНН должен содержать 12 цифр.",false,errors);
   CheckDocument(p.СНИЛС,@"^[0-9]{3}-[0-9]{3}-[0-9]{3} [0-9]{2}$","СНИЛС должен содержать 11 цифр.",false,errors);
   CheckDocument(p.Телефон,@"^\+7 \([0-9]{3}\) [0-9]{3}-[0-9]{2}-[0-9]{2}$","Телефон должен содержать 11 цифр и начинаться с +7 или 8.",true,errors);
   return string.Join("\n",errors);
  }


  static void CheckDocument(string value,string pattern,string message,bool required,List<string> errors){if(string.IsNullOrEmpty(value)){if(required)errors.Add(message);return;}if(!Regex.IsMatch(value,pattern))errors.Add(message);}
  public static string NumberValue(string text){var value=Regex.Replace(text??"",@"[\s()-]","");return value.Length==0?null:value;}
  public static void NormalizeIdentityFields(Patients p){
   string passport=NumberValue(p.Паспорт);
   p.Паспорт=passport!=null && Regex.IsMatch(passport,@"^[0-9]{10}$")?passport.Substring(0,4)+" "+passport.Substring(4):passport;
   p.Полис_ОМС=NumberValue(p.Полис_ОМС);p.ИНН=NumberValue(p.ИНН);
   string snils=NumberValue(p.СНИЛС);
   p.СНИЛС=snils!=null && Regex.IsMatch(snils,@"^[0-9]{11}$")?snils.Substring(0,3)+"-"+snils.Substring(3,3)+"-"+snils.Substring(6,3)+" "+snils.Substring(9):snils;
   string phone=NumberValue(p.Телефон);
   if(phone!=null && phone.StartsWith("+"))phone=phone.Substring(1);
   if(phone!=null && Regex.IsMatch(phone,@"^[78][0-9]{10}$"))p.Телефон="+7 ("+phone.Substring(1,3)+") "+phone.Substring(4,3)+"-"+phone.Substring(7,2)+"-"+phone.Substring(9,2);
   else p.Телефон=phone;
  }

  public static string FormatAddress(string city,string address){return string.Join(", ",new[]{city,address}.Where(p=>!string.IsNullOrWhiteSpace(p)).Select(p=>p.Trim()));}
  public static string ParseAddress(string fullAddress,out string city,out string street){
   city="";street="";var input=(fullAddress??"").Trim();int comma=input.IndexOf(',');
   if(comma<=0 || comma==input.Length-1)return "Укажи полный адрес: город, улица, дом.";
   city=input.Substring(0,comma).Trim();street=input.Substring(comma+1).Trim();
   if(city.Length==0 || street.Length==0)return "Укажи полный адрес: город, улица, дом.";
   if(city.Length>100 || street.Length>255)return "Адрес слишком длинный: город — до 100 символов, остальная часть — до 255.";
   return "";
  }
  // All clinical filters apply to the same current case (or last case after recovery).
  public static List<PatientCard> Query(IEnumerable<PatientCard> source,string search,int status,string treatment,int departmentId,int sort){
   var rows=source;search=(search??"").Trim();
   if(search.Length>0){string digits=Regex.Replace(search,@"[^0-9]","");bool numeric=digits.Length>=3 && !search.Any(char.IsLetter);rows=rows.Where(p=>SearchText(p).IndexOf(search,StringComparison.CurrentCultureIgnoreCase)>=0 || (numeric && IdentityDigits(p).Contains(digits)));}
   if(status>0)rows=rows.Where(p=>p.ClinicalAvailable && p.TreatmentStatus==status);
   if(!string.IsNullOrEmpty(treatment) && treatment!="Любой вид лечения")rows=rows.Where(p=>p.PrimaryHistory!=null && p.PrimaryHistory.Treatment==treatment);
   if(departmentId>=0)rows=rows.Where(p=>p.PrimaryHistory!=null && p.PrimaryHistory.DepartmentId==departmentId);
   switch(sort){
    case 1:rows=rows.OrderByDescending(p=>p.FullName,StringComparer.CurrentCultureIgnoreCase).ThenBy(p=>p.Id);break;
    case 2:rows=rows.OrderBy(p=>!p.CaseStart.HasValue).ThenByDescending(p=>p.CaseStart).ThenBy(p=>p.FullName,StringComparer.CurrentCultureIgnoreCase).ThenBy(p=>p.Id);break;
    case 3:rows=rows.OrderBy(p=>!p.CaseStart.HasValue).ThenBy(p=>p.CaseStart).ThenBy(p=>p.FullName,StringComparer.CurrentCultureIgnoreCase).ThenBy(p=>p.Id);break;
    default:rows=rows.OrderBy(p=>p.FullName,StringComparer.CurrentCultureIgnoreCase).ThenBy(p=>p.Id);break;
   }
   return rows.ToList();
  }
  static string IdentityDigits(PatientCard p){return string.Join(" ",new[]{p.Patient.Телефон,p.Patient.Паспорт,p.Patient.Полис_ОМС,p.Patient.ИНН,p.Patient.СНИЛС}.Select(v=>Regex.Replace(v??"",@"[^0-9]","")));}
  static string SearchText(PatientCard p){var h=p.PrimaryHistory;return p.FullName+" "+p.Address+" "+p.Id+" "+p.Patient.Телефон+" "+p.Patient.Паспорт+" "+p.Patient.Полис_ОМС+" "+p.Patient.ИНН+" "+p.Patient.СНИЛС+(h==null?"":" "+h.Diagnosis+" "+h.Doctor+" "+h.Department);}
 }
 public static class PatientPhotos {
  static string Folder {get{using(var hash=SHA256.Create()){var key=BitConverter.ToString(hash.ComputeHash(Encoding.UTF8.GetBytes(HospitalSession.ServerName??"default"))).Replace("-","").Substring(0,16);return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"YusupovHospital","Photos",key);}}}
  public static ImageSource Read(string path){var img=new BitmapImage();using(var stream=File.OpenRead(path)){img.BeginInit();img.CacheOption=BitmapCacheOption.OnLoad;img.DecodePixelWidth=600;img.StreamSource=stream;img.EndInit();img.Freeze();}return img;}
  public static ImageSource Load(int id){try{var path=Path.Combine(Folder,id+".png");if(File.Exists(path))return Read(path);}catch(IOException){}catch(NotSupportedException){}catch(UnauthorizedAccessException){}catch(System.IO.FileFormatException){}return (ImageSource)Application.Current.FindResource("PatientPlaceholder");}
  public static void Save(int id,string source){Directory.CreateDirectory(Folder);var image=(BitmapSource)Read(source);var encoder=new PngBitmapEncoder();encoder.Frames.Add(BitmapFrame.Create(image));var path=Path.Combine(Folder,id+".png");var temp=path+".tmp";try{using(var stream=File.Create(temp))encoder.Save(stream);if(File.Exists(path))File.Replace(temp,path,null);else File.Move(temp,path);}finally{if(File.Exists(temp))File.Delete(temp);}}
 }
}
