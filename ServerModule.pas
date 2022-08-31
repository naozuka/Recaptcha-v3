unit ServerModule;

interface

uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication, uIdCustomHTTPServer,
  uniGUITypes;

type
  TUniServerModule = class(TUniGUIServerModule)
    procedure UniGUIServerModuleBeforeInit(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure FirstInit; override;
  public
    { Public declarations }
  end;

function UniServerModule: TUniServerModule;

implementation

{$R *.dfm}

uses
  UniGUIVars, recaptcha3;

const
  // Register your domain name and get your reCAPTCHA v3 keys
  // https://www.google.com/recaptcha/admin
  RECAPTCHA_SITE_KEY = '';
  RECAPTCHA_SECRET_KEY = '';

function UniServerModule: TUniServerModule;
begin
  Result:=TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;

procedure TUniServerModule.UniGUIServerModuleBeforeInit(Sender: TObject);
begin
  Recaptcha3InitJSLibrary(Self, RECAPTCHA_SITE_KEY, RECAPTCHA_SECRET_KEY);
end;

initialization
  RegisterServerModuleClass(TUniServerModule);
end.
