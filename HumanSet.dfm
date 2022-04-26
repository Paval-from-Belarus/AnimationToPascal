object Frames: TFrames
  Left = 0
  Top = 0
  Caption = 'Frames'
  ClientHeight = 379
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -9
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 11
  object imgMap: TImage
    Left = 467
    Top = 154
    Width = 84
    Height = 84
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object pbDrawGrid: TPaintBox
    Left = -5
    Top = 0
    Width = 628
    Height = 385
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    OnPaint = pbDrawGridPaint
  end
  object btnGo: TButton
    Left = 480
    Top = 269
    Width = 71
    Height = 26
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'btnGo'
    TabOrder = 0
  end
  object tmrRender: TTimer
    Enabled = False
    Interval = 30
    OnTimer = tmrRenderTimer
    Left = 696
    Top = 440
  end
end
