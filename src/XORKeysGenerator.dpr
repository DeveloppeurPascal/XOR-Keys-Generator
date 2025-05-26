﻿(* C2PP
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
  File last update : 2025-05-26T20:03:22.000+02:00
  Signature : 0966cff6e0f7490e3ffb5b9dc1e860b5ad1ca306
  ***************************************************************************
*)

program XORKeysGenerator;

uses
  System.StartUpCopy,
  FMX.Forms,
  uConfig in '..\lib-externes\FMX-Tools-Starter-Kit\src\uConfig.pas',
  uDMAboutBox in '..\lib-externes\FMX-Tools-Starter-Kit\src\uDMAboutBox.pas' {AboutBox: TDataModule},
  uTranslate in '..\lib-externes\FMX-Tools-Starter-Kit\src\uTranslate.pas',
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm},
  Olf.FMX.SelectDirectory in '..\lib-externes\Delphi-FMXExtend-Library\src\Olf.FMX.SelectDirectory.pas',
  Olf.RTL.CryptDecrypt in '..\lib-externes\librairies\src\Olf.RTL.CryptDecrypt.pas',
  Olf.RTL.Language in '..\lib-externes\librairies\src\Olf.RTL.Language.pas',
  Olf.RTL.Params in '..\lib-externes\librairies\src\Olf.RTL.Params.pas',
  u_urlOpen in '..\lib-externes\librairies\src\u_urlOpen.pas',
  _TFrameAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\_TFrameAncestor.pas' {__TFrameAncestor: TFrame},
  _TFormAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\_TFormAncestor.pas' {__TFormAncestor},
  _MainFormAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\_MainFormAncestor.pas' {__MainFormAncestor},
  uDocumentsAncestor in '..\lib-externes\FMX-Tools-Starter-Kit\src\uDocumentsAncestor.pas',
  Olf.RTL.Streams in '..\lib-externes\librairies\src\Olf.RTL.Streams.pas',
  Olf.RTL.Maths.Conversions in '..\lib-externes\librairies\src\Olf.RTL.Maths.Conversions.pas',
  uStyleManagerHelpers in '..\lib-externes\FMX-Tools-Starter-Kit\src\uStyleManagerHelpers.pas',
  Olf.RTL.SystemAppearance in '..\lib-externes\librairies\src\Olf.RTL.SystemAppearance.pas',
  fToolsStylesDialog in '..\lib-externes\FMX-Tools-Starter-Kit\src\fToolsStylesDialog.pas' {frmToolsStylesDialog},
  fToolsLanguagesDialog in '..\lib-externes\FMX-Tools-Starter-Kit\src\fToolsLanguagesDialog.pas' {frmToolsLanguagesDialog},
  Olf.CilTseg.ClientLib in '..\lib-externes\CilTseg4Delphi\src\Olf.CilTseg.ClientLib.pas',
  Olf.RTL.Checksum in '..\lib-externes\librairies\src\Olf.RTL.Checksum.pas',
  u_md5 in '..\lib-externes\librairies\src\u_md5.pas',
  fCiltsegRegisterOrShowLicense in '..\lib-externes\CilTseg4Delphi\src\FMX\fCiltsegRegisterOrShowLicense.pas' {frmCilTsegRegisterOrShowLicense},
  _StyleContainerAncestor in '..\lib-externes\FMX-Styles-Utils\src\_StyleContainerAncestor.pas' {__StyleContainerAncestor: TDataModule},
  uStyleManager in '..\lib-externes\FMX-Styles-Utils\src\uStyleManager.pas',
  uStyleDarkByDefault in '..\lib-externes\FMX-Styles-Utils\samples\DarkLightSampleProject\uStyleDarkByDefault.pas' {StyleDarkByDefault: TDataModule},
  uStyleLightByDefault in '..\lib-externes\FMX-Styles-Utils\samples\DarkLightSampleProject\uStyleLightByDefault.pas' {StyleLightByDefault: TDataModule},
  uGetDeviceName in '..\lib-externes\librairies\src\uGetDeviceName.pas',
  fMainForm in 'fMainForm.pas' {MainForm},
  uConsts in 'uConsts.pas',
  uDMAboutBoxLogoStorrage in 'uDMAboutBoxLogoStorrage.pas' {dmAboutBoxLogo: TDataModule},
  uTxtAboutDescription in 'uTxtAboutDescription.pas',
  uTxtAboutLicense in 'uTxtAboutLicense.pas',
  uConfigHelpers in 'uConfigHelpers.pas',
  uStyleCoralCrystal in '..\lib-externes\FMX-Tools-Starter-Kit\samples\01-NoDocProject\uStyleCoralCrystal.pas' {dmStyleCoralCrystal: TDataModule},
  uStyleGoldenGraphite in '..\lib-externes\FMX-Tools-Starter-Kit\samples\01-NoDocProject\uStyleGoldenGraphite.pas' {dmStyleGoldenGraphite: TDataModule},
  uStyleTransparent in '..\lib-externes\FMX-Tools-Starter-Kit\samples\01-NoDocProject\uStyleTransparent.pas' {dmStyleTransparent: TDataModule},
  uStyleWin10ModernBlue in '..\lib-externes\FMX-Tools-Starter-Kit\samples\01-NoDocProject\uStyleWin10ModernBlue.pas' {dmStyleWin10ModernBlue: TDataModule},
  uStyleImpressiveDark in '..\_PRIVATE\src\uStyleImpressiveDark.pas' {StyleImpressiveDark: TDataModule},
  uStyleImpressiveLight in '..\_PRIVATE\src\uStyleImpressiveLight.pas' {StyleImpressiveLight: TDataModule},
  uStylePolarDark in '..\_PRIVATE\src\uStylePolarDark.pas' {StylePolarDark: TDataModule},
  uStylePolarLight in '..\_PRIVATE\src\uStylePolarLight.pas' {StylePolarLight: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TdmStyleCoralCrystal, dmStyleCoralCrystal);
  Application.CreateForm(TdmStyleGoldenGraphite, dmStyleGoldenGraphite);
  Application.CreateForm(TdmStyleTransparent, dmStyleTransparent);
  Application.CreateForm(TdmStyleWin10ModernBlue, dmStyleWin10ModernBlue);
  Application.Run;
end.
