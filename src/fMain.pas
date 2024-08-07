/// <summary>
/// ***************************************************************************
///
/// XOR Keys Generator
///
/// Copyright 2024 Patrick Pr�martin under AGPL 3.0 license.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
/// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS IN THE SOFTWARE.
///
/// ***************************************************************************
///
/// A simple generator of random series of bytes that can be used, for
/// example, to encrypt or sign data.
///
/// If you're developing under Delphi or Pascal in general, you can use these blocks with the TOlfCryptDecrypt.XORCrypt and TOlfCryptDecrypt.XORDecrypt functions in the Olf.RTL.CryptDecrypt unit from https://github.com/DeveloppeurPascal/librairies/
///
/// ***************************************************************************
///
/// Author(s) :
/// Patrick PREMARTIN
///
/// Site :
/// https://xorkeysgenerator.olfsoftware.fr/
///
/// Project site :
/// https://github.com/DeveloppeurPascal/XOR-Keys-Generator
///
/// ***************************************************************************
/// File last update : 2024-08-07T08:10:32.000+02:00
/// Signature : bb2ef2fc9b7b977cc5749aeaf81b0941f6250edf
/// ***************************************************************************
/// </summary>

unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Controls.Presentation,
  FMX.Layouts,
  Olf.FMX.AboutDialog,
  FMX.Menus,
  System.Generics.Collections;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    mnuMacOS: TMenuItem;
    mnuFile: TMenuItem;
    mnuQuit: TMenuItem;
    mnuLanguages: TMenuItem;
    mnuPascal: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    OlfAboutDialog1: TOlfAboutDialog;
    VertScrollBox1: TVertScrollBox;
    pnlGeneratedKey: TPanel;
    btnGenerateANewKey: TButton;
    mmoKey: TMemo;
    btnRefreshCode: TButton;
    pnlPascal: TPanel;
    lblPascal: TLabel;
    btnPascalSample: TButton;
    mmoPascal: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure OlfAboutDialog1URLClick(const AURL: string);
    procedure mnuQuitClick(Sender: TObject);
    procedure btnGenerateANewKeyClick(Sender: TObject);
    procedure btnRefreshCodeClick(Sender: TObject);
    procedure mnuLanguageCodeClick(Sender: TObject);
    procedure btnPascalSampleClick(Sender: TObject);
  private
    FFreezePAramsSetValue: boolean;
    FKeySize: integer;
  protected
    procedure InitAboutDialogBox;
    procedure FillPascalCode(const Key: TList<byte>);
    procedure mmoSelectAllOnEnter(Sender: TObject);
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  u_urlOpen,
  Olf.RTL.Params,
  Olf.RTL.CryptDecrypt;

{ TfrmMain }

procedure TfrmMain.btnGenerateANewKeyClick(Sender: TObject);
var
  sKeySize: string;
begin
  randomize;
  sKeySize := FKeySize.ToString;
  InputQuery('Key size', ['How many values do you want for this key ?'],
    [sKeySize],
    procedure(const AResult: TModalResult; const AValues: array of string)
    var
      i: integer;
      Key: TByteDynArray;
      s: string;
    begin
      if (AResult = mrOk) and (length(AValues) = 1) and (not AValues[0].IsEmpty)
      then
      begin
        i := AValues[0].ToInteger;
        if (i < 1) or (i > 2048) then
          raise exception.Create('Please choose a value between 1 and 2048.');

        FKeySize := i;
        Key := TOlfCryptDecrypt.GenXORKey(FKeySize);

        s := '';
        for i := 0 to length(Key) - 1 do
          if (i > 0) then
            s := s + ', ' + Key[i].ToString
          else
            s := Key[i].ToString;
        mmoKey.Text := s;

        btnRefreshCodeClick(btnRefreshCode);
      end;
    end);
end;

procedure TfrmMain.btnPascalSampleClick(Sender: TObject);
begin
  url_Open_In_Browser
    ('https://github.com/DeveloppeurPascal/librairies/tree/master/samples/RTL.CryptDecrypt/SimpleCryptDecryptSample');
end;

procedure TfrmMain.btnRefreshCodeClick(Sender: TObject);
var
  i: integer;
  Key: TList<byte>;
  tab: tstringdynarray;
  nb: integer;
begin
  if mmoKey.Text.IsEmpty then
    btnGenerateANewKeyClick(self);

  tab := mmoKey.Text.replace(' ', '').Split([',']);
  if length(tab) <> FKeySize then
    raise exception.Create('Wrong number of bytes in the list. (' + length(tab)
      .ToString + ' <> ' + FKeySize.ToString + ')');

  Key := TList<byte>.Create;
  try
    for i := 0 to length(tab) - 1 do
      if tab[i].trim.IsEmpty then
        raise exception.Create('An empty value is in the list.')
      else
      begin
        nb := tab[i].trim.ToInteger;
        if (nb >= 0) and (nb < 256) then
          Key.add(nb)
        else
          raise exception.Create('Wrong value ' + nb.ToString +
            '. Must be between 0 and 255.');
      end;

    FillPascalCode(Key);
  finally
    Key.free;
  end;
end;

procedure TfrmMain.FillPascalCode(const Key: TList<byte>);
var
  i: integer;
  s: string;
