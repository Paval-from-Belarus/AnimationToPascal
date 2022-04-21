program togetherWork;

uses
  Vcl.Forms,
  HumanSet in 'HumanSet.pas' {Frames};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrames, Frames);
  Application.Run;
end.
