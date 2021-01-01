
  unit Uri.Tests;

interface

  uses
    Deltics.Smoketest;


  type
    UriComponents = record
      Scheme: String;
      UserInfo: String;
      Host: String;
      Port: Integer;
      Path: String;
      Query: String;
      Fragment: String;
      Authority: String;
      constructor Init(const aScheme: String; const aUserInfo: String; const aHost: String; const aPort: Integer; const aPath: String; const aQuery: String; const aFragment: String; const aAuthority: String);
    end;


    TUriTests = class(TTest)
    private
      procedure TestViaObject(const aUriString: String; const aComponents: UriComponents);
      procedure TestViaInterface(const aUriString: String; const aComponents: UriComponents);
    published
      procedure UriComponentsAreCorrectlyIdentifiedInStringsUsingObject;
      procedure UriComponentsAreCorrectlyIdentifiedInStringsUsingInterface;
      procedure EmptyPasswordIsStrippedFromUserInfo;
      procedure NonEmptyPasswordIsPreservedInUserInfo;
      procedure UncPathIsParsedAsFileScheme;
      procedure DriveLetterPathIsParsedAsFileScheme;
      procedure AsPathReturnsFilepathForValidUris;
      procedure AsPathRaisesInvalidOperationForInvalidUris;
    end;



