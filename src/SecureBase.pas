{
  version:  v1.1
  author:   beytullahakyuz
  github:   https://github.com/beytullahakyuz/securebase-delphi
}

unit SecureBase;

interface

uses
  System.SysUtils, System.Classes, System.NetEncoding, Keccak;

type
  TSBEncoding = (Unicode, UTF8);

  TSecureBase = class(TInterfacedObject)
  private
    const
      DefCharset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"#&''()*,-.:;<>?@[]\^_{}|~/+=';
      Base64Standart = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    var
      FGlobalCharset: string;
      FPadding: Char;
      FDisposed: Boolean;
      FEncoding: TSBEncoding;

    function ProcessEncoding(Input: TBytes): TBytes;
    function ProcessDecoding(const Input: string): TBytes;
    procedure pr_SuffleCharset(const SecretKey: string);
    function ComputeHash(const S: string; Key: Integer): string;
    function fn_SuffleCharset(const Data: string; Keys: TArray<Integer>): string;
    function fn_CharacterSetSecretKey(const Anahtar: string): TArray<Integer>;

  public
    constructor Create(Encoding: TSBEncoding); overload;
    constructor Create(Encoding: TSBEncoding; const SecretKey: string); overload;
    destructor Destroy; override;

    procedure SetSecretKey(const SecretKey: string);
    function Encode(const Input: string): string;
    function Decode(const Input: string): string;
    procedure Dispose;
  end;

implementation

{ TSecureBase }

constructor TSecureBase.Create(Encoding: TSBEncoding);
begin
  inherited Create;
  FGlobalCharset := Base64Standart;
  FPadding := '=';
  FEncoding := Encoding;
  FDisposed := False;
end;

constructor TSecureBase.Create(Encoding: TSBEncoding; const SecretKey: string);
begin
  Create(Encoding);
  SetSecretKey(SecretKey);
end;

destructor TSecureBase.Destroy;
begin
  Dispose;
  inherited;
end;

procedure TSecureBase.SetSecretKey(const SecretKey: string);
begin
  if Length(SecretKey) > 0 then
  begin
    FGlobalCharset := DefCharset;
    pr_SuffleCharset(SecretKey);
    FPadding := FGlobalCharset[65]; // Delphi'de string index 1'den baþlar
    FGlobalCharset := Copy(FGlobalCharset, 1, 64);
  end
  else
  begin
    FGlobalCharset := Base64Standart;
    FPadding := '=';
  end;
end;

function TSecureBase.Encode(const Input: string): string;
var
  Bytes: TBytes;
begin
  if FEncoding = Unicode then
  begin
    Bytes := TEncoding.Unicode.GetBytes(Input);
    Result := TEncoding.Unicode.GetString(ProcessEncoding(Bytes));
  end
  else
  begin
    Bytes := TEncoding.UTF8.GetBytes(Input);
    Result := TEncoding.UTF8.GetString(ProcessEncoding(Bytes));
  end;
end;

function TSecureBase.Decode(const Input: string): string;
begin
  if FEncoding = Unicode then
    Result := TEncoding.Unicode.GetString(ProcessDecoding(Input))
  else
    Result := TEncoding.UTF8.GetString(ProcessDecoding(Input));
end;

function TSecureBase.ProcessEncoding(Input: TBytes): TBytes;
var
  BaseArray: TArray<Char>;
  PData: TBytes;
  EncodedData: TArray<Char>;
  len, LengthDiv3, Remainder, EncodedLength: Integer;
  DataIndex, EncodedIndex, I, Chunk, LastByte, SecondLastByte: Integer;
begin
  try
    BaseArray := FGlobalCharset.ToCharArray;
    PData := Input;
    
    if System.Length(PData) > 0 then
    begin
      len := System.Length(PData);
      LengthDiv3 := len div 3;
      Remainder := len mod 3;

      if Remainder = 0 then
        EncodedLength := LengthDiv3 * 4
      else
        EncodedLength := LengthDiv3 * 4 + 4;

      SetLength(EncodedData, EncodedLength);

      DataIndex := 0;
      EncodedIndex := 0;

      for I := 0 to LengthDiv3 - 1 do
      begin
        Chunk := (PData[DataIndex] shl 16) or (PData[DataIndex + 1] shl 8) or PData[DataIndex + 2];
        Inc(DataIndex, 3);

        EncodedData[EncodedIndex] := BaseArray[(Chunk shr 18) and 63];
        EncodedData[EncodedIndex + 1] := BaseArray[(Chunk shr 12) and 63];
        EncodedData[EncodedIndex + 2] := BaseArray[(Chunk shr 6) and 63];
        EncodedData[EncodedIndex + 3] := BaseArray[Chunk and 63];
        Inc(EncodedIndex, 4);
      end;

      if Remainder = 1 then
      begin
        LastByte := PData[DataIndex];
        EncodedData[EncodedIndex] := BaseArray[LastByte shr 2];
        EncodedData[EncodedIndex + 1] := BaseArray[(LastByte and 3) shl 4];
        EncodedData[EncodedIndex + 2] := FPadding;
        EncodedData[EncodedIndex + 3] := FPadding;
      end
      else if Remainder = 2 then
      begin
        SecondLastByte := PData[DataIndex];
        Inc(DataIndex);
        LastByte := PData[DataIndex];

        EncodedData[EncodedIndex] := BaseArray[SecondLastByte shr 2];
        EncodedData[EncodedIndex + 1] := BaseArray[((SecondLastByte and 3) shl 4) or (LastByte shr 4)];
        EncodedData[EncodedIndex + 2] := BaseArray[(LastByte and 15) shl 2];
        EncodedData[EncodedIndex + 3] := FPadding;
      end;

      if FEncoding = Unicode then
        Result := TEncoding.Unicode.GetBytes(string.Create(EncodedData))
      else
        Result := TEncoding.UTF8.GetBytes(string.Create(EncodedData));
    end
    else
      SetLength(Result, 0);
  except
    raise Exception.Create('Invalid data or secret key!');
  end;
