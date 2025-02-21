unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Keccak, Vcl.StdCtrls, SecureBase,
  Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    btnEncode: TButton;
    PageControl1: TPageControl;
    tabEncode: TTabSheet;
    tabDecode: TTabSheet;
    lblLanguage: TLabel;
    enc_lblData: TLabel;
    lblEncoding: TLabel;
    cmbLanguage: TComboBox;
    cmbEncoding: TComboBox;
    GroupBox1: TGroupBox;
    lblSecretkey: TLabel;
    editSecretkey: TEdit;
    enc_memoData: TMemo;
    enc_lblResult: TLabel;
    enc_memoResult: TMemo;
    dec_lblData: TLabel;
    dec_memoData: TMemo;
    dec_memoResult: TMemo;
    dec_lblResult: TLabel;
    btnDecode: TButton;
    procedure btnEncodeClick(Sender: TObject);
    procedure cmbLanguageChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function ComputeHash(const S: string; Key: Integer): string;
var
  Keccak: TKeccak;
  Input, Hash: TBytes;
  I: Integer;
  HexStr: string;
begin
  Keccak := TKeccak.Create;
  try
    Input := TEncoding.UTF8.GetBytes(S);
    Hash := Keccak.Hash(Input, Key);
    HexStr := '';
    for I := 0 to Length(Hash) - 1 do
    begin
      HexStr := HexStr + IntToHex(Hash[I], 2);
    end;
    Result := LowerCase(HexStr);
  finally
    Keccak.Free;
  end;
end;

procedure TForm1.btnEncodeClick(Sender: TObject);
var
  sb: TSecureBase;
  encoding: TSBEncoding;
  secretkey, data, res: string;
begin
  try
    if cmbEncoding.ItemIndex = 0 then
      encoding := TSBEncoding.Unicode
    else
      encoding := TSBEncoding.UTF8;
    secretkey := Trim(editSecretkey.Text);
    sb := TSecureBase.Create(encoding);
    sb.SetSecretKey(secretkey);
    if sender = btnEncode then begin
      data := enc_memoData.Text;
      res := sb.Encode(data);
      enc_memoResult.Text := res;
    end else if sender = btnDecode then begin
      data := dec_memoData.Text;
      res := sb.Decode(data);
      dec_memoResult.Text := res;
    end;
  except on ex: Exception do
    Application.MessageBox(PChar('invalid decoding!'), PChar('!!'), MB_ICONINFORMATION + MB_OK);
  end;

end;

procedure TForm1.cmbLanguageChange(Sender: TObject);
begin
  if cmbLanguage.ItemIndex = 0 then begin
    tabEncode.Caption := 'Encoding';
    tabDecode.Caption := 'Decoding';
    lblSecretkey.Caption := 'Secret key:';
    enc_lblData.Caption := 'Data;';
    enc_lblResult.Caption := 'Result;';
    dec_lblData.Caption := 'Data;';
    dec_lblResult.Caption := 'Result;';
    btnEncode.Caption := 'Encode';
    btnDecode.Caption := 'Decode';
    lblLanguage.Caption := 'Language:';
    lblEncoding.Caption := 'Encoding:';
  end else begin
    tabEncode.Caption := 'Kodlama';
    tabDecode.Caption := 'Kod çözme';
    lblSecretkey.Caption := 'Gizli anahtar:';
    enc_lblData.Caption := 'Veri;';
    enc_lblResult.Caption := 'Sonuç;';
    dec_lblData.Caption := 'Veri;';
    dec_lblResult.Caption := 'Sonuç;';
    btnEncode.Caption := 'Kodla';
    btnDecode.Caption := 'Kod çöz';
    lblLanguage.Caption := 'Dil:';
    lblEncoding.Caption := 'Kodlama:';
  end;
end;

end.
