unit main;

interface

uses
  Windows,SysUtils,Forms,imapsend,ssl_openssl,AdvAlertWindow,ExtCtrlsX,AppEvnts,IniFiles,ComCtrls, Classes, Controls, StdCtrls, ExtCtrls,
  Buttons;

type
  TForm1 = class(TForm)
    tmr1: TTimer;
    edLogin: TEdit;
    edPassword: TEdit;
    edImapServer: TEdit;
    edPort: TEdit;
    edCheckCount: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    chUseTLS: TCheckBox;
    chUseSSL: TCheckBox;
    trycn1: TTrayIcon;
    advlrtwndw1: TAdvAlertWindow;
    aplctnvnts1: TApplicationEvents;
    stat1: TStatusBar;
    Label1: TLabel;
    edCheckFolder: TEdit;
    btn2: TBitBtn;
    chkMail: TCheckBox;
    procedure tmr1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DataFilter(Sender: TObject; var Value: AnsiString);
    procedure trycn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure chkMailClick(Sender: TObject);
    procedure edCheckCountChange(Sender: TObject);
  private
    ImapClient: TIMAPSend;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.tmr1Timer(Sender: TObject);
var
  i, NumOfMsgs: Integer; // Количество писем
  MessList: TStringList;
begin
  try
    ImapClient.TargetHost := edImapServer.Text;
    ImapClient.TargetPort := edPort.Text;
    ImapClient.UserName := edLogin.Text;
    ImapClient.Password := edPassword.Text;
    ImapClient.AutoTLS := chUseTLS.Checked;
    ImapClient.FullSSL := chUseSSL.Checked;
    ImapClient.Login;
    ImapClient.SelectFolder('INBOX/' + Form1.edCheckFolder.Text);
    MessList := TStringList.Create;
    if ImapClient.SearchMess('UNSEEN', MessList) then
    begin
      if MessList.Count > 0 then
      begin
        advlrtwndw1.AlertMessages.Add.Text.Text := 'Есть ' +
          IntToStr(MessList.Count) + ' сообщений JIRA';
        advlrtwndw1.Show;
      end;
    end;
    MessList.Free;
    ImapClient.Logout;
  except // Если произошла ошибка- выводим её в Memo1
    on E: Exception do
    begin
      advlrtwndw1.AlertMessages.Add.Text.Text := 'Ошибка подключения! ' +
        E.Message;
      advlrtwndw1.Show;
    end;
  end;

end;

procedure TForm1.DataFilter(Sender: TObject; var Value: AnsiString);
begin
  stat1.SimpleText:=Value;
end;

procedure TForm1.FormCreate(Sender: TObject);
  var
  Ini: Tinifile;
begin
  ImapClient := TIMAPSend.Create;
  ImapClient.Sock.OnReadFilter := DataFilter;
  Ini:=TiniFile.Create(extractfilepath(Application.ExeName)+'Config.ini');
  edLogin.Text:=Ini.ReadString('Options','Login','');
  edPassword.Text:=Ini.ReadString('Options','Pass','');
  edImapServer.Text:=Ini.ReadString('Options','Server','');
  edPort.Text:= Ini.ReadString('Options','Port','993');
  edCheckCount.Text:=Ini.ReadString('Options','Count','30');
  chUseTLS.Checked:=Ini.ReadBool('Options','TSL',true);
  chUseSSL.Checked:=Ini.ReadBool('Options','SSL',true);
 // Form1.Width:=Ini.ReadInteger('Size','Width',427);
 // Form1.Height:=Ini.ReadInteger('Size','Height',204);
 // Form1.Left:=Ini.ReadInteger('Position','X',714);
 // Form1.Top:=Ini.ReadInteger('Position','Y',390);
 Ini.Free;
  tmr1.Interval := StrToInt(edCheckCount.Text) * 1000; // задаём интервал проверки
end;

procedure TForm1.FormDestroy(Sender: TObject);
  var
  Ini: Tinifile;
begin
  ImapClient.Free;
  Ini:=TiniFile.Create(extractfilepath(Application.ExeName)+'Config.ini');
  Ini.WriteString('Options','Login',edLogin.Text);
  Ini.WriteString('Options','Pass',edPassword.Text);
  Ini.WriteString('Options','Server',edImapServer.Text);
  Ini.WriteString('Options','Port',edPort.Text);
  Ini.WriteString('Options','Count', edCheckCount.Text);
  Ini.WriteBool('Options','TSL',chUseTLS.Checked);
  Ini.WriteBool('Options','SSL', chUseSSL.Checked);
//  Ini.WriteInteger('Size','Width',form1.width);
//  Ini.WriteInteger('Size','Height',form1.height);
//  Ini.WriteInteger('Position','X',form1.left);
//  Ini.WriteInteger('Position','Y',form1.top);
  Ini.Free;
end;

procedure TForm1.trycn1Click(Sender: TObject);
begin
  trycn1.Visible := false; // ???????? ?????? ? ????
  Form1.Visible := True; // ?????? ??????? ????? ??????????
  Form1.WindowState := wsNormal; // ?????????????
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  Form1.Visible := false; // ?????? ????? ?????????
  trycn1.Icon := Application.Icon;
  trycn1.Visible := True; // ?????? ?????? ? ???? ???????
end;

procedure TForm1.chkMailClick(Sender: TObject);
begin
  tmr1.Enabled := chkMail.Checked;
  if chkMail.Checked then stat1.SimpleText:= 'Почта будет проверена через '+edCheckCount.Text +' sec.';
end;

procedure TForm1.edCheckCountChange(Sender: TObject);
begin
 tmr1.Enabled := False;
 tmr1.Interval := StrToInt(edCheckCount.Text) * 1000; // задаём интервал проверки
 tmr1.Enabled := True;
end;

end.

