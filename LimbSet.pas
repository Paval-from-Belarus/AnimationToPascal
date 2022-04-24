unit LimbSet;

interface

uses
  VCL.Graphics, System.Math;

const
  defLegLen = 40;
  defShinLen = 30;
  defArmLen = 30;
  defForeArmLen = 20;
  defHandLen = 10;
  defFeetLen = 13;

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

  TArmOrientation = record
    armAngle, elBowAngle, wristAngle: Real;
  end;

  TLegOrientation = record
    legAngle, kneeAngle, ankleAngle: Real;
  end;

  TArm = class(TLimb)
  private
    foreArm, hand: TLimb;
    fingerX, fingerY: Integer;
    procedure setOrient(const savedPos: TArmOrientation);
    function getOrient: TArmOrientation;
  public
    procedure draw(const Canvas: TCanvas); override;
    procedure setPos(const X, Y: Integer); override;
    procedure setAngle(const angle: Real); override;
    procedure setElbow(const angle: Real);
    procedure setWrist(const angle: Real);
    procedure setScale(const scale: Real); override;

    constructor Create(const angle: Real; const X, Y: Integer);
    property Orient: TArmOrientation read getOrient write setOrient;
  end;

  TLeg = class(TArm)
  private
    procedure setOrient(const savedPos: TLegOrientation);
    function getOrient: TLegOrientation;
  public
    procedure draw(const Canvas: TCanvas); override;
    procedure setPos(const X, Y: Integer); override;
    procedure setAngle(const angle: Real); override;
    procedure setKnee(const angle: Real);
    procedure setAnkle(const angle: Real);
    procedure setScale(const scale: Real); override;
    constructor Create(const angle: Real; const X, Y: Integer); overload;
    property Orient: TLegOrientation read getOrient write setOrient;
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

constructor TArm.Create(const angle: Real; const X, Y: Integer);
begin
  foreArm := TLimb.Create(angle, X, Y, defforeArmLen);
  hand := TLimb.Create(angle, X, Y, defHandLen);
  inherited Create(angle, X, Y, defArmLen);
end;

procedure TArm.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    MoveTo(anrX, anrY);
    LineTo(foreArm.anrX, foreArm.anrY);
    LineTo(hand.anrX, hand.anrY);
    LineTo(fingerX, fingerY);
  end;
end;

procedure TArm.setPos(const X: Integer; const Y: Integer);
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

procedure TArm.setAngle(const angle: Real);
begin
  self.angle := angle;
  foreArm.anrX := anrX + Round(Len * sin(angle));
  foreArm.anrY := anrY + Round(Len * cos(angle));

  setElbow(foreArm.angle);
end;

procedure TArm.setElbow(const angle: Real);
begin
  hand.anrX := foreArm.anrX + Round(foreArm.Len * sin(angle));
  hand.anrY := foreArm.anrY + Round(foreArm.Len * cos(angle));

  foreArm.setAngle(angle);
  setWrist(hand.angle);
end;

procedure TArm.setWrist(const angle: Real);
begin
  fingerX := hand.anrX + Round(hand.Len * sin(angle));
  fingerY := hand.anrY + Round(hand.Len * cos(angle));
  hand.setAngle(angle);
end;

procedure TArm.setScale(const scale: Real);
begin
  inherited setScale(scale);
  foreArm.setScale(scale);
  hand.setScale(scale);
  setAngle(angle);
  setElbow(foreArm.angle);
  //  setWrist(wristAngle);
end;

procedure TArm.setOrient(const savedPos: TArmOrientation);
begin
  setAngle(savedPos.armAngle);
  setElbow(savedPos.elBowAngle);
  setWrist(savedPos.wristAngle);
end;

function TArm.getOrient: TArmOrientation;
begin
  Result.armAngle := angle;
  Result.elBowAngle := foreArm.angle;
  Result.wristAngle := hand.angle;
end;
//Leg implementation

constructor TLeg.Create(const angle: Real; const X, Y: Integer);
begin
  inherited Create(angle, X, Y);
  self.Len := defLegLen;
  foreArm.Len := defShinLen;
  hand.Len := defFeetLen;
  hand.setAngle(Pi / 2);
  setAngle(angle);
end;

procedure TLeg.setAngle(const angle: Real);
begin
  inherited setAngle(angle);
end;

procedure TLeg.setKnee(const angle: Real);
begin
  inherited setElbow(angle);
end;

procedure TLeg.setAnkle(const angle: Real);
begin
  inherited setWrist(angle);
end;

procedure TLeg.draw(const Canvas: TCanvas);
begin
  inherited draw(Canvas);
end;

procedure TLeg.setPos(const X: Integer; const Y: Integer);
begin
  inherited setPos(X, Y);
end;

procedure TLeg.setScale(const scale: Real);
begin
  inherited setScale(scale);
end;

procedure TLeg.setOrient(const savedPos: TLegOrientation);
begin
  inherited setOrient(TArmOrientation(savedPos));
end;

function TLeg.getOrient: TLegOrientation;
begin
  Result := TLegOrientation(inherited getOrient);
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

