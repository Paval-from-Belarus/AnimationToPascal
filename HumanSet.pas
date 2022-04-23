unit HumanSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Math, LimbSet;

type
  TCharachter = class
    procedure draw(const Canvas: TCanvas);
    procedure setPos(const X, Y: Integer);
    procedure setScale(const scale: Real);
    constructor Create(const X, Y: Integer); overload;
  public
    leftArm, rightArm: TArm;
    leftLeg, rightLeg: TLeg;
    body: TLimb;
    head: THead;
  private
    neckX, neckY: Integer;
    bodyLen: Integer;
    scale: real;
    const
      defArmWidth = 4;
      defArmAngle = Pi / 4;
      defLegAngle = Pi / 8;
      defBodyLen = 50;
      defNeckLen = 7;
      defHeadSize = 15;
    property nextPos: Integer read bodyLen;

  end;

  TAnimationAction = procedure(var stage: Integer; var tick: Real; var hero: TCharachter);

  TAnimation = class
    constructor Create(hero: TCharachter; action: TAnimationAction);
  private
    tick: Real;
    stage: Integer;
    hero: TCharachter;
    action: TAnimationAction;
  public
    procedure update();
  end;

  TFrames = class(TForm)
    imgMap: TImage;
    btnGo: TButton;
    tmrRender: TTimer;
    pbDrawGrid: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure tmrRenderTimer(Sender: TObject);
    procedure pbDrawGridPaint(Sender: TObject);
  private
    anmWalk: TAnimation;
    anmPlay: TAnimation;
    anmTremor: TAnimation;
    mainHero: TCharachter;
  public
  end;

  TPosition = record
    startValue, finalValue: Real;
  end;

var
  Frames: TFrames;

implementation
{$R *.dfm}

constructor TAnimation.Create(hero: TCharachter; action: TAnimationAction);
begin
  self.hero := hero;
  self.action := action;
end;

procedure TAnimation.update;
begin
  action(stage, tick, hero);
end;

constructor TCharachter.Create(const X, Y: Integer);
begin
  self := TCharachter.Create;
  neckX := X;
  neckY := Y;
  bodyLen := defBodyLen;
  scale := 1;
  leftArm := TArm.Create(-defArmAngle, X, Y);
  RightArm := TArm.Create(defArmAngle, X, Y);
  leftLeg := TLeg.Create(-defLegAngle, X, Y + bodyLen);
  rightLeg := TLeg.Create(defLegAngle, X, Y + bodyLen);
  head := THead.Create(X, Y, defNeckLen, defHeadSize);
  body := TLimb.Create(0, X, Y, defBodyLen);
end;

procedure TCharachter.setScale(const scale: Real);
begin
  bodyLen := round(bodyLen * scale / self.scale);
  self.scale := scale;
  leftArm.setScale(scale);
  rightArm.setScale(scale);
  leftLeg.setScale(scale);
  rightLeg.setScale(scale);
  head.setScale(scale);
end;

procedure TCharachter.setPos(const X: Integer; const Y: Integer);
begin
  head.setPos(X, Y);
  leftArm.setPos(X, Y);
  rightArm.setPos(X, Y);
  leftLeg.setPos(X, Y + bodyLen);
  rightLeg.setPos(X, Y + bodyLen);
end;

procedure TCharachter.draw(const Canvas: TCanvas);
const
  headRadius = 10;
  angle = 0.5;
begin
  with Canvas do
  begin
    head.draw(Canvas);
    body.draw(Canvas);
    leftArm.draw(Canvas);
    rightArm.draw(Canvas);
    leftLeg.draw(Canvas);
    rightLeg.draw(Canvas);
  end;
end;

function getChanged(const startPos, endPos: TLegOrientation; tick: Real): TLegOrientation; overload;
begin
  Result.legAngle := (startPos.legAngle - (startPos.legAngle - endPos.legAngle) * tick);
  Result.kneeAngle := (startPos.kneeAngle - (startPos.kneeAngle - endPos.kneeAngle) * tick);
  Result.ankleAngle := (startPos.ankleAngle - (startPos.ankleAngle - endPos.ankleAngle) * tick);
end;

function getChanged(const startPos, endPos: Real; tick: Real): Real; overload;
begin
  Result := (startPos - (startPos - endPos) * tick);
