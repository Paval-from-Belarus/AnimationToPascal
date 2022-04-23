unit HumanSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Math, LimbSet;

type
  TCharachter = class
    procedure draw(const Canvas: TCanvas);
    procedure setPos(const floatX, floatY: Real);
    procedure setScale(const scale: Real);
    constructor Create(const X, Y: Integer); overload;
  public
    leftArm, rightArm: TArm;
    leftLeg, rightLeg: TLeg;
    body: TLimb;
    head: THead;
  private
    scale: real;
    posX, posY: Real;
    const
      defArmWidth = 4;
      defArmAngle = Pi / 4;
      defLegAngle = Pi / 8;
      defBodyLen = 50;
      defNeckLen = 3;
      defHeadSize = 15;

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
  posX := X;
  posY := Y;
  scale := 1;
  head := THead.Create(X, Y, defNeckLen, defHeadSize);
  body := TLimb.Create(0, X, Y, defBodyLen);
  leftArm := TArm.Create(-defArmAngle, X, Y);
  RightArm := TArm.Create(defArmAngle, X, Y);
  leftLeg := TLeg.Create(-defLegAngle, X, Y + body.Len);
  rightLeg := TLeg.Create(defLegAngle, X, Y + body.Len);
  ;
end;

procedure TCharachter.setScale(const scale: Real);
begin
  self.scale := scale;
  leftArm.setScale(scale);
  rightArm.setScale(scale);
  leftLeg.setScale(scale);
  rightLeg.setScale(scale);
  body.setScale(scale);
  head.setScale(scale);
  leftLeg.setPos(head.X, head.Y + body.Len);
  rightLeg.setPos(head.X, head.Y + body.Len);
end;

procedure TCharachter.setPos(const floatX: Real; const floatY: Real);
var
  X, Y: Integer;
begin
  posX := floatX;
  posY := floatY;
  X := round(floatX);
  Y := round(floatY);
  head.setPos(X, Y);
  body.setPos(X, Y);
  leftArm.setPos(X, Y);
  rightArm.setPos(X, Y);
  leftLeg.setPos(X, Y + body.Len);
  rightLeg.setPos(X, Y +  body.Len);
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

function getChanged(const startPos, endPos: TArmOrientation; tick: Real): TArmOrientation; overload;
begin
  Result.armAngle := (startPos.armAngle - (startPos.armAngle - endPos.armAngle) * tick);
  Result.elBowAngle := (startPos.elBowAngle - (startPos.elBowAngle - endPos.elBowAngle) * tick);
  Result.wristAngle := (startPos.wristAngle - (startPos.wristAngle - endPos.wristAngle) * tick);
end;

function getChanged(const startPos, endPos: Real; tick: Real): Real; overload;
begin
  Result := (startPos - (startPos - endPos) * tick);
end;

procedure tremor(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  startWrist = 0;
  upSpeed = 0.15;
  downSpeed = 0.13;
  endWrist = Pi / 2 + Pi / 6;
  startHead = Pi / 12 + Pi;
  endHead = Pi - Pi / 12;
  armOrient: array[0..1] of TArmOrientation = ((
    armAngle: -Pi / 4;
    elBowAngle: Pi / 3 + Pi / 12;
    wristAngle: Pi / 3 + Pi / 6;
  ), (
    armAngle: -Pi / 4;
    elBowAngle: Pi / 3;
    wristAngle: Pi / 12;
  ));
var
  castSpeed: Real;
begin
  if stage = 1 then
    castSpeed := upSpeed
  else
    castSpeed := downSpeed;
  with hero do
    if stage = 0 then
    begin
      leftArm.Orient := getChanged(armOrient[stage], armOrient[stage + 1], tick);
      head.setAngle(getChanged(startHead, endHead, tick));
    end
    else
    begin

      leftArm.Orient := getChanged(armOrient[stage], armOrient[stage - 1], tick);
      head.setAngle(getChanged(endHead, startHead, tick));
    end;
  if tick > 1 then
  begin
    tick := 0;
    if stage = 0 then
      stage := 1
    else
      stage := 0;
  end
  else
    tick := tick + castSpeed;
end;

procedure play(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  speedCast = 0.03;
  handPos: array[0..2] of Real = (Pi / 4 , Pi / 4 - Pi / 12, Pi / 4 + Pi / 12);
begin
  with hero do
  begin

    rightArm.setElbow(Pi / 2 + Pi / 3);
    leftArm.setElbow(Pi / 2 - Pi / 6);
    leftArm.setAngle(-Pi / 4);
    with rightArm do
      case stage of
        0:
          begin
            setAngle(Pi / 3);
            setWrist(handPos[stage]);
          end;
        1:
          begin
            setAngle(Pi / 6);
            setWrist(handPos[stage]);
          end;
        2:
          begin
            setAngle(Pi / 4);
            setWrist(handPos[stage]);
          end;
      end;

    if tick > 1 then
    begin
      stage := Random(3);
      tick := 0;
    end;
    tick := tick + speedCast;
  end;
end;

procedure walk(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  maxStage = 3;
  speedWalking = 0.1;
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
      tick := tick + speedWalking;
    end
    else
    begin
      stage := (stage + 1) mod maxStage;
      tick := 0;
    end;
  end;
 // var tempScale: Real := 1.2;
//  if hero.scale < 2 then
//    hero.setScale(hero.scale + 0.0005)
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
  mainHero.setPos(mainHero.posX + 0.05, mainHero.posY + 0.05);
  pbDrawGrid.Repaint;
end;

end.

