unit CharachterSet;

interface

uses
  LimbSet, VCL.Graphics, GuitarObject, Windows, Classes, System.Math;

const
  defLegLen = 40;
  defShinLen = 30;
  defArmLen = 30;
  defForeArmLen = 20;
  defHandLen = 10;
  defFeetLen = 13;
  defGuitarWidth = 110;
  defLegSize: TLongLimbSize = (
    arm: defLegLen;
    foreArm: defShinLen;
    hand: defFeetLen
  );

type
  TPath = array of TPoint;

  TCharachterState = (csProcess, csDone);

  TCharachter = class
    procedure draw(const Canvas: TCanvas);
    procedure setPos(const floatX, floatY: Real);
    procedure setScale(const scale: Real);
    procedure setPath(const points: TPath);
    procedure updatePath;
    procedure setState(const state: TCharachterState);
    function getState: TCharachterState;
    constructor Create(const X, Y: Integer); overload;
  private
    stopPoints: TPath;
    currPoint: Integer;
    onNext: Boolean;
    chState: TCharachterState;
  public
    leftArm, rightArm: TLongLimb;
    leftLeg, rightLeg: TLongLimb;
    body: TLimb;
    head: THead;
    posX, posY: Real;
    guitar: TGuitar;
    scale: real;
    velocityX, velocityY: Real;
    speed: Real;
    const
      defVelocity = 0.27;
      defArmWidth = 4;
      defArmAngle = Pi / 4;
      defLegAngle = Pi / 8;
      defBodyLen = 50;
      defNeckLen = 3;
      defHeadSize = 15;
    property PATH: TPATH write setPath;
    property STATE: TCharachterState read getState write setState;
  end;

  TAnimationAction = procedure(var stage: Integer; var tick: Real; var hero: TCharachter);

  TAnimation = class
    constructor Create(hero: TCharachter; action: TAnimationAction);
  private
    tick: Real;
    hero: TCharachter;
    action: TAnimationAction;
  public
    stage: Integer;
    procedure update();
  end;

implementation
//create new entity of TAnimation class

constructor TAnimation.Create(hero: TCharachter; action: TAnimationAction);
begin
  self.hero := hero;
  self.action := action;
end;
//implement action inside TAnimation object

procedure TAnimation.update;
begin
  action(stage, tick, hero);
end;
//create new entity of TCharachter class
//initialisation all inside objects
// That is legs, arms, guitar
//set default Charachter sizes
//and other options

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

  currPoint := -1;
  velocityX := defVelocity;
  velocityY := defVelocity;
  speed := defVelocity;
  onNext := false;
  chState := csDONE;

  guitar := TGuitar.Create(rightArm.midLimb.X, rightArm.midLimb.Y);
  guitar.PRotPoint := Point(rightArm.midLimb.X, rightArm.midLimb.Y);
  guitar.PWidth := defGuitarWidth;
  guitar.PAngle := leftArm.Rotation;

end;
//set Charachter's sizes according existing scale
//guitar's scale also refferes to it

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
  guitar.PWidth := defGuitarWidth + Round(defGuitarWidth / defBodyLen * (body.Len - defBodyLen));
  if scale = 1.1 then
    self.scale := scale;
//  guitar.setScale(scale);
end;

//Set position Charachter's head
//All Belong components will be transfer too
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
  guitar.set_Pos(X, Y + body.Len div 2);
  guitar.PRotPoint := Point(head.X, head.Y);
end;

//Set Path's points throught witch
//Charachter will be move
procedure TCharachter.setPath(const points: TPath);
begin
  stopPoints := points;
  currPoint := Low(points);
  onNext := false;
  chState := csProcess;
end;
//Implement Charachter moving (not completed)

procedure TCharachter.updatePath;
var
  distance: Real;
begin
  if (chState <> csDONE) then
  begin
    if not onNext then
    begin
      distance := sqrt(sqr(stopPoints[currPoint].X - posX) + sqr(stopPoints[currPoint].Y - posY));
      velocityX := (stopPoints[currPoint].X - posX) / distance * Speed;
      velocityY := (stopPoints[currPoint].Y - posY) / distance * speed;
      onNext := true;
    end;
    if (head.X <> stopPoints[currPoint].X) or (head.Y <> stopPoints[currPoint].Y) then
    begin
      setPos(posX + velocityX, posY + velocityY);
    end
    else
    begin
      if currPoint <> High(stopPoints) then
      begin
        onNext := false;
        inc(currPoint);
      end
      else
      begin
        currPoint := -1;
        setLength(stopPoints, 0);
        chState := csDONE;
      end;
    end;
  end;
end;

procedure TCharachter.setState(const state: TCharachterState);
begin
  chState := state;
end;

function TCharachter.getState: TCharachterState;
begin
  Result := chState;
end;
//Draw Character on Certain Canvas

procedure TCharachter.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    guitar.draw(Canvas);
    head.draw(Canvas);
    body.draw(Canvas);
    leftArm.draw(Canvas);
    rightArm.draw(Canvas);
    leftLeg.draw(Canvas);
    rightLeg.draw(Canvas);
  end;
end;

end.

