object MainForm: TMainForm
  Left = 0
  Top = 0
  ClientHeight = 441
  ClientWidth = 696
  Caption = 'MainForm'
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  OnAfterShow = UniFormAfterShow
  PixelsPerInch = 96
  TextHeight = 13
  object ResponseHolder: TUniEdit
    Left = 22
    Top = 27
    Width = 651
    TabOrder = 0
    ReadOnly = True
    LayoutConfig.Width = '200'
  end
  object UniButton1: TUniButton
    Left = 22
    Top = 81
    Width = 122
    Height = 25
    Caption = 'Site Verify'
    TabOrder = 1
    OnClick = UniButton1Click
  end
  object SiteVerifyResponseMemo: TUniMemo
    Left = 22
    Top = 131
    Width = 651
    Height = 286
    TabOrder = 2
  end
  object htmlAcoes: TUniHTMLFrame
    Left = 280
    Top = 73
    Width = 105
    Height = 33
    OnAjaxEvent = htmlAcoesAjaxEvent
  end
end
