unit LandscapeObject;   {scenery}

interface
uses
  Windows,  Classes, Graphics, GuitarObject;
  type

  TLandscape = class
  public
    constructor Create   (const client_width, client_heigh : integer);
    procedure   Draw     (const Canvas: TCanvas); virtual;
  protected
    class var client_width, client_heigh : integer;
  end;

    TClouds = class (TLandscape)
  public
    constructor Create           (const x, y : integer) overload;
    procedure   Construct        (const ox, oy : integer; const Canvas : TCanvas; const k : real);
    procedure   Draw             (const Canvas : TCanvas); override;
  private
    x, y       : integer;
    px         : integer;
    k1, k2, k3 : real;
  end;

    THill = class (TLandscape)
  public
    constructor Create overload;
    procedure   Draw     (const Canvas : TCanvas); override;
    procedure   Draw_Road(const x1, y1, x2, y2: integer; const k : real; const Canvas : TCanvas);
  private
    x, y : integer;
    k    : real;
  end;

     TSun = class (TLandscape)
  private
    x, y, ran_x, ran_y, rad : integer;
    angle, move_sun_angle   : real;
    rays                    : real;
    round_point             : TPoint;
    procedure   Set_MoveSunAngle    (const Alpha : Real);     function    Get_MoveSunAngle         : Real;
    procedure   Set_RotatingPoint   (const pnt : TPoint);     function    Get_RotatingPoint        : Tpoint;
    procedure   Set_Rad             (const rad : Integer);    function    Get_Rad                  : Integer;
  public
    constructor Create (const x,  y : integer) overload;
    procedure   Draw   (const Canvas: TCanvas); override;
    procedure   Sets;
  published
    property    PRotPoint      : Tpoint   read Get_RotatingPoint write Set_RotatingPoint;
    property    PMoveSunAngle  : Real     read Get_MoveSunAngle  write Set_MoveSunAngle;
    property    PRad           : Integer  read Get_Rad           write Set_Rad;
  end;
    {odjects}
  var
    Sun   : TSun;
    Hill  : THill;
    Clouds : TClouds;



implementation
{TLandscape}
constructor TLandscape.Create(const client_width, client_heigh : integer);
    begin
        self.client_width := client_width;
        self.client_heigh := client_heigh;
        Sun      := TSun.Create(1, client_heigh);

        Sun.PRad := 30;
        Sun.PRotPoint := Point (client_width div 2, Round (0.8*client_heigh));

        Hill  := THill.Create;
        Clouds := TClouds.Create(0,0);
    end;

procedure   TLandscape.Draw(const Canvas: TCanvas);
    begin
        Sun.Draw    (Canvas);
        Hill.Draw   (Canvas);
        Clouds.Draw (Canvas);
    end;

{TClouds}
procedure   TClouds.Construct(const ox, oy: integer; const Canvas : TCanvas; const k : real);
    var
        x, y : integer;
        i : integer;
        Dot_Arr : array[0..5] of TPoint;
    begin
        i := 0;
        x := ox; y := oy;
        Canvas.MoveTo(x, y);
        Canvas.PolyBezierTo([Point (Round(x - 61*k), Round(y - 2*k)), Point (Round(x - 62*k), Round(y - 70*k)), Point  (x, Round(y - 71*k))]);
        x := x; y :=  y - Round(71*k);
        Canvas.MoveTo (x, y);
        Canvas.PolyBezierTo([Point (Round(x - 14*k), Round(y - 37*k)), Point (Round(x + 45*k), Round(y - 73*k)),  Point (Round(x + 70*k), Round(y - 17*k))]);
        x := x + Round(70*k); y :=  y - Round(17*k);
        Canvas.MoveTo (x, y);
        Canvas.PolyBezierTo([Point (Round(x - 12*k), Round(y - 87*k)), Point (Round(x + 161*k), Round(y - 63*k)),  Point (Round(x + 137*k), Round(y + 13*k))]);
        x := x + Round(137*k); y := y + Round(13*k);
        Canvas.MoveTo (x, y);
        Canvas.PolyBezierTo([Point (Round(x + 115*k), Round(y - 42*k)), Point (Round(x + 154*k), Round(y + 68*k)),  Point (Round(x + 49*k), Round(y + 67*k))]);
        x := x + Round(49*k); y := y + Round(67*k);
        Canvas.MoveTo (x, y);
        Canvas.PolyBezierTo([Point (Round(x - 77*k), Round(y - 5*k)), Point (Round(x - 139*k),  y),  Point (ox,  oy)]);
   end;

