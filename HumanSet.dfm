object Frames: TFrames
  Left = 0
  Top = 0
  Caption = 'Frames'
  ClientHeight = 482
  ClientWidth = 787
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object imgMap: TImage
    Left = 584
    Top = 192
    Width = 105
    Height = 105
  end
  object pbDrawGrid: TPaintBox
    Left = -6
    Top = 0
    Width = 785
    Height = 481
    OnPaint = pbDrawGridPaint
  end
  object btnGo: TButton
    Left = 600
    Top = 336
    Width = 89
    Height = 33
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
