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
  object pbDrawGrid: TPaintBox
    Left = -6
    Top = 0
    Width = 800
    Height = 600
    OnPaint = pbDrawGridPaint
  end
  object tmrRender: TTimer
    Enabled = False
    Interval = 30
    OnTimer = tmrRenderTimer
    Left = 696
    Top = 440
  end
end
