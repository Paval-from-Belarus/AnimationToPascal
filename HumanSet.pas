unit HumanSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Math, LimbSet, GuitarObject, SunObject,
  MmSystem, LandscapeObject, CharachterSet, AnimationSet, System.Types;

type
  TFrames = class(TForm)
    tmrRender: TTimer;
    pbDrawGrid: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure tmrRenderTimer(Sender: TObject);
    procedure pbDrawGridPaint(Sender: TObject);
  private
    anmWalk: TAnimation;
    anmPlay: TAnimation;
    anmTremor: TAnimation;
    anmStay: TAnimation;
    anmDestroyer: TAnimation;
    anmVictory: TAnimation;
    mainHero: TCharachter;

    hill: THill;
    cloud: TClouds;
    sun: TSun;

    repeatStage: Boolean;
    ElapsedTime: Cardinal;
    const
      duration = 57 * 1000;
      addtionalTime = 7 * 1000;
  end;

var
  Frames: TFrames;

implementation
{$R *.dfm}


procedure TFrames.FormCreate(Sender: TObject);
begin
  tmrRender.Enabled := true;
  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := clBlack;
  mainHero := TCharachter.Create(200, 200);

  anmWalk := TAnimation.Create(mainHero, walk);
  anmPlay := TAnimation.Create(mainHero, play);
  anmTremor := TAnimation.Create(mainHero, tremor);
  anmStay := TAnimation.Create(mainHero, stopDancer);
  anmDestroyer := TAnimation.Create(mainHero, destroyer);
  anmVictory := TAnimation.Create(mainHero, victory);

  PlaySound('HeroTheme.wav', 0, SND_FILENAME or SND_ASYNC or SND_LOOP);

  sun := TSun.Create(100, 100);
  cloud := TClouds.Create(0, 0, Frames.Width);
  hill := THill.Create(Frames.Height, Frames.Width);

  repeatStage := false;
  ElapsedTime := 0;
end;

procedure TFrames.pbDrawGridPaint(Sender: TObject);
const
  scalable = 0.0002;
  borderY = 375;
begin
  Sun.Sets;
  Cloud.Shift_Clouds;
  inc(ElapsedTime, tmrRender.Interval);
  if ElapsedTime < duration then
  begin
    anmPlay.update;
    anmTremor.update;
    with mainHero do
    begin
      if posY < borderY then
      begin
        setPos(posX + velocityX, posY + velocityY);
        setScale(scale + scalable);
        anmWalk.update
      end
      else
        anmStay.update;
    end;
  end
  else
  if ElapsedTime < (duration + addtionalTime) then
  begin
    if anmDestroyer.stage < 2 then
    begin
      anmDestroyer.update;
      PlaySound(0, 0, 0);
    end
    else
    begin
        with mainHero do
        begin
              if anmDestroyer.stage < 3 then
                anmDestroyer.update else
                anmVictory.update;
  //        guitar.PRotPoint := guitar.Position;
        //   guitar.PAngle := guitar.PAngle  + Pi / 360;
          guitar.Position := Point(guitar.Position.X  - 2, guitar.Position.Y);
          anmStay.update;
        end;

    end;
      //thanks for watching
  end else
  begin
    anmWalk.update;
    with mainHero do
      setPos(posX + velocityX * 3, posY);
  end;
  Sun.Draw(Canvas);
  Cloud.Draw(Canvas);
  hill.Draw(Canvas);
  mainHero.draw(Canvas);
end;

procedure TFrames.tmrRenderTimer(Sender: TObject);
begin
  pbDrawGrid.Repaint;
end;

end.

