using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Linq;
namespace YusupovHospital {
 public static class PatientService {
  public static List<PatientCard> Load(){
   using(var db=HospitalSession.Open()){
    var cards=db.Patients.AsNoTracking().ToList().Select(p=>new PatientCard{Patient=p,ClinicalAvailable=HospitalSession.CanReadMedical}).ToList();
    if(!HospitalSession.CanReadMedical)return cards;
    var histories=db.MedicalHistories.AsNoTracking().Include("Doctors").ToList();
    var departments=new Dictionary<int,string>();
    // DoctorRole may not have SELECT on Departments; do not broaden database permissions.
    bool canReadDepartments=db.Database.SqlQuery<int?>("SELECT HAS_PERMS_BY_NAME(N'dbo.Departments', N'OBJECT', N'SELECT')").Single().GetValueOrDefault()==1;
    if(canReadDepartments)departments=db.Departments.AsNoTracking().ToDictionary(d=>d.Id_отделения,d=>d.Название);
    var grouped=histories.GroupBy(h=>h.Id_пациента).ToDictionary(g=>g.Key,g=>g.ToList());
    foreach(var card in cards){
     List<MedicalHistories> patientHistories;if(!grouped.TryGetValue(card.Id,out patientHistories))continue;
     foreach(var h in patientHistories){
      var doctor=h.Doctors;int departmentId=doctor==null?0:doctor.Id_отделения;string department;
      if(!departments.TryGetValue(departmentId,out department))department=departmentId==0?"Не указано":"Отделение № "+departmentId;
      card.Histories.Add(new PatientHistoryInfo{Id=h.Id_истории,Diagnosis=h.Диагноз,Doctor=doctor==null?"Не указан":(doctor.Фамилия+" "+doctor.Имя+" "+doctor.Отчество).Trim(),DepartmentId=departmentId,Department=department,Treatment=h.Вид_лечения,Start=h.Дата_заболевания,End=h.Дата_вылечивания});
     }
    }
    return cards;
   }
  }
  public static int Save(Patients draft){
   if(!HospitalSession.CanEditPatients)throw new InvalidOperationException("Нет прав на изменение пациентов.");
   var error=PatientRules.Validate(draft);if(error.Length>0)throw new InvalidOperationException(error);
   using(var db=HospitalSession.Open()){
    Patients target;
    if(draft.Id_пациента==0){target=new Patients();db.Patients.Add(target);}else{target=db.Patients.Find(draft.Id_пациента);if(target==null)throw new InvalidOperationException("Пациент уже удалён. Обнови список.");}
    target.Фамилия=draft.Фамилия;target.Имя=draft.Имя;target.Отчество=draft.Отчество;target.Дата_рождения=draft.Дата_рождения;target.Пол=draft.Пол;target.Город=draft.Город;target.Адрес=draft.Адрес;
    target.Паспорт=draft.Паспорт;target.Полис_ОМС=draft.Полис_ОМС;target.ИНН=draft.ИНН;target.СНИЛС=draft.СНИЛС;target.Телефон=draft.Телефон;
    try{db.SaveChanges();}catch(DbUpdateException ex){var sql=ex.GetBaseException() as SqlException;if(sql!=null && (sql.Number==2601 || sql.Number==2627)){string field=sql.Message.Contains("UX_Patients_Passport")?"паспорт":sql.Message.Contains("UX_Patients_Oms")?"полис ОМС":sql.Message.Contains("UX_Patients_Inn")?"ИНН":sql.Message.Contains("UX_Patients_Snils")?"СНИЛС":"документ";throw new InvalidOperationException("Этот "+field+" уже указан у другого пациента.");}throw;}return target.Id_пациента;
   }
  }
  public static void Delete(int id){
   if(!HospitalSession.CanDeletePatients)throw new InvalidOperationException("Удаление доступно только главному врачу.");
   using(var db=HospitalSession.Open())using(var tx=db.Database.BeginTransaction(IsolationLevel.Serializable)){
    // Блокируем карточку и диапазон историй: проверка и удаление составляют одну транзакцию.
    db.Database.SqlQuery<int>("SELECT [Id_пациента] FROM dbo.Patients WITH (UPDLOCK,HOLDLOCK) WHERE [Id_пациента]=@p0",id).ToList();
    if(db.MedicalHistories.Any(h=>h.Id_пациента==id))throw new InvalidOperationException("Удаление запрещено: у пациента есть истории болезни.");
    var patient=db.Patients.Find(id);if(patient==null)throw new InvalidOperationException("Пациент уже удалён. Обнови список.");
    db.Patients.Remove(patient);db.SaveChanges();tx.Commit();
   }
  }
 }
}
