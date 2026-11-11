using System.Windows.Controls;
namespace YusupovHospital {
 public static class Manager {
  public static Frame MainFrame {get;set;}
  public static void Show(Page page){MainFrame.Navigate(page); while(MainFrame.CanGoBack) MainFrame.RemoveBackEntry();}
 }
}
