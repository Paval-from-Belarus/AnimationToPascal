unit HumanSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Math, LimbSet, GuitarObject, SunObject;

const
  defLegLen = 40;
  defShinLen = 30;
  defArmLen = 30;
  defForeArmLen = 20;
  defHandLen = 10;
  defFeetLen = 13;
  defLegSize : TLongLimbSize = ( arm:defLegLen; foreArm:defShinLen; hand: defFeetLen );

type
  TCharachter = class
    procedure draw(const Canvas: TCanvas);
    procedure setPos(const floatX, floatY: Real);
    procedure setScale(const scale: Real);
    constructor Create(const X, Y: Integer); overload;
  public
    leftArm, rightArm: TLongLimb;
    leftLeg, rightLeg: TLongLimb;
    body: TLimb;
    head: THead;
    posX, posY: Real;
    guitar: TGuitar;
  private
    scale: real;
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
    sun: TSun;
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
  leftArm := TLongLimb.Create(-defArmAngle, X, Y);
  rightArm := TLongLimb.Create(defArmAngle, X, Y);
  leftLeg := TLongLimb.Create(-defLegAngle, X, Y + body.Len);
  leftLeg.Size := defLegSize;
  rightLeg := TLongLimb.Create(defLegAngle, X, Y + body.Len);
  rightLeg.Size := defLegSize;

  guitar := TGuitar.Create(rightArm.midLimb.X, rightArm.midLimb.Y);
  guitar.PRotPoint := Point(rightArm.midLimb.X, rightArm.midLimb.Y);
  guitar.PAngle := 0;
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
  rightLeg.setPos(X, Y + body.Len);
end;

procedure TCharachter.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    head.draw(Canvas);
    body.draw(Canvas);
    leftArm.draw(Canvas);
    rightArm.draw(Canvas);
    leftLeg.draw(Canvas);
    rightLeg.draw(Canvas);
    guitar.Draw(Canvas);
  end;
end;

function getChanged(const startPos, endPos: TLongLimbOrientation; tick: Real): TLongLimbOrientation; overload;
begin
  Result.mainAngle := (startPos.mainAngle - (startPos.mainAngle - endPos.mainAngle) * tick);
  Result.midAngle := (startPos.midAngle - (startPos.midAngle - endPos.midAngle) * tick);
  Result.finAngle := (startPos.finAngle - (startPos.finAngle - endPos.finAngle) * tick);
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
  armOrient: array[0..1] of TLongLimbOrientation = ((
    mainAngle: -Pi / 4;
    midAngle: Pi / 3 + Pi / 12;
    finAngle: Pi / 3 + Pi / 6;
  ), (
    mainAngle: -Pi / 4;
    midAngle: Pi / 3;
    finAngle: Pi / 12;
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
  handPos: array[0..2] of Real = (Pi / 4, Pi / 4 - Pi / 12, Pi / 4 + Pi / 12);
begin
  with hero do
  begin
    rightArm.setMidJoint(Pi / 2 + Pi / 3);
    leftArm.setMidJoint(Pi / 2 - Pi / 6);
    leftArm.setAngle(-Pi / 4);
    with rightArm do
      case stage of
        0:
          begin
            setAngle(Pi / 3);
            setFinJoint(handPos[stage]);
          end;
        1:
          begin
            setAngle(Pi / 6);
            setFinJoint(handPos[stage]);
          end;
        2:
          begin
            setAngle(Pi / 4);
            setFinJoint(handPos[stage]);
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
  leftLegOrient: array[0..3] of TLongLimbOrientation = ((
    mainAngle: -Pi / 4;
    midAngle: (-60 / 180) * Pi;
    finAngle: Pi / 6;
  ), (
    mainAngle: -Pi / 9;
    midAngle: -Pi / 3;
    finAngle: Pi / 18
  ), (
    mainAngle: Pi / 12;
    midAngle: (-11 / 180) * Pi;
    finAngle: Pi / 3;
  ), (
    mainAngle: Pi / 6;
    midAngle: (25 / 180) * Pi;
    finAngle: (Pi / 2 + Pi / 12);
  ));
  rightLegOrient: array[0..3] of TLongLimbOrientation = ((
    mainAngle: Pi / 6;
    midAngle: (25 / 180) * Pi;
    finAngle: (Pi / 2 + Pi / 12);
  ), (
    mainAngle: Pi / 12;
    midAngle: (-11 / 180) * Pi;
    finAngle: Pi / 3;
  ), (
    mainAngle: -Pi / 9;
    midAngle: -Pi / 3;
    finAngle: Pi / 18
  ), (
    mainAngle: -Pi / 4;
    midAngle: -Pi / 3;
    finAngle: Pi / 6;
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
 // if hero.scale < 2 then
 //  hero.setScale(hero.scale + 0.0005)
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


  sun := TSun.Create(100, 100);
end;

procedure TFrames.pbDrawGridPaint(Sender: TObject);
begin
  anmWalk.update;
  anmPlay.update;
  anmTremor.update;
  mainHero.draw(Canvas);

 // guitar.Draw(Canvas);
  sun.Draw(Canvas);
end;

procedure TFrames.tmrRenderTimer(Sender: TObject);
begin
  Canvas.Pen.Color := clBlack;
   // Canvas.Brush.Color := clBlack;
  mainHero.guitar.PAngle := mainHero.leftArm.Rotation;
  //mainHero.setPos(mainHero.posX + 0.05, mainHero.posY + 0.05);
  pbDrawGrid.Repaint;

  //
  //sun.Sets;
end;

end.

