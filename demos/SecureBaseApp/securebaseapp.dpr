program securebaseapp;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  Keccak in 'Keccak.pas',
  SecureBase in 'SecureBase.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SecureBaseApp';
  TStyleManager.TrySetStyle('Cobalt XEMedia');
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
