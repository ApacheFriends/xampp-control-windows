object fNetstat: TfNetstat
  Left = 394
  Top = 196
  BorderStyle = bsSizeToolWin
  Caption = 'Netstat - TCP Listening sockets'
  ClientHeight = 758
  ClientWidth = 826
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    826
    758)
  PixelsPerInch = 120
  TextHeight = 16
  object lvSockets: TListView
    Left = 5
    Top = 37
    Width = 816
    Height = 691
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Address'
        Width = 131
      end
      item
        Alignment = taRightJustify
        Caption = 'Port'
        Width = 65
      end
      item
        Alignment = taRightJustify
        Caption = 'PID'
        Width = 65
      end
      item
        Caption = 'Name'
        Width = 200
      end>
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Arial'
    Font.Style = []
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnColumnClick = lvSocketsColumnClick
    OnCustomDrawItem = lvSocketsCustomDrawItem
    OnData = lvSocketsData
  end
  object bRefresh: TBitBtn
    Left = 718
    Top = 5
    Width = 98
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    ModalResult = 4
    NumGlyphs = 2
    TabOrder = 1
    OnClick = bRefreshClick
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 739
    Width = 826
    Height = 19
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <>
  end
  object pnlActiveExample: TPanel
    Left = 5
    Top = 5
    Width = 105
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Active socket'
    Color = clWindow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 3
  end
  object pnlOldExample: TPanel
    Left = 230
    Top = 5
    Width = 105
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Old socket'
    Color = clMaroon
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 4
  end
  object pnlNewExample: TPanel
    Left = 118
    Top = 5
    Width = 104
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'New socket'
    Color = clLime
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 5
  end
  object TimerUpdate: TTimer
    Interval = 500
    OnTimer = TimerUpdateTimer
    Left = 44
    Top = 84
  end
end
