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
    procedure   Shift_Clouds;
  private
    x, y       : integer;
    ox         : integer;
    k1, k2, k3 : real;
    client_width : integer;
    end;

    THill = class (TLandscape)
    constructor Create (const heigh, width : integer) overload;
    procedure   Draw (const Canvas : TCanvas);
    procedure   Construct (const ox, oy : integer; const Canvas : TCanvas);

  private
    x, y : integer;
    client_heigh, client_width : integer;
    end;



    TRoad = class (TLandscape)

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
        ox := x;
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


        self.Construct(x+40,  y+100,  Canvas, k1);
        self.Construct(x+240, y+140, Canvas,  k2);
        self.Construct(x+500, y+120, Canvas,  k3);


        Canvas.Pen.Color   := Prev_PenColor;
        Canvas.Pen.Width   := Prev_PenWidth;
    end;



procedure TClouds.Shift_Clouds;
    var
        x2 : integer;
    begin
        x := x + 2;
        if (x >= client_width div 4) then begin
            if (x2 < ox div 2) then x2 := ox;
            x2 := x2 + 1;
        end;
    end;

{ TLandscape }

constructor TLandscape.Create(const x, y: integer);
    begin
        self.x := x;
        self.y := y;
    end;

{ THill }

procedure THill.Construct(const ox, oy: integer; const Canvas: TCanvas);
    var
        x, y : integer;
    begin
        x := ox; y := oy;
        Canvas.MoveTo(x, y);
        Canvas.PolyBezierTo([Point(x+54, y-100), Point(x+204+client_width div 4, y-80), Point(x+210+client_width div 4, y+40)]);

        x :=  x+150+client_width div 4; y := y-25;
        Canvas.MoveTo(x, y);
        Canvas.PolyBezierTo([Point(x+54, y-100), Point(x+204+client_width div 4, y-80), Point(client_width, client_heigh div 2)]);

        x := client_width; y := client_heigh div 2;
        Canvas.MoveTo(x, y);
        Canvas.PolyBezierTo([Point(x, y), Point(x, y), Point(client_width, client_heigh)]);

        x := client_width; y := client_heigh;
        Canvas.MoveTo(x, y);
        Canvas.PolyBezierTo([Point(x, y), Point(x, y), Point(0, client_heigh)]);

        x := 0; y := client_heigh;
        Canvas.MoveTo(x, y);
        Canvas.PolyBezierTo([Point(x, y), Point(x, y), Point(0, client_heigh div 2)]);
    end;

constructor THill.Create(const heigh, width: integer) overload;
    begin
        client_heigh := heigh;
        client_width := width;
        x := 0;
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


        Canvas.Pen.Color   := $00000040;
        Canvas.Brush.Color := $00000040;
        Canvas.Pen.Width   := 1;

        self.Construct(x, y, Canvas);

        Canvas.FloodFill(client_width-100, client_heigh-20, $00000040,TFillStyle.fsSurface);

        Canvas.Pen.Color   := Prev_PenColor;
        Canvas.Brush.Color := Prev_BrushColor;
        Canvas.Pen.Width   := Prev_PenWidth;
    end;

end.
