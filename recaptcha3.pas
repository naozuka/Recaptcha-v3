unit recaptcha3;

interface

uses
  SysUtils, System.Classes, DateUtils, uniGUIServer, uniGUIApplication, uniEdit, IdHTTP, IdSSLOpenSSL, IdMultipartFormData, DBXJSON, XSBuiltIns;

type
  TSiteVerifyResponse = record
    Success: Boolean;
    ChallengeTs: TDateTime;
    Hostname: string;
    Score: Double;
    Action: string;
    ErrorCodes: string;
    Response: string;
  private type
    THTTPStatus = record
      Code: Integer;
      Text: string;
    end;
  public
    HTTPStatus: THTTPStatus;
  end;

procedure Recaptcha3InitJSLibrary(AServerModule: TUniGUIServerModule; const ASiteKey, ASecretKey: string; AHideBarge: Boolean = False);
procedure Recaptcha3Execute(const AAction: string; AResponseHolder: TUniCustomEdit);
function  Recaptcha3SiteVerify(const AResponse, AExpectedAction: string; AScoreThreshold: Double): TSiteVerifyResponse;
procedure Recaptcha3Stop;

implementation

var
  GSiteKey: string;
  GSecretKey: string;

procedure Recaptcha3InitJSLibrary(AServerModule: TUniGUIServerModule;
  const ASiteKey, ASecretKey: string; AHideBarge: Boolean = False);
begin
  if (ASiteKey = '') or (ASecretKey = '') then
    raise Exception.Create('reCAPTCHA keys not set!');

  GSiteKey := ASiteKey;
  GSecretKey := ASecretKey;
  AServerModule.CustomFiles.Append(
    '<script src="https://www.google.com/recaptcha/api.js?render='+GSiteKey+'" async defer></script>');
  if AHideBarge then
    AServerModule.CustomCSS.Append('.grecaptcha-badge { visibility: hidden; }');
end;

procedure Recaptcha3Execute(const AAction: string; AResponseHolder: TUniCustomEdit);
begin
  //AResponseHolder.Visible := False;
  Recaptcha3Stop;
  UniSession.AddJS(
    'function grecaptcha3_execute() {'+
    '  grecaptcha.execute('''+GSiteKey+''', {'+
    '    action: '''+AAction+''''+
    '  }).then(function (token) {'+
    //'      var _textEl = Ext.getCmp('''+AResponseHolder.JSId+''');'+
    //'      _textEl.setValue(token);'+
    '      ajaxRequest(MainForm.htmlAcoes, "setToken",["token="+token]);'+
    //'      console.log("token", token);'+
    '  }, function (reason) {'+
    '    console.log(reason);'+
    '  });'+
    '}'+
    'if (typeof grecaptcha !== ''undefined'') {'+
    '  grecaptcha.ready(grecaptcha3_execute);'+
    '  window.grecaptcha3_interval_id = setInterval(grecaptcha3_execute, 60000);'+
    '}'
  );
end;

function Recaptcha3SiteVerify(
  const AResponse, AExpectedAction: string; AScoreThreshold: Double): TSiteVerifyResponse;
var
  JSONObject: TJSONObject;
  LChallengeTs: string;
  LSuccess: Boolean;
  ErrorsArr: TJSONArray;
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  Data: TStringList;
  Response: string;
  tmpSuccess: string;
  tmpScore: string;
  tmp : string;
begin
  with Result do
  begin
    Success := False;
    ChallengeTs := 0;
    Score := 0;
  end;

  HTTP := TIdHTTP.Create;
  HTTP.Request.ContentType := 'application/x-www-form-urlencoded';

  try
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
    SSL.SSLOptions.SSLVersions := [sslvTLSv1];
    HTTP.IOHandler := SSL;

    Data := TStringList.Create;
    try

      Data.Add('secret='+GSecretKey);
      Data.Add('response='+AResponse);
      Data.Add('remoteip='+UniSession.RemoteIP);

      Response := HTTP.Post('https://www.google.com/recaptcha/api/siteverify', Data);
      Result.Response := Response;

      JSONObject := TJSONObject.ParseJSONValue(Response) as TJSONObject;
      LSuccess := (JSONObject.Get('success').JsonValue.ToString = 'true');
      if LSuccess then
      begin
        LChallengeTs := JSONObject.Get('challenge_ts').JsonValue.ToString; //JSONObject.GetValue<string>('challenge_ts');
        //Result.ChallengeTs := DateUtils.ISO8601ToDate(LChallengeTs);
        Result.Hostname := JSONObject.Get('hostname').JsonValue.Value; //JSONObject.GetValue<string>('hostname');
        tmpScore := JSONObject.Get('score').JsonValue.ToString;
        Result.Score := StrToFloatDef(StringReplace(JSONObject.Get('score').JsonValue.ToString,'.',',',[]), 0);
        Result.Action := JSONObject.Get('action').JsonValue.Value; //JSONObject.GetValue<string>('action');
        Result.Success := LSuccess and SameText(AExpectedAction, Result.Action) and (Result.Score >= AScoreThreshold);
      end
      else
      begin
        if JSONObject.Get('error-codes') <> nil then
        begin
          ErrorsArr := JSONObject.Get('error-codes').JsonValue as TJSONArray; // Processo->Get("ITENS")->JsonValue
          Result.ErrorCodes := ErrorsArr.ToString;
        end;
      end;
    finally
      Data.Free;
      SSL.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure Recaptcha3Stop;
begin
  UniSession.AddJS(
    'if (window.grecaptcha3_interval_id > 0) {'+
    '  clearInterval(window.grecaptcha3_interval_id);'+
    '  window.grecaptcha3_interval_id = 0;'+
    '}'
  );
end;

end.
