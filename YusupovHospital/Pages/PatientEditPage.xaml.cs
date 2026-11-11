using System;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Win32;
namespace YusupovHospital {
 public partial class PatientEditPage:Page {
  readonly PatientsPage previous;readonly int id;string photo;string initial;bool busy;
  public PatientEditPage(PatientCard card,PatientsPage previous){InitializeComponent();this.previous=previous;
   if(card!=null){var p=card.Patient;id=p.Id_пациента;TitleText.Text="Карточка пациента № "+id;LastNameBox.Text=p.Фамилия;FirstNameBox.Text=p.Имя;PatronymicBox.Text=p.Отчество;BirthPicker.SelectedDate=p.Дата_рождения;GenderBox.SelectedIndex=p.Пол=="М"?0:1;AddressBox.Text=card.Address;PhotoImage.Source=card.Photo;PhoneBox.Text=p.Телефон;PolicyBox.Text=p.Полис_ОМС;PassportBox.Text=p.Паспорт;InnBox.Text=p.ИНН;SnilsBox.Text=p.СНИЛС;}
   else{AddressBox.Text="";}
   if(card!=null && card.ClinicalAvailable){ClinicalPanel.DataContext=card;ClinicalPanel.Visibility=Visibility.Visible;}
   Fields.IsEnabled=PhotoButton.IsEnabled=SaveButton.IsEnabled=HospitalSession.CanEditPatients;DeleteButton.Visibility=id>0 && HospitalSession.CanDeletePatients?Visibility.Visible:Visibility.Collapsed;initial=Signature();
  }
  void Photo_Click(object s,RoutedEventArgs e){var dialog=new OpenFileDialog{Filter="Фото PNG/JPEG|*.png;*.jpg;*.jpeg",CheckFileExists=true};if(dialog.ShowDialog()!=true)return;
   try{if(new FileInfo(dialog.FileName).Length>10*1024*1024)throw new InvalidOperationException("Выбери фото размером до 10 МБ.");var image=PatientPhotos.Read(dialog.FileName);photo=dialog.FileName;PhotoImage.Source=image;ErrorText.Text="";}catch(Exception ex){ErrorText.Text="Не удалось открыть изображение: "+ex.Message;}
  }
  async void Save_Click(object s,RoutedEventArgs e){if(busy)return;string city,street;var addressError=PatientRules.ParseAddress(AddressBox.Text,out city,out street);var draft=new Patients{Id_пациента=id,Фамилия=LastNameBox.Text.Trim(),Имя=FirstNameBox.Text.Trim(),Отчество=string.IsNullOrWhiteSpace(PatronymicBox.Text)?null:PatronymicBox.Text.Trim(),Дата_рождения=BirthPicker.SelectedDate??DateTime.MinValue,Пол=(GenderBox.SelectedItem as ComboBoxItem)?.Content.ToString(),Город=city,Адрес=street,Телефон=PhoneBox.Text,Полис_ОМС=PolicyBox.Text,Паспорт=PassportBox.Text,ИНН=InnBox.Text,СНИЛС=SnilsBox.Text};
   ErrorText.Text=PatientRules.Validate(draft);if(addressError.Length>0)ErrorText.Text=addressError+"\n"+ErrorText.Text;if(ErrorText.Text.Length>0)return;busy=true;SaveButton.IsEnabled=DeleteButton.IsEnabled=false;
   try{int saved=await Task.Run(()=>PatientService.Save(draft));if(photo!=null){try{PatientPhotos.Save(saved,photo);}catch(Exception ex){MessageBox.Show("Пациент сохранён, но фото не записано. Открой карточку и выбери его повторно. "+ex.Message,"Фотография");}}Manager.Show(previous);}
   catch(Exception ex){ErrorText.Text="Не удалось сохранить: "+ex.GetBaseException().Message;}
   finally{busy=false;SaveButton.IsEnabled=HospitalSession.CanEditPatients;DeleteButton.IsEnabled=true;}
  }
  async void Delete_Click(object s,RoutedEventArgs e){if(busy)return;if(MessageBox.Show("Удалить карточку № "+id+"? Действие нельзя отменить.","Удаление пациента",MessageBoxButton.YesNo,MessageBoxImage.Warning)!=MessageBoxResult.Yes)return;busy=true;SaveButton.IsEnabled=DeleteButton.IsEnabled=false;
   try{await Task.Run(()=>PatientService.Delete(id));Manager.Show(previous);}catch(Exception ex){ErrorText.Text=ex.GetBaseException().Message;}finally{busy=false;SaveButton.IsEnabled=HospitalSession.CanEditPatients;DeleteButton.IsEnabled=true;}
  }
  string Signature(){return string.Join("|",LastNameBox.Text,FirstNameBox.Text,PatronymicBox.Text,BirthPicker.Text,GenderBox.SelectedIndex.ToString(),AddressBox.Text,PhoneBox.Text,PolicyBox.Text,PassportBox.Text,InnBox.Text,SnilsBox.Text);}
  void Cancel_Click(object s,RoutedEventArgs e){if(busy)return;bool changed=photo!=null || Signature()!=initial;if(changed && MessageBox.Show("Вернуться без сохранения?","Карточка",MessageBoxButton.YesNo)!=MessageBoxResult.Yes)return;Manager.Show(previous);}
 }
}
