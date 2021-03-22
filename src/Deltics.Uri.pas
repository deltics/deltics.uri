
  unit Deltics.Uri;

interface

  uses
    Deltics.InterfacedObjects;


  type
    IUri = interface
    ['{D1889DA2-096A-4019-A502-D0EFDA1078AB}']
      function get_AsFilePath: String;
      function get_AsString: String;
      function get_Authority: String;
      function get_Scheme: String;
      function get_UserInfo: String;
      function get_Host: String;
      function get_Port: Integer;
      function get_Path: String;
      function get_Query: String;
      function get_Fragment: String;
      procedure set_AsString(const aValue: String);
      procedure set_Scheme(const aValue: String);
      procedure set_UserInfo(const aValue: String);
      procedure set_Host(const aValue: String);
      procedure set_Port(const aValue: Integer);
      procedure set_Path(const aValue: String);
      procedure set_Query(const aValue: String);
      procedure set_Fragment(const aValue: String);

      property Scheme: String read get_Scheme write set_Scheme;
      property UserInfo: String read get_UserInfo write set_UserInfo;
      property Host: String read get_Host write set_Host;
      property Port: Integer read get_Port write set_Port;
      property Path: String read get_Path write set_Path;
      property Query: String read get_Query write set_Query;
      property Fragment: String read get_Fragment write set_Fragment;
      property Authority: String read get_Authority;
      property AsFilePath: String read get_AsFilePath;
      property AsString: String read get_AsString write set_AsString;
    end;


    TUri = class(TComInterfacedObject, IUri)
    // IUri
    protected
      function get_AsFilePath: String;
      function get_AsString: String;
      function get_Authority: String;
      function get_Scheme: String;
      function get_UserInfo: String;
      function get_Host: String;
      function get_Port: Integer;
      function get_Path: String;
      function get_Query: String;
      function get_Fragment: String;
      procedure set_AsString(const aValue: String);
      procedure set_Scheme(const aValue: String);
      procedure set_UserInfo(const aValue: String);
      procedure set_Host(const aValue: String);
      procedure set_Port(const aValue: Integer);
      procedure set_Path(const aValue: String);
      procedure set_Query(const aValue: String);
      procedure set_Fragment(const aValue: String);

    private
      fScheme: String;
      fUserInfo: String;
      fHost: String;
      fPort: Integer;
      fPath: String;
      fQuery: String;
      fFragment: String;
    public
      constructor Create; overload;
      constructor Create(const aUri: String); overload;
      property Scheme: String read fScheme write fScheme;
      property UserInfo: String read get_UserInfo write set_UserInfo;
      property Host: String read fHost write fHost;
      property Port: Integer read fPort write fPort;
      property Path: String read fPath write fPath;
      property Query: String read fQuery write fQuery;
      property Fragment: String read fFragment write fFragment;
      property Authority: String read get_Authority;
      property AsFilePath: String read get_AsFilePath;
      property AsString: String read get_AsString write set_AsString;
    end;


implementation

  uses
    SysUtils,
    Deltics.Exceptions,
    Deltics.StringLists,
    Deltics.StringParsers,
    Deltics.Strings,
    Deltics.StringTemplates;


