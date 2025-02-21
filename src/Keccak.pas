unit Keccak;

interface

uses
  System.SysUtils, System.Classes;

type
  TKeccak = class
  private
    FState: array[0..24] of UInt64;
    FDisposed: Boolean;

    const KeccakRounds = 24;
    const RoundConstants: array[0..23] of UInt64 = (
      $0000000000000001, $0000000000008082, $800000000000808A, $8000000080008000,
      $000000000000808B, $0000000080000001, $8000000080008081, $8000000000008009,
      $000000000000008A, $0000000000000088, $0000000080008009, $000000008000000A,
      $000000008000808B, $800000000000008B, $8000000000008089, $8000000000008003,
      $8000000000008002, $8000000000000080, $000000000000800A, $800000008000000A,
      $8000000080008081, $8000000000008080, $0000000080000001, $8000000080008008
    );

    const RhoOffsets: array[0..24] of Integer = (
      0, 1, 62, 28, 27,
      36, 44, 6, 55, 20,
      3, 10, 43, 25, 39,
      41, 45, 15, 21, 8,
      18, 2, 61, 56, 14
    );

    function ROL(X: UInt64; N: Integer): UInt64;
    function ToUInt64(Bytes: TBytes; Offset: Integer): UInt64;
    function Pad(Input: TBytes; RateInBytes: Integer): TBytes;
    procedure KeccakF;
    procedure Absorb(Message: TBytes; RateInBytes: Integer);
    function Squeeze(OutputLength: Integer): TBytes;

  public
    constructor Create;
    destructor Destroy; override;

    function Hash(Input: TBytes; OutputLengthBits: Integer): TBytes;
    procedure Dispose;
  end;

implementation

constructor TKeccak.Create;
begin
  inherited;
  FDisposed := False;
  FillChar(FState, SizeOf(FState), 0);
end;

destructor TKeccak.Destroy;
begin
  Dispose;
  inherited;
end;

function TKeccak.Hash(Input: TBytes; OutputLengthBits: Integer): TBytes;
var
  RateInBytes: Integer;
  PaddedMessage: TBytes;
begin
  if FDisposed then
    raise Exception.Create('Object is disposed');

  RateInBytes := (1600 - 2 * OutputLengthBits) div 8;
  PaddedMessage := Pad(Input, RateInBytes);
  Absorb(PaddedMessage, RateInBytes);
  Result := Squeeze(OutputLengthBits div 8);
end;

procedure TKeccak.Absorb(Message: TBytes; RateInBytes: Integer);
var
  Offset, I, BlockSize: Integer;
  TempBytes: TBytes;
begin
  BlockSize := RateInBytes;
  Offset := 0;

  while Offset < Length(Message) do
  begin
    for I := 0 to (BlockSize div 8) - 1 do
    begin
      if Offset + (I + 1) * 8 <= Length(Message) then
      begin
        SetLength(TempBytes, 8);
        Move(Message[Offset + I * 8], TempBytes[0], 8);
        FState[I] := FState[I] xor ToUInt64(TempBytes, 0);
      end;
    end;
    KeccakF;
    Inc(Offset, BlockSize);
  end;
end;

function TKeccak.Squeeze(OutputLength: Integer): TBytes;
var
  Output: TBytes;
  Offset, BytesToOutput, I: Integer;
begin
  SetLength(Output, OutputLength);
  Offset := 0;

  while OutputLength > 0 do
  begin
    if OutputLength < 200 then
      BytesToOutput := OutputLength
    else
      BytesToOutput := 200;

    for I := 0 to BytesToOutput - 1 do
      Output[Offset + I] := Byte(FState[I div 8] shr (8 * (I mod 8)));

    Inc(Offset, BytesToOutput);
    Dec(OutputLength, BytesToOutput);

    if OutputLength > 0 then
      KeccakF;
  end;

  Result := Output;
end;

procedure TKeccak.KeccakF;
var
  Round: Integer;
  C, D, B: array[0..24] of UInt64;
  I, J: Integer;
begin
  for Round := 0 to KeccakRounds - 1 do
  begin
    // Theta step
    for I := 0 to 4 do
    begin
      C[I] := FState[I] xor FState[I + 5] xor FState[I + 10] xor FState[I + 15] xor FState[I + 20];
    end;

    for I := 0 to 4 do
    begin
      D[I] := C[(I + 4) mod 5] xor ROL(C[(I + 1) mod 5], 1);
    end;

    for I := 0 to 24 do
    begin
      if I mod 5 < 5 then
        FState[I] := FState[I] xor D[I mod 5];
    end;

    // Rho and Pi steps
    for I := 0 to 24 do
    begin
      B[I] := ROL(FState[I], RhoOffsets[I]);
    end;

    // Chi step
    for I := 0 to 20 do
    begin
      if I mod 5 = 0 then
      begin
        for J := 0 to 4 do
        begin
          FState[I + J] := B[I + J] xor ((not B[I + ((J + 1) mod 5)]) and B[I + ((J + 2) mod 5)]);
        end;
      end;
    end;

    // Iota step
    FState[0] := FState[0] xor RoundConstants[Round];
  end;
end;

function TKeccak.ROL(X: UInt64; N: Integer): UInt64;
begin
  Result := (X shl N) or (X shr (64 - N));
end;

function TKeccak.Pad(Input: TBytes; RateInBytes: Integer): TBytes;
var
  PaddingLength: Integer;
  Padded: TBytes;
begin
  PaddingLength := RateInBytes - (Length(Input) mod RateInBytes);
  SetLength(Padded, Length(Input) + PaddingLength);

  if Length(Input) > 0 then
    Move(Input[0], Padded[0], Length(Input));

  Padded[Length(Input)] := $06;
  Padded[High(Padded)] := Padded[High(Padded)] or $80;

  Result := Padded;
end;

function TKeccak.ToUInt64(Bytes: TBytes; Offset: Integer): UInt64;
var
  I: Integer;
  Result64: UInt64;
begin
  Result64 := 0;

  // Little Endian conversion
  for I := 0 to 7 do
  begin
    if Offset + I < Length(Bytes) then
      Result64 := Result64 or (UInt64(Bytes[Offset + I]) shl (8 * I));
  end;

  Result := Result64;
end;

procedure TKeccak.Dispose;
begin
  if not FDisposed then
  begin
    FillChar(FState, SizeOf(FState), 0);
    FDisposed := True;
  end;
end;

end.
