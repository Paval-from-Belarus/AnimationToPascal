unit LandscapeObject;   {scenery}

interface
uses
  Windows,  Classes, Graphics, SunObject;
  type
    TLandscape = class
    constructor Create   (const x, y : integer);  virtual;
  private
    x, y : integer;
    {procedure   Draw     (const Canvas: TCanvas); virtual;
    procedure   Set_Pos  (const X, Y: Integer);   virtual;
    procedure   Set_Scale(const scale: Real);     virtual;}
  private
    Sun : TSun;

  end;
    TClouds = class (TLandscape)
    constructor Create           (const x, y : integer; const width : integer)  overload;
    procedure   Construct        (const ox, oy : integer; const Canvas : TCanvas; const k : real);
    procedure   Draw             (const Canvas : TCanvas);
  private
    x, y       : integer;
    px         : integer;
    k1, k2, k3 : real;
    client_width : integer;
    end;

    THill = class (TLandscape)
    constructor Create (const heigh, width : integer) overload;
    procedure   Draw (const Canvas : TCanvas);
    procedure   Draw_Road(const x1, y1, x2, y2: integer; const k : real; const Canvas : TCanvas);
    procedure   Hill_Move;
  private
    x, y : integer;
    k : real;
    client_heigh, client_width : integer;
    end;





implementation

{ TClouds }

procedure TClouds.Construct(const ox, oy: integer; const Canvas : TCanvas; const k : real);
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

constructor TClouds.Create(const x, y: integer; const width : integer)  overload;
    begin
        self.x := x;
        self.y := y;
        px := x;
        k1 := 0.5; k2 := 0.55; k3 := 0.7;
        client_width := width;
    end;

procedure TClouds.Draw(const Canvas: TCanvas);
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

constructor TLandscape.Create(const x, y: integer);
    begin
        self.x := x;
        self.y := y;
    end;

constructor THill.Create(const heigh, width: integer) overload;
    begin
        client_heigh := heigh;
        client_width := width;
        x := 0;
        k := 1;
        y := round(2.5/5*self.client_heigh);
    end;

procedure THill.Draw(const Canvas: TCanvas);
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

procedure THill.Draw_Road(const x1, y1, x2, y2: integer; const k : real; const Canvas : TCanvas);
    begin
        Canvas.PolyBezier([Point(Round(1/k*x1), Round(y1-1-k)), Point(x1-2, Round(0.75*client_heigh)),Point(x1 + 230, Round((1/k)*0.6*client_heigh)), Point(Round(k*0.42*client_width), client_heigh)]);
        Canvas.PolyBezier([Point(Round (k*x2), y2), Point(x2-2, Round(0.7*client_heigh)), Point(x2 + 230, Round(k*0.55*client_heigh)), Point(Round((1/k)*0.6*client_width), client_heigh)]);
        Canvas.MoveTo(Round(k*0.42*client_width), client_heigh);
        Canvas.LineTo(Round((1/k)*0.6*client_width),  client_heigh);
        Canvas.MoveTo(Round(1/k)*x1, y1);
        Canvas.LineTo(Round (k*x2), y2);
        if (Round (k*x2) - Round(1/k)*x1 > 25) then self.k := self.k - 0.001;
    end;


procedure THill.Hill_Move;
    begin

    end;

end.
