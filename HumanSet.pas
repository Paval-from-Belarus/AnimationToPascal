unit HumanSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Math, LimbSet, GuitarObject,
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
    Landscape : TLandscape;

    pathWay: TPath;
    repeatStage: Boolean;
    ElapsedTime: Cardinal;
    const
      duration = 54 * 1000;
      addtionalTime = 8 * 1000;
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

  Landscape := TLandscape.Create(Frames.Width, Frames.Height);
  repeatStage := false;
  ElapsedTime := 0;

  setLength(pathWay, 4);
  pathWay[0] := Point(200, 250);
  pathWay[1] := Point(350, 275);
  pathWay[2] := Point(430, 325);
  pathWay[3] := Point(520, 390);
  mainHero.PATH := pathWay;
end;

procedure TFrames.pbDrawGridPaint(Sender: TObject);
const
  scalable = 0.0002;
  borderY = 375;
begin
 // Sun.Sets;
//  Cloud.Shift_Clouds;
  inc(ElapsedTime, tmrRender.Interval);
  if ElapsedTime < duration then
  begin
    anmPlay.update;
    anmTremor.update;
    with mainHero do
    begin
      if STATE <> csDONE then
      begin
        updatePath;
       // setPos(posX + velocityX, posY + velocityY);
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
      PlaySound(nil, 0, 0);
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
    Landscape.Draw(Canvas);
  mainHero.draw(Canvas);
end;

procedure TFrames.tmrRenderTimer(Sender: TObject);
begin
  pbDrawGrid.Repaint;
end;

end.

