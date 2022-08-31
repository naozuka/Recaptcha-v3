unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniMemo, uniButton,
  uniGUIBaseClasses, uniEdit, uniPanel, uniHTMLFrame;

type
  TMainForm = class(TUniForm)
    ResponseHolder: TUniEdit;
    UniButton1: TUniButton;
    SiteVerifyResponseMemo: TUniMemo;
    htmlAcoes: TUniHTMLFrame;
    procedure UniButton1Click(Sender: TObject);
    procedure UniFormAfterShow(Sender: TObject);
    procedure htmlAcoesAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, recaptcha3;

const
  EXPECTED_ACTION = 'register';

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.htmlAcoesAjaxEvent(Sender: TComponent;
  EventName: string; Params: TUniStrings);
begin
  if EventName = 'setToken' then
  begin
    ResponseHolder.Text := Params.Values['token'];
  end;
end;

procedure TMainForm.UniButton1Click(Sender: TObject);
var
  SiteVerifyResponse: TSiteVerifyResponse;
begin
  UniSession.Synchronize();
  SiteVerifyResponseMemo.Lines.Clear;
  SiteVerifyResponseMemo.Lines.Add('Token: ' + ResponseHolder.Text);

  if ResponseHolder.Text <> '' then
  begin
    SiteVerifyResponse := Recaptcha3SiteVerify(ResponseHolder.Text, EXPECTED_ACTION, 0.5);
    with SiteVerifyResponseMemo.Lines do
    begin
      Append('Response: ' + SiteVerifyResponse.Response);
      Append('Success: ' + BoolToStr(SiteVerifyResponse.Success, True));
      Append('ChallengeTs: ' + DateTimeToStr(SiteVerifyResponse.ChallengeTs));
      Append('Hostname: ' + SiteVerifyResponse.Hostname);
      Append('Score: ' + FloatToStr(SiteVerifyResponse.Score));
      Append('Action: ' + SiteVerifyResponse.Action);
      Append('Error-Codes: ' + SiteVerifyResponse.ErrorCodes);
      Append('HTTPStatus: ' + IntToStr(SiteVerifyResponse.HTTPStatus.Code) + ' - ' + SiteVerifyResponse.HTTPStatus.Text);
    end;
    Recaptcha3Execute(EXPECTED_ACTION, ResponseHolder);
  end;

end;

procedure TMainForm.UniFormAfterShow(Sender: TObject);
begin
  Recaptcha3Execute(EXPECTED_ACTION, ResponseHolder);
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