constructor TClouds.Create(const x, y: integer) overload;
    begin
        self.x := x;
        self.y := y;
        px := x;
        k1 := 0.5; k2 := 0.55; k3 := 0.7;
    end;

procedure   TClouds.Draw(const Canvas: TCanvas);
    var
        Prev_PenColor: TColor;
        Prev_PenWidth : Integer;
    begin
        Prev_PenColor   := Canvas.Pen.Color;
        Prev_PenWidth   := Canvas.Pen.Width;

        Canvas.Pen.Color := clBlue;
        Canvas.Pen.Width := 1;
        self.Construct(px+client_width div 20,  y + 100, Canvas, k1);
        self.Construct(px+client_width div 3, y+140, Canvas, k2);
        self.Construct(px+Round(client_width / 1.6), y+120, Canvas, k3);
        inc(px);
        self.Construct(x -Round (0.3*client_width),    y+145, Canvas, k1);
        self.Construct(x -Round (0.6*client_width),  y+125, Canvas, k3);
        self.Construct(x -Round (client_width),  y+110, Canvas, k2);
        inc (x);
        if (px = client_width) then
          px := -x;
        if (x -Round (client_width)  = client_width) then
          x := -px;
        Canvas.Pen.Color   := Prev_PenColor;
        Canvas.Pen.Width   := Prev_PenWidth;
    end;


{THill}
constructor THill.Create overload;
    begin
        x := 0;
        k := 1;
        y := round(2.5/5*self.client_heigh);
    end;

procedure   THill.Draw(const Canvas: TCanvas);
    var
        Prev_PenColor, Prev_BrushColor : TColor;
        Prev_PenWidth : Integer;
    begin
        Prev_PenColor   := Canvas.Pen.Color;
        Prev_BrushColor := Canvas.Brush.Color;
        Prev_PenWidth   := Canvas.Pen.Width;

        Canvas.Pen.Width := 2;
        Canvas.Pen.Color := $215a00;
        Canvas.Brush.Color := $215a00;


        Canvas.Rectangle(0, client_heigh div 2 + 70, client_width, client_heigh);
        Canvas.Ellipse  (-10, Round(0.46*client_heigh), Round (client_width*0.56), Round(0.875*client_heigh));
        Canvas.Ellipse  (Round (client_width*0.48), Round (0.53*client_heigh), client_width, Round(0.875*client_heigh));

        Canvas.Pen.Width := 0;
        Canvas.Pen.Color := $00000040;
        Canvas.Brush.Color := $00000040;

        self.Draw_Road  (Round(0.15*client_width), Round(0.48*client_heigh), Round(0.2*client_width), Round(0.47*client_heigh)-1, k, Canvas);
        Canvas.FloodFill(Round(0.42*client_width), client_heigh-65,$00000040, fsBorder);

        Canvas.Pen.Color   := Prev_PenColor;
        Canvas.Brush.Color := Prev_BrushColor;
        Canvas.Pen.Width   := Prev_PenWidth;
    end;

procedure   THill.Draw_Road(const x1, y1, x2, y2: integer; const k : real; const Canvas : TCanvas);
    begin
        Canvas.PolyBezier([Point(Round(1/k*x1), Round(y1-1-k)), Point(x1-2, Round(0.75*client_heigh)),Point(x1 + 230, Round((1/k)*0.6*client_heigh)), Point(Round(k*0.42*client_width), client_heigh)]);
        Canvas.PolyBezier([Point(Round (k*x2), y2), Point(x2-2, Round(0.7*client_heigh)), Point(x2 + 230, Round(k*0.55*client_heigh)), Point(Round((1/k)*0.6*client_width), client_heigh)]);
        Canvas.MoveTo(Round(k*0.42*client_width), client_heigh);
        Canvas.LineTo(Round((1/k)*0.6*client_width),  client_heigh);
        Canvas.MoveTo(Round(1/k)*x1, y1);
        Canvas.LineTo(Round (k*x2), y2);
        if (Round (k*x2) - Round(1/k)*x1 > 25) then self.k := self.k - 0.001;
    end;

{TSun}

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
        self.x := x;
        self.y := y;
        move_sun_angle := 0;
        angle  := 0;
        rad    := 45;

    end;

procedure TSun.Sets;
    begin
        ran_x := 1 + random(10);
        ran_y := 1 + random(10);
        angle := angle + 0.001;
        move_sun_angle := move_sun_angle + 0.0001;
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

        self.PMoveSunAngle := self.PMoveSunAngle + 0.0001;

        Canvas.Pen.Color   := Prev_PenColor;
        Canvas.Brush.Color := Prev_BrushColor;
        Canvas.Pen.Width   := Prev_PenWidth;
    end;

end.