begin
  mmoPascal.Lines.Clear;
  if mnuPascal.IsChecked then
  begin
    mmoPascal.Lines.add('// declaration');
    mmoPascal.Lines.add('var Key:array of byte;');
    mmoPascal.Lines.add('// implementation');
    s := 'Key := [';
    for i := 0 to Key.count - 1 do
      if i > 0 then
        s := s + ', ' + Key[i].ToString
      else
        s := s + Key[i].ToString;
    s := s + '];';
    mmoPascal.Lines.add(s);
    mmoPascal.Lines.add('// sample of use available at');
    mmoPascal.Lines.add
      ('// https://github.com/DeveloppeurPascal/librairies/tree/master/samples/RTL.CryptDecrypt/SimpleCryptDecryptSample');
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  InitAboutDialogBox;

  FKeySize := 0;

  for i := 0 to ComponentCount - 1 do
    if Components[i] is TMemo then
      (Components[i] as TMemo).OnEnter := mmoSelectAllOnEnter;

  // Menu
{$IF Defined(MACOS) and not Defined(IOS)}
  mnuAbout.Parent := mnuMacOS;
  mnuQuit.Visible := false;
  mnuFile.Visible := false;
{$ENDIF}
  mnuMacOS.Visible := (mnuMacOS.ItemsCount > 0);
  mnuHelp.Visible := (mnuHelp.ItemsCount > 0);

  FFreezePAramsSetValue := true;
  try
    for i := 0 to mnuLanguages.ItemsCount - 1 do
      repeat
        mnuLanguageCodeClick(mnuLanguages.Items[i]);
      until (mnuLanguages.Items[i].IsChecked = TParams.getValue
        (mnuLanguages.Items[i].name, true));
  finally
    FFreezePAramsSetValue := false;
  end;
end;

procedure TfrmMain.InitAboutDialogBox;
begin
  // TODO : traduire texte(s)
  OlfAboutDialog1.Licence.Text :=
    'This program is distributed as shareware. If you use it (especially for ' +
    'commercial or income-generating purposes), please remember the author and '
    + 'contribute to its development by purchasing a license.' + slinebreak +
    slinebreak +
    'This software is supplied as is, with or without bugs. No warranty is offered '
    + 'as to its operation or the data processed. Make backups!';
  OlfAboutDialog1.Description.Text :=
    'XOR keys Generator creates a randomly generated serie of bytes as an array depending on the language you use.'
    + slinebreak + slinebreak + '*****************' + slinebreak +
    '* Publisher info' + slinebreak + slinebreak +
    'This application was developed by Patrick Pr�martin.' + slinebreak +
    slinebreak +
    'It is published by OLF SOFTWARE, a company registered in Paris (France) under the reference 439521725.'
    + slinebreak + slinebreak + '****************' + slinebreak +
    '* Personal data' + slinebreak + slinebreak +
    'This program is autonomous in its current version. It does not depend on the Internet and communicates nothing to the outside world.'
    + slinebreak + slinebreak + 'We have no knowledge of what you do with it.' +
    slinebreak + slinebreak +
    'No information about you is transmitted to us or to any third party.' +
    slinebreak + slinebreak +
    'We use no cookies, no tracking, no stats on your use of the application.' +
    slinebreak + slinebreak + '**********************' + slinebreak +
    '* User support' + slinebreak + slinebreak +
    'If you have any questions or require additional functionality, please leave us a message on the application''s website or on its code repository.'
    + slinebreak + slinebreak + 'To find out more, visit ' +
    OlfAboutDialog1.URL;
end;

procedure TfrmMain.mmoSelectAllOnEnter(Sender: TObject);
begin
  if Sender is TMemo then
    (Sender as TMemo).SelectAll;
end;

procedure TfrmMain.mnuAboutClick(Sender: TObject);
begin
  OlfAboutDialog1.Execute;
end;

procedure TfrmMain.mnuLanguageCodeClick(Sender: TObject);
var
  mnu: TMenuItem;
  pnlName: string;
  FmxO: TFMXObject;
begin
  if Sender is TMenuItem then
  begin
    mnu := Sender as TMenuItem;

    mnu.IsChecked := not mnu.IsChecked;

    if not FFreezePAramsSetValue then
      TParams.setValue(mnu.name, mnu.IsChecked);

    pnlName := 'pnl' + string(mnu.name).Substring('mnu'.length).ToLower;

    for FmxO in VertScrollBox1.Content.Children do
      if (FmxO is TPanel) and (string((FmxO as TPanel).name).ToLower = pnlName)
      then
      begin
        (FmxO as TPanel).Visible := mnu.IsChecked;
        break;
      end;
  end;
end;

procedure TfrmMain.mnuQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.OlfAboutDialog1URLClick(const AURL: string);
begin
  url_Open_In_Browser(AURL);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
TParams.InitDefaultFileNameV2('OlfSoftware', 'XORKeysGen', false);
{$IF Defined(RELEASE)}
TParams.onCryptProc := function(Const AParams: string): TStream
  var
    Keys: TByteDynArray;
    ParStream: TStringStream;
  begin
    ParStream := TStringStream.Create(AParams);
    try
{$I '..\_PRIVATE\src\paramsxorkey.inc'}
      result := TOlfCryptDecrypt.XORCrypt(ParStream, Keys);
    finally
      ParStream.free;
    end;
  end;
TParams.onDecryptProc := function(Const AStream: TStream): string
  var
    Keys: TByteDynArray;
    Stream: TStream;
    StringStream: TStringStream;
  begin
{$I '..\_PRIVATE\src\paramsxorkey.inc'}
    result := '';
    Stream := TOlfCryptDecrypt.XORdeCrypt(AStream, Keys);
    try
      if assigned(Stream) and (Stream.Size > 0) then
      begin
        StringStream := TStringStream.Create;
        try
          Stream.Position := 0;
          StringStream.CopyFrom(Stream);
          result := StringStream.DataString;
        finally
          StringStream.free;
        end;
      end;
    finally
      Stream.free;
    end;
  end;
{$ENDIF}
TParams.load;

end.
