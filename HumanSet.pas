unit HumanSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Math, GuitarObject;

type
  TFrames = class(TForm)
    imgMap: TImage;
    btnGo: TButton;
    tmrRender: TTimer;
    pbDrawGrid: TPaintBox;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrRenderTimer(Sender: TObject);
    procedure pbDrawGridPaint(Sender: TObject);
  private
    { Private declarations }
  public
  end;

  TPosition = record
    startValue, finalValue: Real;
  end;

  TLimb = class
    procedure draw(const Canvas: TCanvas); virtual;
    procedure setPos(const X, Y: Integer); virtual;
    procedure setScale(const scale: Real); virtual;
    procedure setAngle(const angle: Real); virtual;
    procedure change(const startAngle, finalAngle, tick: Real);
    constructor Create(const angle: Real; const X, Y: Integer); overload;
  protected
    angle: Real;
    anchorX, anchorY: Integer;
    Len: Integer;
    scale: Real;
  end;

  TArm = class(TLimb)
    procedure draw(const Canvas: TCanvas); override;
    procedure setPos(const X, Y: Integer); override;
    procedure setAngle(const angle: Real); override;
    procedure setElbow(const angle: Real);
    procedure setWrist(const angle: Real);
    procedure setScale(const scale: Real); override;
    constructor Create(const angle: Real; const X, Y: Integer); overload;

  private
    wristX, wristY: Integer;
    elBowX, elBowY: Integer;
    fingerX, fingerY: Integer;
    foreArmLen, handLen: Integer;
    elbowAngle, wristAngle: Real;
    const
      defArmLen = 30;
      defSecondLen = 20;
      defHandLen = 10;
  end;

  TLeg = class(TLimb)
    procedure draw(const Canvas: TCanvas); override;
    procedure setPos(const X, Y: Integer); override;
    procedure setAngle(const angle: Real); override;
    procedure setKnee(const angle: Real);
    procedure setScale(const scale: Real); override;
    constructor Create(const angle: Real; const X, Y: Integer); overload;

  private
    anchorX, anchorY: Integer;
    kneeX, kneeY: Integer;
    feetX, feetY: Integer;
    shinLen: Integer;
    kneeAngle: Real;
    dirForward: Boolean;
    const
      defLegLen = 40;
      defSecondLen = 30;
  end;

  TCharachter = class
    procedure draw(const Canvas: TCanvas);
    procedure setPos(const X, Y: Integer);
    procedure setScale(const scale: Real);
    constructor Create(const X, Y: Integer); overload;
  public
    leftArm, rightArm: TArm;
    leftLeg, rightLeg: TLeg;
    body, header: TLimb;
  private
    neckX, neckY: Integer;
    bodyLen: Integer;
    scale: real;
    const
      defArmWidth = 4;
      defArmAngle = Pi / 4;
      defLegAngle = Pi / 8;
      defBodyLen = 50;
  end;

  TAnimationAction = procedure(var hero: TCharachter);

  TAnimation = class
    procedure start;
    procedure stop;
    procedure TimerEvent(Sender: TObject);
    constructor Create(owner: TComponent); overload;
  private
    action: TAnimationAction;
    hero: TCharachter;
  public
    timer: TTimer;
    duration: Integer; //in milliseconds
  end;

var
  Frames: TFrames;
  mainHero: TCharachter;
  guitar  : TGuitar;
  animationSet: TAnimation;
  tick: Real;
  stage: Integer;

implementation
{$R *.dfm}

constructor TLimb.Create(const angle: Real; const X, Y: Integer);
begin
  self := TLimb.Create;
  anchorX := X;
  anchorY := Y;
  setAngle(angle);
  scale := 1;
end;

procedure TLimb.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    MoveTo(anchorX, anchorY);
    LineTo(anchorX + Round(sin(angle) * Len), anchorY + Round(cos(angle) + Len));
  end;
end;

procedure TLimb.change(const startAngle: Real; const finalAngle: Real; const tick: Real);
begin
  self.angle := (startAngle - (startAngle - finalAngle) * tick);
  setAngle(angle);
end;

procedure TLimb.setPos(const X: Integer; const Y: Integer);
begin
  anchorX := X;
  anchorY := Y;
end;

procedure TLimb.setAngle(const angle: Real);
begin
  self.angle := angle;
end;

procedure TLimb.setScale(const scale: Real);
begin
  Len := round(Len * scale / self.scale);
  self.scale := scale;
end;

constructor TAnimation.Create(owner: TComponent);
begin
  self := TAnimation.Create;
  timer := TTimer.Create(owner);
end;

procedure TAnimation.TimerEvent(Sender: TObject);
begin
  self.action(self.hero);
end;

procedure TAnimation.stop;
begin
  timer.Enabled := false;
end;

procedure TAnimation.start;
begin
  with self do
  begin
    timer.Enabled := true;
    timer.Interval := duration;
    timer.OnTimer := self.TimerEvent;
  end;
end;

constructor TLeg.Create(const angle: Real; const X, Y: Integer);
begin
 // inherited Create(angle, X, Y);
