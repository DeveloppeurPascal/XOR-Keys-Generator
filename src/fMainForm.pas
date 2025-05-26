(* C2PP
  ***************************************************************************

  XOR Keys Generator

  Copyright 2024-2025 Patrick Prémartin under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  A simple generator of random series of bytes that can be used, for
  example, to encrypt or sign data.

  If you're developing under Delphi or Pascal in general, you can use these blocks with the TOlfCryptDecrypt.XORCrypt and TOlfCryptDecrypt.XORDecrypt functions in the Olf.RTL.CryptDecrypt unit from https://github.com/DeveloppeurPascal/librairies/

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://xorkeysgenerator.olfsoftware.fr/

  Project site :
  https://github.com/DeveloppeurPascal/XOR-Keys-Generator

  ***************************************************************************
  File last update : 2025-05-26T19:40:40.000+02:00
  Signature : 3408209aeb8c80d47fd76d7d771cb90bf96fc10c
  ***************************************************************************
*)

unit fMainForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  _MainFormAncestor,
  System.Actions,
  FMX.ActnList,
  FMX.Menus,
  uDocumentsAncestor,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Controls.Presentation,
  FMX.Layouts,
  System.Generics.Collections;

type
  TMainForm = class(T__MainFormAncestor)
    VertScrollBox1: TVertScrollBox;
    pnlGeneratedKey: TPanel;
    btnGenerateANewKey: TButton;
    mmoKey: TMemo;
    btnRefreshCode: TButton;
    pnlPascal: TPanel;
    lblPascal: TLabel;
    btnPascalSample: TButton;
    mmoPascal: TMemo;
    procedure btnPascalSampleClick(Sender: TObject);
    procedure btnGenerateANewKeyClick(Sender: TObject);
    procedure btnRefreshCodeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FFreezeParamsSetValue: boolean;
    FKeySize: integer;
    mnuLanguage: TMenuItem;
  protected
    procedure FillPascalCode(const Key: TList<byte>);
    procedure mmoSelectAllOnEnter(Sender: TObject);
    procedure mnuLanguageCodeClick(Sender: TObject);
  public
    procedure TranslateTexts(const Language: string); override;
    procedure AfterConstruction; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  u_urlOpen,
  Olf.RTL.CryptDecrypt,
  uConfigHelpers,
  uConfig;

procedure TMainForm.AfterConstruction;
var
  i: integer;
begin
  inherited;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TMemo then
      (Components[i] as TMemo).OnEnter := mmoSelectAllOnEnter;
end;

procedure TMainForm.btnGenerateANewKeyClick(Sender: TObject);
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

procedure TMainForm.btnPascalSampleClick(Sender: TObject);
begin
  url_Open_In_Browser
    ('https://github.com/DeveloppeurPascal/librairies/tree/master/samples/RTL.CryptDecrypt/SimpleCryptDecryptSample');
end;

procedure TMainForm.btnRefreshCodeClick(Sender: TObject);
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

procedure TMainForm.FillPascalCode(const Key: TList<byte>);
var
  i: integer;
  s: string;
begin
  mmoPascal.Lines.Clear;
  if TConfig.Current.IsChecked['Pascal'] then
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

procedure TMainForm.FormCreate(Sender: TObject);
  procedure AddLanguageMenuItem(const Language: string);
  var
    mnu: TMenuItem;
  begin
    mnu := TMenuItem.Create(self);
    mnu.Text := Language;
    mnu.OnClick := mnuLanguageCodeClick;
    mnu.TagString := Language;
    mnuLanguage.AddObject(mnu);
    repeat
      mnuLanguageCodeClick(mnu);
    until (mnu.IsChecked = TConfig.Current.IsChecked[Language]);
  end;

begin
  FKeySize := 0;

  mnuLanguage := TMenuItem.Create(self);
  MainFormAncestorMenu.InsertObject(mnuTools.Index, mnuLanguage);

  FFreezeParamsSetValue := true;
  try
    AddLanguageMenuItem('Pascal');
  finally
    FFreezeParamsSetValue := false;
  end;
end;

procedure TMainForm.mmoSelectAllOnEnter(Sender: TObject);
begin
  if Sender is TMemo then
    (Sender as TMemo).SelectAll;
end;

procedure TMainForm.mnuLanguageCodeClick(Sender: TObject);
var
  mnu: TMenuItem;
  pnlName: string;
  FmxO: TFMXObject;
begin
  if Sender is TMenuItem then
  begin
    mnu := Sender as TMenuItem;

    mnu.IsChecked := not mnu.IsChecked;

    if not FFreezeParamsSetValue then
      TConfig.Current.IsChecked[mnu.TagString] := mnu.IsChecked;

    pnlName := 'pnl' + mnu.TagString.ToLower;

    for FmxO in VertScrollBox1.Content.Children do
      if (FmxO is TPanel) and (string((FmxO as TPanel).name).ToLower = pnlName)
      then
      begin
        (FmxO as TPanel).Visible := mnu.IsChecked;
        break;
      end;
  end;
end;

procedure TMainForm.TranslateTexts(const Language: string);
begin
  inherited;
  if (Language = 'fr') then
  begin
    btnGenerateANewKey.Text := 'Obtenir une nouvelle clé';
    btnRefreshCode.Text := 'Rafraichir les exemples';
    btnPascalSample.Text := 'Exemple';
    mnuLanguage.Text := 'Langages';
  end
  else
  begin
    btnGenerateANewKey.Text := 'Get a new key';
    btnRefreshCode.Text := 'Refresh the samples';
    btnPascalSample.Text := 'Sample';
    mnuLanguage.Text := 'Languages';
  end;
end;

end.