{ TUri }

  constructor TUri.Create(const aUri: String);
  begin
    inherited Create;

    AsString := aUri;
  end;


  constructor TUri.Create;
  begin
    inherited Create;

    fPort := -1;
  end;


  function TUri.get_AsFilePath: String;
  begin
    if fScheme <> 'file' then
      raise EInvalidOperation.CreateFmt('''%s'' is not a filepath Uri', [AsString]);

    if fPath = '' then
      raise EInvalidOperation.CreateFmt('''%s'' is not a valid filepath Uri', [AsString]);

    if NOT Str.Contains(fPath, ':') then
      result := '//' + fHost + '/' + fPath
    else
      result := fPath;

    result := Str.ReplaceAll(result, '/', '\');
  end;


  function TUri.get_AsString: String;
  var
    auth: String;
  begin
    auth    := Authority;
    result  := fScheme + '://';

    if auth <> '' then
      result := result + auth;

    if fPath <> '' then
      result := result + '/' + fPath;

    if fQuery <> '' then
      result := result + '?' + fQuery;

    if fFragment <> '' then
      result := result + '#' + fFragment;
  end;


  function TUri.get_Authority: String;
  begin
    result := '';

    if fUserInfo <> '' then
      result := result + fUserInfo + '@';

    if fHost <> '' then
      result := result + fHost;

    if fPort <> -1 then
      result := result + ':' + IntToStr(fPort);
  end;


  function TUri.get_Fragment: String;
  begin
    result := fFragment;
  end;

  function TUri.get_Host: String;
  begin
    result := fHost;
  end;

  function TUri.get_Path: String;
  begin
    result := fPath;
  end;

  function TUri.get_Port: Integer;
  begin
    result := fPort;
  end;

  function TUri.get_Query: String;
  begin
    result := fQuery;
  end;

  function TUri.get_Scheme: String;
  begin
    result := fScheme;
  end;

  function TUri.get_UserInfo: String;
  begin
    result := fUserInfo;
  end;



  procedure TUri.set_AsString(const aValue: String);
  var
    vars: TStringList;
  begin
    fScheme   := '';
    fUserInfo := '';
    fHost     := '';
    fPort     := -1;
    fPath     := '';
    fQuery    := '';
    fFragment := '';

    vars := TStringList.Create;
    try
      if TStringTemplate.Match([
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]?[query]#[fragment]',
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]?[query]',
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]#[fragment]',
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]',
                                 '[scheme]://[userinfo]@[host]/[path]?[query]#[fragment]',
                                 '[scheme]://[userinfo]@[host]/[path]?[query]',
                                 '[scheme]://[userinfo]@[host]/[path]?#[fragment]',
                                 '[scheme]://[userinfo]@[host]/[path]',
                                 '[scheme]://[host]:[port:int]/[path]?[query]#[fragment]',
                                 '[scheme]://[host]:[port:int]/[path]?[query]',
                                 '[scheme]://[host]:[port:int]/[path]?#[fragment]',
                                 '[scheme]://[host]:[port:int]/[path]',
                                 '[scheme]:///[path]?[query]#[fragment]',
                                 '[scheme]:///[path]?[query]',
                                 '[scheme]:///[path]?#[fragment]',
                                 '[scheme]:///[path]',
                                 '[scheme]://[host]/[path]?[query]#[fragment]',
                                 '[scheme]://[host]/[path]?[query]',
                                 '[scheme]://[host]/[path]?#[fragment]',
                                 '[scheme]://[host]/[path]',
                                 '[scheme]://[host]/',
                                 '[scheme]://[host]',
                                 '\\[host]\[path]',
                                 '[drive]:\[path]',
                                 '\\\[path]'
                               ], aValue, vars) then
      begin
        if vars.ContainsName('scheme') then
        begin
          fScheme := vars.Values['scheme'];

          if vars.ContainsName('userinfo')  then UserInfo   := vars.Values['userinfo'];
          if vars.ContainsName('host')      then fHost      := vars.Values['host'];
          if vars.ContainsName('port')      then fPort      := Parse(vars.Values['port']).AsInteger;
          if vars.ContainsName('path')      then fPath      := vars.Values['path'];
          if vars.ContainsName('query')     then fQuery     := vars.Values['query'];
          if vars.ContainsName('fragment')  then fFragment  := vars.Values['fragment'];
        end
        else if vars.ContainsName('drive') then
        begin
          fScheme := 'file';
          fPath   := vars.Values['drive'] + ':/';
          if vars.ContainsName('path') then
            fPath := fPath + Str.ReplaceAll(vars.Values['path'], '\', '/');
        end
        else if vars.ContainsName('path') then
        begin
          fScheme := 'file';

          if vars.ContainsName('host') then
            fHost := vars.Values['host'];

          fPath := Str.ReplaceAll(vars.Values['path'], '\', '/');
        end;
      end;

    finally
      vars.Free;
    end;
  end;


  procedure TUri.set_Fragment(const aValue: String);
  begin
    fFragment := aValue;
  end;

  procedure TUri.set_Host(const aValue: String);
  begin
    fHost := aValue;
  end;

  procedure TUri.set_Path(const aValue: String);
  begin
    fPath := aValue;
  end;

  procedure TUri.set_Port(const aValue: Integer);
  begin
    fPort := aValue;
  end;

  procedure TUri.set_Query(const aValue: String);
  begin
    fQuery := aValue;
  end;

  procedure TUri.set_Scheme(const aValue: String);
  begin
    fScheme := aValue;
  end;

  procedure TUri.set_UserInfo(const aValue: String);
  begin
    fUserInfo := aValue;

    if STR.EndsWith(fUserInfo, ':') then
      fUserInfo := Str.RTrim(fUserInfo, 1);
  end;



end.
