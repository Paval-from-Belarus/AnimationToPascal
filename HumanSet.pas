unit HumanSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Math, LimbSet;

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



  TCharachter = class
    procedure draw(const Canvas: TCanvas);
    procedure setPos(const X, Y: Integer);
    procedure setScale(const scale: Real);
    constructor Create(const X, Y: Integer); overload;
  public
    leftArm, rightArm: TArm;
    leftLeg, rightLeg: TLeg;
    body, head: TLimb;
  private
    neckX, neckY: Integer;
    bodyLen: Integer;
    scale: real;
    const
      defArmWidth = 4;
      defArmAngle = Pi / 4;
      defLegAngle = Pi / 8;
      defBodyLen = 50;
    property nextPos: Integer read bodyLen;
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
  animationSet: TAnimation;
  tick: Real;
  stage: Integer;

implementation
{$R *.dfm}



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


procedure TCharachter.setScale(const scale: Real);
begin
  bodyLen := round(bodyLen * scale / self.scale);
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
  middleReturnAngle = -Pi / 6;
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
  var tempScale: Real:= 1.2;
    hero.setScale(hero.scale + 0.008)
end;

procedure TFrames.FormCreate(Sender: TObject);
begin
  tmrRender.Enabled := true;
  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := clBlack;
  mainHero := TCharachter.Create(200, 200);

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
end;

procedure TFrames.tmrRenderTimer(Sender: TObject);
begin

//  if mainHero.neckX = Frames.Width - 100 then
//    animationSet.stop
//  else
  mainHero.setPos(mainHero.neckX + 1, mainHero.neckY);
  pbDrawGrid.Repaint;
//Canvas.Pen.Mode := pmNotXor;
//angle:= angle + 0.5;
//mainHero.leftArm.setWrist(angle);
//mainHero.leftArm.setFinger(angle);
 // mainHero.draw;
end;

end.