//  self:= inherited Create(angle, X, Y);
  self := TLeg.Create;
  self.angle := angle;
  anchorX := X;
  anchorY := Y;
  scale := 1;
  Len := defLegLen;
  shinLen := defSecondLen;
  setKnee(angle);
  setAngle(angle);
  dirForward := true;
end;

constructor TArm.Create(const angle: Real; const X, Y: Integer);
begin
  self := TArm.Create;
  self.angle := angle;
  anchorX := X;
  anchorY := Y;
  scale := 1;
  Len := defArmLen;
  foreArmLen := defSecondLen;
  handLen := defHandLen;
  setAngle(angle);
  setElbow(angle);
  setWrist(angle);
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
end;

procedure TLeg.setAngle(const angle: Real);
begin
  kneeX := anchorX + Round(Len * sin(angle));
  kneeY := anchorY + Round(Len * cos(angle));
  self.angle := angle;

  feetX := kneeX + Round(shinLen * sin(kneeAngle));
  feetY := kneeY + Round(shinLen * cos(kneeAngle));
end;

procedure TLeg.setKnee(const angle: Real);
begin
  feetX := kneeX + Round(shinLen * sin(angle));
  feetY := kneeY + Round(shinLen * cos(angle));
  kneeAngle := angle;
end;

procedure TLeg.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    MoveTo(anchorX, anchorY);
    LineTo(kneeX, kneeY);
    LineTo(feetX, feetY);
  end;
end;

procedure TLeg.setPos(const X: Integer; const Y: Integer);
var
  change: Integer;
begin
  change := X - anchorX;
  inc(kneeX, change);
  inc(feetX, change);
  anchorX := X;
  change := Y - anchorY;
  inc(kneeX, change);
  inc(feetX, change);
  anchorY := Y;
end;

procedure TLeg.setScale(const scale: Real);
begin
  Len := Round(Len * scale / self.scale);
  shinLen := Round(defSecondLen * scale / self.scale);
  setAngle(angle);
  setKnee(kneeAngle);
end;

procedure TArm.draw(const Canvas: TCanvas);
begin
  with Canvas do
  begin
    MoveTo(anchorX, anchorY);
    LineTo(elBowX, elBowY);
    LineTo(wristX, wristY);
    LineTo(fingerX, fingerY);
  end;
end;

procedure TArm.setPos(const X: Integer; const Y: Integer);
var
  change: Integer;
begin
  change := X - anchorX;
  inc(elBowX, change);
  inc(wristX, change);
  inc(fingerX, change);
  anchorX := X;
  change := Y - anchorY;
  inc(elBowY, change);
  inc(wristY, change);
  inc(fingerY, change);
  anchorY := Y;
end;

procedure TArm.setAngle(const angle: Real);
begin
  elBowX := anchorX + Round(Len * sin(angle));
  elBowY := anchorY + Round(Len * cos(angle));
  elbowAngle := angle;

  wristX := elBowX + Round(foreArmLen * sin(elbowAngle));
  wristY := elBowY + Round(foreArmLen * cos(elbowAngle));

  fingerX := wristX + Round(handLen * sin(wristAngle));
  fingerY := wristY + Round(handLen * cos(wristAngle));
end;

procedure TArm.setElbow(const angle: Real);
begin
  wristX := elBowX + Round(foreArmLen * sin(angle));
  wristY := elBowY + Round(foreArmLen * cos(angle));
  wristAngle := angle;

  fingerX := wristX + Round(handLen * sin(wristAngle));
  fingerY := wristY + Round(handLen * cos(wristAngle));
end;

procedure TArm.setWrist(const angle: Real);
begin
  fingerX := wristX + Round(handLen * sin(angle));
  fingerY := wristY + Round(handLen * cos(angle));
  wristAngle := angle;
end;

procedure TArm.setScale(const scale: Real);
begin
  Len := Round(Len * scale / self.scale);
  foreArmLen := Round(defSecondLen * scale / self.scale);
  handLen := Round(defSecondLen * scale / self.scale);

  setAngle(angle);
  setElbow(elbowAngle);
  setWrist(wristAngle);
  self.scale := scale;
end;

procedure TCharachter.setScale(const scale: Real);
begin
  bodyLen := Round(scale * defBodyLen);
  self.scale := scale;
  leftArm.setScale(scale);
  rightArm.setScale(scale);
  leftLeg.setScale(scale);
  rightLeg.setScale(scale);
end;

procedure TCharachter.setPos(const X: Integer; const Y: Integer);
begin
  neckX := X;
  neckY := Y;
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
    moveTo(neckX, neckY);
    LineTo(neckX, neckY + bodyLen);
    Ellipse(neckX - headRadius, neckY - 2 * headRadius, neckX + headRadius, neckY);
    leftArm.draw(Canvas);
    rightArm.draw(Canvas);
    leftLeg.draw(Canvas);
    rightLeg.draw(Canvas);
  end;
end;

procedure walk(var hero: TCharachter);
const
  limitAngle = Pi / 5;
  forwardSpeed = 0.02;
  kneeSpeed = 0.025;
  feetSpeed = 0.02;
  startAngle = -Pi / 8;
  middleAngle = Pi / 12;
  finishAngle = Pi / 5;
  startKneeAngle = -Pi / 6;
  middleKneeAngle = -Pi / 8;
  middleReturnAngle = - Pi /6;
  finishKneeAngle = 0;
