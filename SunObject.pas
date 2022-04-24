unit SunObject;

interface
uses
  Windows,  Classes, Graphics, GuitarObject;
type
  TSun = class
  private
    x, y, ran_x, ran_y, rad : integer;
    angle, move_sun_angle   : real;
    rays                    : real;
    round_point             : TPoint;
    procedure   Set_MoveSunAngle    (const Alpha : Real);     function    Get_MoveSunAngle         : Real;
    procedure   Set_RotatingPoint   (const pnt : TPoint);     function    Get_RotatingPoint        : Tpoint;
    procedure   Set_Rad             (const rad : Integer);    function    Get_Rad                : Integer;
    x, y, ran_x, ran_y      : integer;
    angle, move_sun_angle   : real;
    rays            : real;
  public
    constructor Create (const x,  y : integer) overload;
    procedure   Draw   (const Canvas: TCanvas);
    procedure   Sets;
  published
    property    PRotPoint      : Tpoint   read Get_RotatingPoint write Set_RotatingPoint;
    property    PMoveSunAngle  : Real     read Get_MoveSunAngle  write Set_MoveSunAngle;
    property    PRad           : Integer  read Get_Rad           write Set_Rad;
  end;

implementation

procedure  TSun.Set_MoveSunAngle (const Alpha : Real);
    begin
        move_sun_angle := Alpha;
    end;

function   TSun.Get_MoveSunAngle : Real;
    begin
        result := move_sun_angle;
    end;

procedure  TSun.Set_RotatingPoint   (const pnt : TPoint);
    begin
        round_point := pnt;
    end;

function   TSun.Get_RotatingPoint  : Tpoint;
    begin
        result := round_point;
    end;

procedure TSun.Set_Rad(const rad : Integer);
    begin
        self.rad := rad;
    end;

function  TSun.Get_Rad: Integer;
    begin
        result := rad;
    end;

function    Convert_x (const x, y, xc, yc : integer; const angle : real) : integer;
    begin
        result := Round((x-xc)*cos(angle) - (y -yc)*sin(angle)) ;
    end;

function    Convert_y (const x, y, xc, yc : integer; const angle : real) : integer;
    begin
        result := Round((x -xc)*sin(angle) + (y -yc)*cos(angle));
    end;

constructor TSun.Create (const x,  y : integer) overload;
    begin
        randomize;
        self   := TSun.Create;
        self.x := x;
        self.y := y;
        move_sun_angle := 0;
        angle  := 0;
        rad    := 45;
        round_point.x := 500;
        round_point.y := 500;
    end;

procedure TSun.Sets;
    begin
        ran_x := 1 + random(10);
        ran_y := 1 + random(10);
        angle := angle + 0.001;
        move_sun_angle := move_sun_angle + 0.00001;
    end;

procedure TSun.Draw(const Canvas: TCanvas);
    var
        Prev_PenColor, Prev_BrushColor : TColor;
        Prev_PenWidth : Integer;
        k, j, new_x, new_y : integer;
        s, g : real;
    begin
        Prev_PenColor   := Canvas.Pen.Color;
        Prev_BrushColor := Canvas.Brush.Color;
        Prev_PenWidth   := Canvas.Pen.Width;

        Canvas.Pen.Color    := clYellow;
        Canvas.Brush.Color  := clYellow;
        Canvas.Pen.Width := 3;

        TGuitar.RotatedEllipse(x, y, rad, rad, move_sun_angle, round_point, Canvas);
        new_x := Convert_x (x , y, round_point.x, round_point.y, move_sun_angle) + round_point.x;
        new_y := Convert_y (x , y, round_point.x, round_point.y, move_sun_angle) + round_point.y;
        x := new_x; y := new_y;
        k :=  25; s := 0; g := 2*pi/k;
        for j := 0 to k-1 do begin
            Canvas.MoveTo(x+round(rad*cos(s+angle))+round(cos(s+angle)),y+round(rad*sin(s+angle))+round(sin(s)));
            Canvas.Lineto(x+round((2+0.05*ran_x)*rad*cos(s+angle)),y+round((2+0.05*ran_y)*rad*sin(s+angle)));
            s := s + g;
        end;

        Canvas.Pen.Color   := Prev_PenColor;
        Canvas.Brush.Color := Prev_BrushColor;
        Canvas.Pen.Width   := Prev_PenWidth;
    end;
end.