implementation

  uses
    Deltics.Uri,
    Deltics.Exceptions;



  constructor UriComponents.Init(const aScheme: String;
                                 const aUserInfo: String;
                                 const aHost: String;
                                 const aPort: Integer;
                                 const aPath: String;
                                 const aQuery: String;
                                 const aFragment: String;
                                 const aAuthority: String);
  begin
    Scheme    := aScheme;
    UserInfo  := aUserInfo;
    Host      := aHost;
    Port      := aPort;
    Path      := aPath;
    Query     := aQuery;
    Fragment  := aFragment;
    Authority := aAuthority;
  end;


  procedure TUriTests.TestViaObject(const aUriString: String; const aComponents: UriComponents);
  var
    uri: TUri;
  begin
    uri := TUri.Create(aUriString);
    try
      Test('Scheme').Assert(uri.Scheme).Equals(aComponents.Scheme);
      Test('UserInfo').Assert(uri.UserInfo).Equals(aComponents.UserInfo);
      Test('Host').Assert(uri.Host).Equals(aComponents.Host);
      Test('Port').Assert(uri.Port).Equals(aComponents.Port);
      Test('Path').Assert(uri.Path).Equals(aComponents.Path);
      Test('Query').Assert(uri.Query).Equals(aComponents.Query);
      Test('Fragment').Assert(uri.Fragment).Equals(aComponents.Fragment);
      Test('Authority').Assert(uri.Authority).Equals(aComponents.Authority);

    finally
      uri.Free;
    end;
  end;

  procedure TUriTests.TestViaInterface(const aUriString: String; const aComponents: UriComponents);
  var
    uri: IUri;
  begin
    uri := TUri.Create(aUriString);

    Test('Scheme').Assert(uri.Scheme).Equals(aComponents.Scheme);
    Test('UserInfo').Assert(uri.UserInfo).Equals(aComponents.UserInfo);
    Test('Host').Assert(uri.Host).Equals(aComponents.Host);
    Test('Port').Assert(uri.Port).Equals(aComponents.Port);
    Test('Path').Assert(uri.Path).Equals(aComponents.Path);
    Test('Query').Assert(uri.Query).Equals(aComponents.Query);
    Test('Fragment').Assert(uri.Fragment).Equals(aComponents.Fragment);
    Test('Authority').Assert(uri.Authority).Equals(aComponents.Authority);
  end;


  procedure TUriTests.UriComponentsAreCorrectlyIdentifiedInStringsUsingObject;
  begin
    TestViaObject('file:///c:/folder/subfolder', UriComponents.Init('file', '', '', -1, 'c:/folder/subfolder', '', '', ''));
    TestViaObject('c:\duget\whatever',           UriComponents.Init('file', '', '', -1, 'c:/duget/whatever',   '', '', ''));

    TestViaObject('http://api.duget.org/v1/index.json',                                UriComponents.Init('http', '',      'api.duget.org', -1, 'v1/index.json',               '',       '',     'api.duget.org'));
    TestViaObject('http://user@hostname:443/api.duget.org/v1/index.json?latest#frag',  UriComponents.Init('http', 'user',  'hostname',     443, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user@hostname:443'));
    TestViaObject('https://hostname:443/api.duget.org/v1/index.json?latest#frag',      UriComponents.Init('https', '',     'hostname',     443, 'api.duget.org/v1/index.json', 'latest', 'frag', 'hostname:443'));
    TestViaObject('https://user@hostname/api.duget.org/v1/index.json?latest#frag',     UriComponents.Init('https', 'user', 'hostname',      -1, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user@hostname'));
  end;


  procedure TUriTests.UriComponentsAreCorrectlyIdentifiedInStringsUsingInterface;
  begin
    TestViaInterface('file:///c:/folder/subfolder', UriComponents.Init('file', '', '', -1, 'c:/folder/subfolder', '', '', ''));
    TestViaInterface('c:\duget\whatever',           UriComponents.Init('file', '', '', -1, 'c:/duget/whatever',   '', '', ''));

    TestViaInterface('http://api.duget.org/v1/index.json',                                UriComponents.Init('http',  '',         'api.duget.org', -1, 'v1/index.json',               '',       '',     'api.duget.org'));
    TestViaInterface('http://user@hostname:443/api.duget.org/v1/index.json?latest#frag',  UriComponents.Init('http',  'user',     'hostname',     443, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user@hostname:443'));
    TestViaInterface('https://hostname:443/api.duget.org/v1/index.json?latest#frag',      UriComponents.Init('https', '',         'hostname',     443, 'api.duget.org/v1/index.json', 'latest', 'frag', 'hostname:443'));
    TestViaInterface('https://user@hostname/api.duget.org/v1/index.json?latest#frag',     UriComponents.Init('https', 'user',     'hostname',      -1, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user@hostname'));
  end;


  procedure TUriTests.EmptyPasswordIsStrippedFromUserInfo;
  begin
    TestViaObject('https://user:@hostname/api.duget.org/v1/index.json?latest#frag',       UriComponents.Init('https', 'user',     'hostname',      -1, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user@hostname'));
    TestViaInterface('https://user:@hostname/api.duget.org/v1/index.json?latest#frag',    UriComponents.Init('https', 'user',     'hostname',      -1, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user@hostname'));
  end;


  procedure TUriTests.NonEmptyPasswordIsPreservedInUserInfo;
  begin
    TestViaObject('https://user:pwd@hostname/api.duget.org/v1/index.json?latest#frag', UriComponents.Init('https', 'user:pwd', 'hostname',      -1, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user:pwd@hostname'));
    TestViaInterface('https://user:pwd@hostname/api.duget.org/v1/index.json?latest#frag', UriComponents.Init('https', 'user:pwd', 'hostname',      -1, 'api.duget.org/v1/index.json', 'latest', 'frag', 'user:pwd@hostname'));
  end;


  procedure TUriTests.UncPathIsParsedAsFileScheme;
  begin
    TestViaObject('\\hostname\share\path', UriComponents.Init('file', '', 'hostname', -1, 'share/path', '', '', 'hostname'));
    TestViaInterface('\\hostname\share\path', UriComponents.Init('file', '', 'hostname', -1, 'share/path', '', '', 'hostname'));
  end;


  procedure TUriTests.DriveLetterPathIsParsedAsFileScheme;
  begin
    TestViaObject('c:\folder\path', UriComponents.Init('file', '', '', -1, 'c:/folder/path', '', '', ''));
    TestViaInterface('c:\folder\path', UriComponents.Init('file', '', '', -1, 'c:/folder/path', '', '', ''));
  end;


  procedure TUriTests.AsPathRaisesInvalidOperationForInvalidUris;
  var
    sut: IUri;

    procedure TestWithPath(const aPath: String);
    begin
      try
        sut.AsString := aPath;
        sut.AsFilePath;

      except
        Test.RaisedException(EInvalidOperation);
      end;
    end;

  begin
    sut := TUri.Create;

    TestWithPath('');
    TestWithPath('\\host');
    TestWithPath('\\host\');
    TestWithPath('c:');
  end;


  procedure TUriTests.AsPathReturnsFilepathForValidUris;
  var
    sut: IUri;

    procedure TestWithPath(const aTestPath: String; const aHost: String; const aPath: String);
    begin
      sut.AsString := aTestPath;

      Test('({filepath}).Scheme', [aTestPath]).Assert(sut.Scheme).Equals('file');
      Test('({filepath}).Host', [aTestPath]).Assert(sut.Host).Equals(aHost);
      Test('({filepath}).Path', [aTestPath]).Assert(sut.Path).Equals(aPath);
      Test('({filepath}).AsFilePath', [aTestPath]).Assert(sut.AsFilePath).Equals(aTestPath);
    end;

  begin
    sut := TUri.Create;

    TestWithPath('c:\folder', '', 'c:/folder');
    TestWithPath('\\hostname\share\path', 'hostname', 'share/path');
    TestWithPath('\\\share\path', '', 'share/path');
  end;




end.