begin
  with hero do
  begin

//    if stage = 1 then
//    begin
//      if (tick < 1) then
//      begin
//        with leftLeg do
//        begin
//          setAngle(startAngle -(startAngle - middleAngle) * tick);
//          setKnee(startKneeAngle - (startKneeAngle - middleKneeAngle) * tick);
//        end;
//        tick := tick + forwardSpeed;
//        with rightLeg do
//        begin
//          setAngle(finishAngle -(finishAngle - middleAngle) * tick);
//          setKnee(finishKneeAngle - (finishKneeAngle - middleKneeAngle) * tick);
//        end;
//      end
//      else begin
//        stage := 2;
//        tick:= 0;
//      end;
//    end;
//    if stage = 2 then
//    begin
//            if (tick < 1) then
//      begin
//        with leftLeg do
//        begin
//          setAngle(middleAngle -(middleAngle - finishAngle) * tick);
//          setKnee(middleKneeAngle - (middleKneeAngle - finishKneeAngle) * tick);
//        end;
//        tick := tick + forwardSpeed;
//        with rightLeg do
//        begin
//          setAngle(middleAngle -(middleAngle - startAngle) * tick);
//          setKnee(middleKneeAngle - (middleKneeAngle - startKneeAngle) * tick);
//        end;
//      end
//      else begin
//        stage := 3;
//        tick:= 0;
//      end;
//    end;
//    if stage = 3 then
//      begin
//             if (tick < 1) then
//      begin
//        with leftLeg do
//        begin
//          setAngle(finishAngle -(finishAngle - middleAngle) * tick);
//          setKnee(finishKneeAngle - (finishKneeAngle - middleKneeAngle) * tick);
//        end;
//        tick := tick + forwardSpeed;
//        with rightLeg do
//        begin
//          setAngle(startAngle -(startAngle - middleAngle) * tick);
//          setKnee(startKneeAngle - (startKneeAngle - middleKneeAngle) * tick);
//        end;
//      end
//      else begin
//        stage := 4;
//        tick:= 0;
//      end;
//
//      end;
//        if stage = 4then
//      begin
//             if (tick < 1) then
//      begin
//        with leftLeg do
//        begin
//          setAngle(middleAngle -(middleAngle - startAngle) * tick);
//          setKnee(middleKneeAngle - (middleKneeAngle - startKneeAngle) * tick);
//        end;
//        tick := tick + forwardSpeed;
//        with rightLeg do
//        begin
//          setAngle(middleAngle -(middleAngle - finishAngle) * tick);
//          setKnee(middleKneeAngle - (middleKneeAngle - finishKneeAngle) * tick);
//        end;
//      end
//      else begin
//        stage := 1;
//        tick:= 0;
//      end;
//
//      end;
  with leftLeg do
    begin
      if dirForward then
      begin
        tick := 0;
        dirForward := false;
      end;
      if (tick < 1) then
      begin
        with leftLeg do
        begin
          setAngle(Pi / 5 - Pi / 2.5 * tick);
          setKnee(-Pi / 3 * tick);
        end;
        with rightLeg do
        begin
          setAngle(-Pi / 5 + Pi / 2.5 * tick);
          setKnee(-Pi / 3 + Pi / 3 * tick);
        end;
        tick := tick + forwardSpeed;
      end
      else
      begin
        dirForward := true;
        tick := 0;
      end;

    end;

  end;

end;

procedure TFrames.FormCreate(Sender: TObject);
begin

  tmrRender.Enabled := true;
  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := clBlack;
  mainHero := TCharachter.Create(200, 200);
  guitar   := TGuitar.Create(400, 400);
  guitar.PRotPoint := Point (400, 400);
  guitar.PAngle := 0;
  animationSet := TAnimation.Create(Frames);
  stage := 1;
  animationSet.action := walk;
  animationSet.hero := mainHero;
  animationSet.duration := 30;
  animationSet.start;
  tick := 0;
end;

procedure TFrames.FormPaint(Sender: TObject);
begin

//  mainHero.draw;
 // mainHero.draw();
 // angle := angle + Pi / 12;
 // mainHero.leftArm.setFinger(angle);
end;

procedure TFrames.pbDrawGridPaint(Sender: TObject);
begin
  mainHero.draw(self.Canvas);
  guitar.Draw(self.Canvas, pmCopy);
end;

procedure TFrames.tmrRenderTimer(Sender: TObject);
begin

//  if mainHero.neckX = Frames.Width - 100 then
//    animationSet.stop
//  else
  mainHero.setPos(mainHero.neckX + 1, mainHero.neckY);
  guitar.PAngle := guitar.PAngle - 0.1;
  pbDrawGrid.Repaint;
//Canvas.Pen.Mode := pmNotXor;
//angle:= angle + 0.5;
//mainHero.leftArm.setWrist(angle);
//mainHero.leftArm.setFinger(angle);
 // mainHero.draw;
end;

end.

