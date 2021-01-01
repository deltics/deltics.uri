
{$apptype CONSOLE}

  program test;

uses
  Deltics.Smoketest,
  Deltics.Uri in '..\src\Deltics.Uri.pas',
  Uri.Tests in 'Uri.Tests.pas';

begin
  TestRun.Test(TUriTests);
end.
