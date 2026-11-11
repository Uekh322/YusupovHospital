using System;
using System.Configuration;
using System.Data.Entity;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
namespace YusupovHospital {
 public enum HospitalRole {None, Registrar, Doctor, ChiefDoctor}
 public partial class HospitalBDEntities {
  static HospitalBDEntities(){Database.SetInitializer<HospitalBDEntities>(null);}
  public HospitalBDEntities(string connection):base(connection){Configuration.LazyLoadingEnabled=false;Configuration.ProxyCreationEnabled=false;}
 }
 public static class HospitalSession {
  static string connection;
  public static HospitalRole Role {get;private set;}
  public static string UserName {get;private set;}
  public static string ServerName {get;private set;}
  public static bool CanEditPatients {get{return Role==HospitalRole.ChiefDoctor || Role==HospitalRole.Registrar;}}
  public static bool CanDeletePatients {get{return Role==HospitalRole.ChiefDoctor;}}
  public static bool CanReadMedical {get{return Role==HospitalRole.ChiefDoctor || Role==HospitalRole.Doctor;}}
  public static string RoleTitle {get{return Role==HospitalRole.ChiefDoctor?"Главный врач":Role==HospitalRole.Doctor?"Врач":"Регистратор";}}
  public static void Login(string login,string password){
   Logout();
   var entity=new EntityConnectionStringBuilder(ConfigurationManager.ConnectionStrings["HospitalBDEntities"].ConnectionString);
   var sql=new SqlConnectionStringBuilder(entity.ProviderConnectionString){IntegratedSecurity=false,ConnectTimeout=30,PersistSecurityInfo=false,UserID=login,Password=password};
   string configuredServer=sql.DataSource;
   sql.DataSource=LocalDbStartup.ResolveDataSource(configuredServer);
   using(var db=new SqlConnection(sql.ConnectionString)){
    db.Open();
    using(var cmd=new SqlCommand("SELECT CASE WHEN IS_ROLEMEMBER('db_owner')=1 OR IS_ROLEMEMBER('ChiefDoctorRole')=1 THEN 3 WHEN IS_ROLEMEMBER('DoctorRole')=1 THEN 2 WHEN IS_ROLEMEMBER('RegistrarRole')=1 THEN 1 ELSE 0 END, ORIGINAL_LOGIN()",db))
    using(var r=cmd.ExecuteReader()) {r.Read();Role=(HospitalRole)r.GetInt32(0);UserName=r.GetString(1);}
   }
   if(Role==HospitalRole.None){Logout();throw new InvalidOperationException("Учётная запись не включена в роль больницы. Обратитесь к администратору БД.");}
   entity.ProviderConnectionString=sql.ConnectionString;connection=entity.ConnectionString;ServerName=configuredServer;
  }
  public static HospitalBDEntities Open(){if(connection==null)throw new InvalidOperationException("Требуется вход в систему.");return new HospitalBDEntities(connection);}
  public static void Logout(){connection=null;Role=HospitalRole.None;UserName=null;ServerName=null;}
 }
 internal static class LocalDbStartup {
  // msoledbsql.h: LocalDBInstanceInfo, pack(8), WCHAR is UTF-16, BOOL/DWORD are 32-bit.
  [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode,Pack=8)]
  struct InstanceInfo {
   public uint Size;
   [MarshalAs(UnmanagedType.ByValTStr,SizeConst=129)]public string Name;
   public int Exists,ConfigurationCorrupted,Running;
   public uint Major,Minor,Build,Revision;
   public System.Runtime.InteropServices.ComTypes.FILETIME LastStart;
   [MarshalAs(UnmanagedType.ByValTStr,SizeConst=260)]public string Connection;
   public int Shared;
   [MarshalAs(UnmanagedType.ByValTStr,SizeConst=129)]public string SharedName;
   [MarshalAs(UnmanagedType.ByValTStr,SizeConst=187)]public string OwnerSid;
   public int Automatic;
  }
  [UnmanagedFunctionPointer(CallingConvention.Cdecl,CharSet=CharSet.Unicode)]
  delegate int GetInstanceInfo(string instance,ref InstanceInfo info,uint size);
  [UnmanagedFunctionPointer(CallingConvention.Cdecl,CharSet=CharSet.Unicode)]
  delegate int StartInstance(string instance,uint flags,[Out]StringBuilder connection,ref uint capacity);
  [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)]
  static extern IntPtr LoadLibraryEx(string path,IntPtr reserved,uint flags);
  [DllImport("kernel32.dll",CharSet=CharSet.Ansi,ExactSpelling=true,SetLastError=true)]
  static extern IntPtr GetProcAddress(IntPtr module,string name);
  [DllImport("kernel32.dll")]static extern bool FreeLibrary(IntPtr module);

  public static string ResolveDataSource(string server){
   const string prefix="(localdb)\\";
   if(!server.StartsWith(prefix,StringComparison.OrdinalIgnoreCase))return server;
   string instance=server.Substring(prefix.Length);
   if(!Regex.IsMatch(instance,@"^[A-Za-z0-9_ .-]+$"))return server;
   string library=FindLibrary();
   // The registry view matches this process: x86 loads the installed x86 DLL, x64 loads x64.
   IntPtr module=LoadLibraryEx(library,IntPtr.Zero,8); // LOAD_WITH_ALTERED_SEARCH_PATH, absolute installed path.
   if(module==IntPtr.Zero)throw new Win32Exception(Marshal.GetLastWin32Error(),"Не удалось загрузить библиотеку LocalDB.");
   try{
    var getInfo=(GetInstanceInfo)Marshal.GetDelegateForFunctionPointer(FindExport(module,"LocalDBGetInstanceInfo"),typeof(GetInstanceInfo));
    var info=new InstanceInfo{Size=(uint)Marshal.SizeOf(typeof(InstanceInfo))};
    CheckResult(getInfo(instance,ref info,info.Size),"получить состояние");
    if(info.Exists==0 || info.ConfigurationCorrupted!=0)throw new InvalidOperationException("Существующий экземпляр LocalDB недоступен или повреждён.");
    string connection=info.Connection;
    if(info.Running==0){
     var start=(StartInstance)Marshal.GetDelegateForFunctionPointer(FindExport(module,"LocalDBStartInstance"),typeof(StartInstance));
     var buffer=new StringBuilder(260);uint capacity=(uint)buffer.Capacity;
     CheckResult(start(instance,0,buffer,ref capacity),"запустить");connection=buffer.ToString();
    }
    // The API returns the current pipe directly; no localized console output or encoding to parse.
    connection=(connection??"").Trim();
    if(connection.StartsWith(@"\\.\pipe\",StringComparison.OrdinalIgnoreCase))connection="np:"+connection;
    if(!connection.StartsWith(@"np:\\.\pipe\",StringComparison.OrdinalIgnoreCase))throw new InvalidOperationException("LocalDB не вернула адрес своего канала.");
    return connection;
   }finally{FreeLibrary(module);}
  }
  static string FindLibrary(){
   using(var versions=Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Microsoft SQL Server Local DB\Installed Versions")){
    if(versions!=null){
     var names=versions.GetSubKeyNames().Select(n=>new{Name=n,Version=ParseVersion(n)}).Where(n=>n.Version!=null).OrderByDescending(n=>n.Version);
     foreach(var name in names)using(var version=versions.OpenSubKey(name.Name)){
      string path=version==null?null:version.GetValue("InstanceAPIPath") as string;
      if(!string.IsNullOrEmpty(path) && Path.IsPathRooted(path) && File.Exists(path))return path;
     }
    }
   }
   throw new InvalidOperationException("Не найдена установленная библиотека LocalDB для разрядности приложения.");
  }
  static Version ParseVersion(string text){Version version;return Version.TryParse(text,out version)?version:null;}
  static IntPtr FindExport(IntPtr module,string name){var pointer=GetProcAddress(module,name);if(pointer==IntPtr.Zero)throw new InvalidOperationException("В библиотеке LocalDB отсутствует "+name+".");return pointer;}
  static void CheckResult(int result,string action){if(result<0)throw new InvalidOperationException("Не удалось "+action+" LocalDB. Код: 0x"+unchecked((uint)result).ToString("X8")+".");}
 }
}
