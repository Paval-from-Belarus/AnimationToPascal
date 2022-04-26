program togetherWork;

uses
  Vcl.Forms,
  HumanSet in 'HumanSet.pas' {Frames},
  LimbSet in 'LimbSet.pas',
  CharachterSet in 'CharachterSet.pas',
  AnimationSet in 'AnimationSet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrames, Frames);
  Application.Run;
end.
