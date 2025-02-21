object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SecureBaseApp - #delphi'
  ClientHeight = 537
  ClientWidth = 735
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 17
  object PageControl1: TPageControl
    AlignWithMargins = True
    Left = 3
    Top = 103
    Width = 729
    Height = 431
    ActivePage = tabEncode
    Align = alClient
    MultiLine = True
    TabHeight = 30
    TabOrder = 0
    TabPosition = tpLeft
    object tabEncode: TTabSheet
      Caption = 'Encoding'
      object enc_lblData: TLabel
        Left = 24
        Top = 16
        Width = 89
        Height = 25
        AutoSize = False
        Caption = 'Data;'
        Layout = tlCenter
      end
      object enc_lblResult: TLabel
        Left = 24
        Top = 184
        Width = 89
        Height = 25
        AutoSize = False
        Caption = 'Result;'
        Layout = tlCenter
      end
      object btnEncode: TButton
        Left = 215
        Top = 366
        Width = 260
        Height = 41
        Cursor = crHandPoint
        Caption = 'Encode'
        TabOrder = 0
        OnClick = btnEncodeClick
      end
      object enc_memoData: TMemo
        Left = 24
        Top = 47
        Width = 641
        Height = 131
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object enc_memoResult: TMemo
        Left = 24
        Top = 215
        Width = 641
        Height = 131
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
    object tabDecode: TTabSheet
      Caption = 'Decoding'
      ImageIndex = 1
      object dec_lblData: TLabel
        Left = 24
        Top = 16
        Width = 89
        Height = 25
        AutoSize = False
        Caption = 'Data;'
        Layout = tlCenter
      end
      object dec_lblResult: TLabel
        Left = 24
        Top = 184
        Width = 89
        Height = 25
        AutoSize = False
        Caption = 'Result;'
        Layout = tlCenter
      end
      object dec_memoData: TMemo
        Left = 24
        Top = 47
        Width = 641
        Height = 131
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object dec_memoResult: TMemo
        Left = 24
        Top = 215
        Width = 641
        Height = 131
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object btnDecode: TButton
        Left = 215
        Top = 366
        Width = 260
        Height = 41
        Cursor = crHandPoint
        Caption = 'Decode'
        TabOrder = 2
        OnClick = btnEncodeClick
      end
    end
  end
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 729
    Height = 94
    Align = alTop
    TabOrder = 1
    object lblEncoding: TLabel
      Left = 489
      Top = 49
      Width = 89
      Height = 25
      AutoSize = False
      Caption = 'Encoding:'
      Layout = tlCenter
    end
    object lblLanguage: TLabel
      Left = 489
      Top = 17
      Width = 89
      Height = 25
      AutoSize = False
      Caption = 'Language:'
      Layout = tlCenter
    end
    object lblSecretkey: TLabel
      Left = 34
      Top = 35
      Width = 89
      Height = 25
      AutoSize = False
      Caption = 'Secret key:'
      Layout = tlCenter
    end
    object cmbLanguage: TComboBox
      Left = 584
      Top = 18
      Width = 113
      Height = 25
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'English'
      OnChange = cmbLanguageChange
      Items.Strings = (
        'English'
        'T'#252'rk'#231'e')
    end
    object cmbEncoding: TComboBox
      Left = 584
      Top = 49
      Width = 113
      Height = 25
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 1
      Text = 'utf-8'
      Items.Strings = (
        'unicode'
        'utf-8')
    end
    object editSecretkey: TEdit
      Left = 129
      Top = 36
      Width = 344
      Height = 25
      TabOrder = 2
    end
  end
end
