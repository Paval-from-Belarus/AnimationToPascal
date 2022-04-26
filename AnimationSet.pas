unit AnimationSet;

//This unit consits  Animation set that can be used in TAnimation object
interface

uses
  CharachterSet, LimbSet;

function getChanged(const startPos, endPos: TLongLimbOrientation; tick: Real): TLongLimbOrientation; overload;

function getChanged(const startPos, endPos: Real; tick: Real): Real; overload;

procedure stopDancer(var stage: Integer; var tick: Real; var hero: TCharachter);

procedure tremor(var stage: Integer; var tick: Real; var hero: TCharachter);

procedure play(var stage: Integer; var tick: Real; var hero: TCharachter);

procedure walk(var stage: Integer; var tick: Real; var hero: TCharachter);

procedure destroyer(var stage: Integer; var tick: Real; var hero: TCharachter);

procedure victory(var stage: Integer; var tick: Real; var hero: TCharachter);

implementation

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

procedure stopDancer(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  stopPos: TLongLimbOrientation = (
    mainAngle: -Pi / 8;
    midAngle: -Pi / 16;
    finAngle: -Pi / 2
  );
  startPos: TLongLimbOrientation = (
    mainAngle: Pi / 8;
    midAngle: -Pi / 16;
    finAngle: Pi / 2
  );
  midAnck = Pi / 2 + Pi / 6;
  clapSpeed = 0.055;
begin
  with hero do
  begin
    leftLeg.Orient := stopPos;
    rightLeg.Orient := startPos;
    rightLeg.setFinJoint(getChanged(startPos.finAngle, midAnck, tick));
    if tick < 1 then
      tick := tick + clapSpeed
    else
      tick := 0;
  end;
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
  armOrientation: array[0..3] of TLongLimbOrientation = ((
    mainAngle: Pi / 3;
    midAngle: Pi / 2 + Pi / 2.5;
    finAngle: Pi / 2 - Pi / 12;
  ), (
    mainAngle: Pi / 6;
    midAngle: Pi / 2 + Pi / 2.6;
    finAngle: Pi / 4 - Pi / 12;
  ), (
    mainAngle: Pi / 4;
    midAngle: Pi / 2 + Pi / 2.5;
    finAngle: Pi / 2 - Pi / 6;
  ), (
    mainAngle: Pi / 2.5;
    midAngle: Pi / 2 + Pi / 2.9;
    finAngle: Pi / 2 - Pi / 6;
  ));
  handPos: array[0..3] of Real = (Pi / 4, Pi / 4 + Pi / 12, Pi / 4 + Pi / 12, Pi / 4);
begin
  if tick > 1 then
  begin
    stage := Random(4);
    tick := 0;
  end;
  tick := tick + speedCast;
  hero.rightArm.Orient := armOrientation[stage];
end;

procedure walk(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  maxStage = 3;
  speedWalking = 0.13;
const
  leftLegOrient: array[0..3] of TLongLimbOrientation =((
  //passing behind leg stage
    mainAngle: -Pi / 6;
    midAngle: (-70 / 180) * Pi;
    finAngle: Pi / 12;
  ),(
  //stage translocation second leg upper
    mainAngle: -Pi / 10;
    midAngle: -Pi / 2.8;
    finAngle: Pi / 18
  ),(
  //
    mainAngle: Pi / 12;
    midAngle: (-40 / 180) * Pi;
    finAngle: Pi / 2.5;
  ), (
    mainAngle: Pi / 6;
    midAngle: (5 / 180) * Pi;
    finAngle: (Pi / 2 + Pi / 12);
  ));
  rightLegOrient: array[0..3] of TLongLimbOrientation = ((
    mainAngle: Pi / 6;
    midAngle: (5 / 180) * Pi;
    finAngle: (Pi / 2 + Pi / 12);
  ), (
    mainAngle: Pi / 12;
    midAngle: (-11 / 180) * Pi;
    finAngle: Pi / 2.5;
  ), (
    mainAngle: -Pi / 9;
    midAngle: -Pi / 3;
    finAngle: Pi / 18
  ), (
    mainAngle: -Pi / 6;
    midAngle: (-70 / 180) * Pi;
    finAngle: Pi / 12;
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
end;

procedure destroyer(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  maxStage = 4;
  rightArmOrientation: TLongLimbOrientation = (
    mainAngle: Pi / 2.5;
    midAngle: Pi / 2 + Pi / 3.5;
    finAngle: Pi / 2 - Pi / 6;
  );
  leftLegOrientation: array[0..1] of TLongLimbOrientation = ((
    mainAngle: -Pi / 8;
    midAngle: -Pi / 16;
    finAngle: -Pi / 2
  ), (
    mainAngle: -Pi / 5;
    midAngle: Pi / 10;
    finAngle: -Pi / 2
  ));
  rightLegOrientation: TLongLimbOrientation = (
    mainAngle: Pi / 8;
    midAngle: Pi / 16;
    finAngle: Pi / 2
  );
  rightArmOrient: array[0..3] of TLongLimbOrientation = ((
    mainAngle: Pi / 3;
    midAngle: Pi / 2 + Pi / 3;
    finAngle: Pi / 2 - Pi / 12;
  ), (
    mainAngle: Pi / 3.3;
    midAngle: Pi - Pi / 12;
    finAngle: Pi - Pi / 10;
  ), (
    mainAngle: Pi / 2.6;
    midAngle: Pi + Pi / 10;
    finAngle: Pi;
  ), (
    mainAngle: Pi / 2.5;
    midAngle: Pi / 2;
    finAngle: Pi / 2;
  ));
  castSpeed = 0.13;
begin
  with hero do
  begin
    head.setAngle(Pi);
    rightArm.Orient := getChanged(rightArmOrient[stage], rightArmOrient[stage + 1], tick);
    if stage <> 2 then
    begin
      guitar.PAngle := -rightArm.midLimb.Rotation;
      guitar.Set_Pos(head.X - defGuitarWidth div 2 - rightArm.finLimb.Len, head.Y);
    end;
    guitar.Set_Pos(head.X - defGuitarWidth div 2 - rightArm.finLimb.Len, head.Y);
    if tick > 1 then
    begin
      tick := 0;
      inc(stage);
    end;
    tick := tick + castSpeed;
  end;
end;

procedure victory(var stage: Integer; var tick: Real; var hero: TCharachter);
const
  rightOrient: array[0..1] of TLongLimbOrientation = ((
    mainAngle:  (Pi / 4);
    midAngle: (Pi - Pi / 14);
    finAngle: Pi / 2 + Pi / 3;
  ), (
    mainAngle: (Pi / 2 + Pi / 8);
    midAngle: (Pi - Pi / 12);
    finAngle: (Pi - Pi / 16)
  ));
  leftOrient: array[0..1] of TLongLimbOrientation = ((
    mainAngle: - (Pi / 4);
    midAngle: -(Pi - Pi / 14);
    finAngle: -(Pi / 2 + Pi / 3);
  ), (
    mainAngle: -(Pi / 2 + Pi / 8);
    midAngle: -(Pi - Pi / 12);
    finAngle: -(Pi - Pi / 16)
  ));
begin
  with hero do
  begin
    if stage = 0 then
  begin
    rightArm.Orient := getChanged(rightOrient[stage], rightOrient[stage + 1], tick);
    leftArm.Orient := getChanged(leftOrient[stage], leftOrient[stage + 1], tick);
  end else
  begin
       rightArm.Orient := getChanged(rightOrient[stage], rightOrient[stage - 1], tick);
    leftArm.Orient := getChanged(leftOrient[stage], leftOrient[stage - 1], tick);
  end;
    if (tick > 1) and (stage <> 2) then begin
    tick:= 0;
    if stage = 1 then
      stage:= 0 else stage:= 1;
    end
    else
      tick := tick + 0.06;
  end;
end;

end.

