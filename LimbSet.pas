unit LimbSet;

interface

uses
  VCL.Graphics, System.Math;

const
  defArmLen = 30;
  defForeArmLen = 20;
  defHandLen = 10;

type
  TLimb = class
    procedure draw(const Canvas: TCanvas); virtual;
    procedure setPos(const X, Y: Integer); virtual;
    procedure setScale(const scale: Real); virtual;
    procedure setAngle(const angle: Real); virtual;
    constructor Create(const angle: Real; const X, Y: Integer; const Len: Integer);
  public
    Len: Integer;
  protected
    angle: Real;
    anrX, anrY: Integer;
    scale: Real;
  public
    property X: Integer read anrX;
    property Y: Integer read anrY;
    property Rotation: Real read angle write setAngle;
  end;

  TLongLimbOrientation = record
    mainAngle, midAngle, finAngle: Real;
  end;
  TLongLimbSize = record
    arm, foreArm, hand: Integer;
  end;

  TLongLimb = class(TLimb) //TLongLimb
  private
    foreArm, hand: TLimb;
    fingerX, fingerY: Integer;
    procedure setOrient(const savedPos: TLongLimbOrientation);
    function getOrient: TLongLimbOrientation;
    function getSize: TLongLimbSize;
    procedure setSize(const size: TLongLimbSize);
  public
    procedure draw(const Canvas: TCanvas); override;
    procedure setPos(const X, Y: Integer); override;
    procedure setAngle(const angle: Real); override;
    procedure setMidJoint(const angle: Real);
    procedure setFinJoint(const angle: Real);
    procedure setScale(const scale: Real); override;

    constructor Create(const angle: Real; const X, Y: Integer);
    property Orient: TLongLimbOrientation read getOrient write setOrient;
    property Size: TLongLimbSize read getSize write setSize;
    property midLimb: TLimb read foreArm;
    property finLimb: TLimb read hand;
  end;

  THead = class(TLimb)
    procedure draw(const Canvas: TCanvas); override;
    procedure setScale(const scale: Real); override;
    constructor Create(const X, Y: Integer; const neckLen, radius: Integer);
  private
    radius: Integer;
  end;

implementation

constructor TLimb.Create(const angle: Real; const X, Y: Integer; const Len: Integer);
begin
  anrX := X;
  anrY := Y;
  self.Len := Len;
  setAngle(angle);
  scale := 1;
end;

procedure TLimb.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    MoveTo(anrX, anrY);
    LineTo(anrX + Round(sin(angle) * Len), anrY + Round(cos(angle) * Len));
  end;
end;

procedure TLimb.setPos(const X: Integer; const Y: Integer);
begin
  anrX := X;
  anrY := Y;
end;

procedure TLimb.setAngle(const angle: Real);
begin
  self.angle := angle;
end;

procedure TLimb.setScale(const scale: Real);
var
  tempLen: Integer;
begin
  tempLen := round(Len * scale / self.scale);
  if tempLen <> Len then
  begin
    self.scale := scale;
    Len := tempLen;
  end;
end;

//Arm implementation

constructor TLongLimb.Create(const angle: Real; const X, Y: Integer);
begin
  foreArm := TLimb.Create(angle, X, Y, defforeArmLen);
  hand := TLimb.Create(angle, X, Y, defHandLen);
  inherited Create(angle, X, Y, defArmLen);
end;

procedure TLongLimb.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    MoveTo(anrX, anrY);
    LineTo(foreArm.anrX, foreArm.anrY);
    LineTo(hand.anrX, hand.anrY);
    LineTo(fingerX, fingerY);
  end;
end;

procedure TLongLimb.setPos(const X: Integer; const Y: Integer);
var
  changeX, changeY: Integer;
begin
  changeX := X - anrX;
  changeY := Y - anrY;
  foreArm.setPos(foreArm.anrX + changeX, foreArm.anrY + changeY);
  hand.setPos(hand.anrX + changeX, hand.anrY + changeY);
  inc(fingerX, changeX);
  inc(fingerY, changeY);
  inherited setPos(X, Y);
end;

procedure TLongLimb.setAngle(const angle: Real);
begin
  self.angle := angle;
  foreArm.anrX := anrX + Round(Len * sin(angle));
  foreArm.anrY := anrY + Round(Len * cos(angle));

  setMidJoint(foreArm.angle);
end;

procedure TLongLimb.setMidJoint(const angle: Real);
begin
  hand.anrX := foreArm.anrX + Round(foreArm.Len * sin(angle));
  hand.anrY := foreArm.anrY + Round(foreArm.Len * cos(angle));

  foreArm.setAngle(angle);
  setFinJoint(hand.angle);
end;

procedure TLongLimb.setFinJoint(const angle: Real);
begin
  fingerX := hand.anrX + Round(hand.Len * sin(angle));
  fingerY := hand.anrY + Round(hand.Len * cos(angle));
  hand.setAngle(angle);
end;

procedure TLongLimb.setScale(const scale: Real);
begin
  inherited setScale(scale);
  foreArm.setScale(scale);
  hand.setScale(scale);
  setAngle(angle);
  setMidJoint(foreArm.angle);
  //  setWrist(wristAngle);
end;

procedure TLongLimb.setOrient(const savedPos: TLongLimbOrientation);
begin
  setAngle(savedPos.mainAngle);
  setMidJoint(savedPos.midAngle);
  setFinJoint(savedPos.finAngle);
end;

function TLongLimb.getOrient: TLongLimbOrientation;
begin
  Result.mainAngle := angle;
  Result.midAngle := foreArm.angle;
  Result.finAngle := hand.angle;
end;

function TLongLimb.getSize: TLongLimbSize;
begin
  Result. arm := self.Len;
  Result.foreArm := foreArm.Len;
  Result.hand :=  hand.Len;
end;
procedure TLongLimb.setSize(const size: TLongLimbSize);
begin
  Len:= size.arm;
  foreArm.Len := size.foreArm;
  hand.Len := size.hand;
end;

// head implementation
constructor THead.Create(const X: Integer; const Y: Integer; const neckLen: Integer; const radius: Integer);
begin
  anrX := X;
  anrY := Y;
  Len := neckLen;
  self.radius := radius;
  angle := Pi;
  scale := 1;
end;

procedure THead.draw(const Canvas: TCanvas);
var
  centerX, centerY: Integer;
begin
  inherited Draw(Canvas);
  centerX := Round(anrX + (Len + radius) * sin(angle));
  centerY := Round(anrY + (Len + radius) * cos(angle));
  Canvas.Ellipse(centerX - radius, centerY - radius, centerX + radius, centerY + radius);
end;

procedure THead.setScale(const scale: Real);
var
  tempLen, tempRadius: Integer;
begin
  tempLen:= Round(Len * scale / self.scale);
  tempRadius := Round(radius * scale  / self.scale);
  if (tempRadius <> radius) and (tempLen <> Len) then
  begin
    self.scale := scale;
    radius := tempRadius;
    Len:= tempLen;
  end;
end;

end.