end;

function TSecureBase.ProcessDecoding(const Input: string): TBytes;
var
  BaseArray: TArray<Char>;
  DecodedData: TBytes;
  Base64Values: array[0..255] of Byte;
  Length, PaddingCount, DecodedLength: Integer;
  EncodedIndex, DecodedIndex, I, Chunk: Integer;
begin
  try
    BaseArray := FGlobalCharset.ToCharArray;
    SetLength(DecodedData, 0);

    if Input <> '' then
    begin
      FillChar(Base64Values, SizeOf(Base64Values), 0);
      for I := 0 to 63 do
        Base64Values[Ord(BaseArray[I])] := I;

      Length := System.Length(Input);
      PaddingCount := 0;

      if (Length > 0) and (Input[Length] = FPadding) then
        Inc(PaddingCount);

      if (Length > 1) and (Input[Length - 1] = FPadding) then
        Inc(PaddingCount);

      DecodedLength := (Length * 3) div 4 - PaddingCount;
      SetLength(DecodedData, DecodedLength);

      EncodedIndex := 1;
      DecodedIndex := 0;

      while EncodedIndex <= Length do
      begin
        Chunk := (Base64Values[Ord(Input[EncodedIndex])] shl 18) or
                 (Base64Values[Ord(Input[EncodedIndex + 1])] shl 12) or
                 (Base64Values[Ord(Input[EncodedIndex + 2])] shl 6) or
                 Base64Values[Ord(Input[EncodedIndex + 3])];

        Inc(EncodedIndex, 4);

        DecodedData[DecodedIndex] := Byte((Chunk shr 16) and 255);
        Inc(DecodedIndex);

        if DecodedIndex < DecodedLength then
        begin
          DecodedData[DecodedIndex] := Byte((Chunk shr 8) and 255);
          Inc(DecodedIndex);
        end;

        if DecodedIndex < DecodedLength then
        begin
          DecodedData[DecodedIndex] := Byte(Chunk and 255);
          Inc(DecodedIndex);
        end;
      end;
    end;

    Result := DecodedData;
  except
    on E: Exception do
      raise Exception.Create('Invalid data or secret key!');
  end;
end;

procedure TSecureBase.pr_SuffleCharset(const SecretKey: string);
var
  SecretHash: string;
begin
  SecretHash := ComputeHash(SecretKey, 512);
  FGlobalCharset := fn_SuffleCharset(FGlobalCharset, fn_CharacterSetSecretKey(SecretHash));
end;

function TSecureBase.ComputeHash(const S: string; Key: Integer): string;
var
  KeccakObj: TKeccak;
  Input, Hash: TBytes;
  I: Integer;
  HexStr: string;
begin
  KeccakObj := TKeccak.Create;
  try
    Input := TEncoding.UTF8.GetBytes(S);
    Hash := KeccakObj.Hash(Input, Key);

    HexStr := '';
    for I := 0 to High(Hash) do
      HexStr := HexStr + IntToHex(Hash[I], 2);

    Result := LowerCase(HexStr);
  finally
    KeccakObj.Free;
  end;
end;

function TSecureBase.fn_SuffleCharset(const Data: string; Keys: TArray<Integer>): string;
var
  Karakterler: TArray<Char>;
  KeyLen, J, I, X: Integer;
  Temp: Char;
begin
  Karakterler := Data.ToCharArray;
  KeyLen := Length(Keys);

  for J := 0 to KeyLen - 2 do
  begin
    for I := High(Karakterler) downto 1 do
    begin
      X := (I * Keys[J]) mod Length(Karakterler);
      Temp := Karakterler[I];
      Karakterler[I] := Karakterler[X];
      Karakterler[X] := Temp;
    end;
  end;

  Result := string.Create(Karakterler);
end;

function TSecureBase.fn_CharacterSetSecretKey(const Anahtar: string): TArray<Integer>;
var
  Arr: TArray<Integer>;
  I: Integer;
  C: Char;
  HS: Integer;
begin
  SetLength(Arr, Length(Anahtar));

  for I := 0 to Length(Anahtar) - 2 do
  begin
    C := Anahtar[I+1];
    HS := 0;
    HS := (HS * 31 + Ord(C)) mod High(Integer);
    Arr[I] := HS;
  end;

  Result := Arr;
end;

procedure TSecureBase.Dispose;
begin
  if not FDisposed then
    FDisposed := True;
end;

end.