end;

procedure tremor(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  startWrist = 0;
  endWrist = Pi / 2 + Pi / 6;
  startHead = Pi / 12 + Pi;
  endHead = Pi - Pi / 12;
  armOrient: TArmOrientation =
  (armAngle: -Pi / 4;
   elBowAngle: Pi /3 + Pi /12;
   wristAngle:  Pi / 12);

begin
  with hero do
    if stage = 0 then
    begin
      leftArm.setWrist(getChanged(startWrist, endWrist, tick));
      head.setAngle(getChanged(startHead, endHead, tick));
    end
    else
    begin

      leftArm.setWrist(getChanged(endWrist, startWrist, tick));
      head.setAngle(getChanged(endHead, startHead, tick));
    end;
        if tick > 1 then
        begin
          tick:= 0;
          if stage = 0 then
            stage:= 1 else stage:= 0;
        end else tick:= tick + 0.1;

end;

procedure play(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  speedWrist = 0.02;
begin
  with hero do
  begin
    rightArm.setElbow(Pi / 2 + Pi / 3);
    leftArm.setElbow(Pi / 2 - Pi / 6);
    leftArm.setAngle(-Pi / 4);
    case stage of
      0: begin
       rightArm.setAngle(Pi / 3);
      end;
      1: begin
       rightArm.setAngle(Pi / 6);
      end;
      2: begin
      rightArm.setAngle(Pi / 4);
      end;
    end;

    if tick > 1 then
    begin
      stage:= Random(3);
      tick := 0;
    end;
    tick := tick + speedWrist;
  end;
end;

procedure walk(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  maxStage = 3;
const
  leftLegOrient: array[0..3] of TLegOrientation = ((
    legAngle: -Pi / 4;
    kneeAngle: (-60 / 180) * Pi;
    ankleAngle: Pi / 6;
  ), (
    legAngle: -Pi / 9;
    kneeAngle: -Pi / 3;
    ankleAngle: Pi / 18
  ), (
    legAngle: Pi / 12;
    kneeAngle: (-11 / 180) * Pi;
    ankleAngle: Pi / 3;
  ), (
    legAngle: Pi / 6;
    kneeAngle: (25 / 180) * Pi;
    ankleAngle: (Pi / 2 + Pi / 12);
  ));
  rightLegOrient: array[0..3] of TLegOrientation = ((
    legAngle: Pi / 6;
    kneeAngle: (25 / 180) * Pi;
    ankleAngle: (Pi / 2 + Pi / 12);
  ), (
    legAngle: Pi / 12;
    kneeAngle: (-11 / 180) * Pi;
    ankleAngle: Pi / 3;
  ), (
    legAngle: -Pi / 9;
    kneeAngle: -Pi / 3;
    ankleAngle: Pi / 18
  ), (
    legAngle: -Pi / 4;
    kneeAngle: -Pi / 3;
    ankleAngle: Pi / 6;
  ));
begin
  with hero do
  begin
    if tick < 1 then
    begin
      leftLeg.Orient := getChanged(leftLegOrient[stage], leftLegOrient[stage + 1], tick);
      rightLeg.Orient := getChanged(rightLegOrient[stage], rightLegOrient[stage + 1], tick);
      tick := tick + 0.12;
    end
    else
    begin
      stage := (stage + 1) mod maxStage;
      tick := 0;
    end;
  end;
 // var tempScale: Real := 1.2;
  //hero.setScale(hero.scale + 0.008)
end;

procedure TFrames.FormCreate(Sender: TObject);
begin
  tmrRender.Enabled := true;
  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := clBlack;
  mainHero := TCharachter.Create(200, 200);
  anmWalk := TAnimation.Create(mainHero, walk);
  anmPlay := TAnimation.Create(mainHero, play);
  anmTremor := TAnimation.Create(mainHero, tremor);
end;

procedure TFrames.pbDrawGridPaint(Sender: TObject);
begin
  anmWalk.update;
  anmPlay.update;
  anmTremor.update;
  mainHero.draw(self.Canvas);
end;

procedure TFrames.tmrRenderTimer(Sender: TObject);
begin
  pbDrawGrid.Repaint;
end;

end.

