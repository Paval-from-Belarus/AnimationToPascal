unit GuitarObject;

interface

uses
  Windows, Classes, Graphics;

type
  TGuitar = class
  private
    x, y: integer;
    round_point: TPoint;
    angle: real;
    procedure Set_Angle(const Alpha: Real);
    function Get_Angle: Real;
    procedure Set_RotatingPoint(const pnt: TPoint);
    function Get_RotatingPoint: Tpoint;
  public
    constructor Create(const x, y: integer)overload;
    procedure Draw(const Canvas: TCanvas);
    procedure RotateRectangle(const x1, y1, x3, y3: integer; const angle: real; const rot_point: TPoint; const Canvas: TCanvas);
    class procedure RotatedEllipse(cx, cy, a, b: integer; angle: real; const rot_point: TPoint; const Canvas: TCanvas);
    procedure Circle(const rad, x, y: integer; const Canvas: TCanvas);
  published
    property PRotPoint: Tpoint read Get_RotatingPoint write Set_RotatingPoint;
    property PAngle: Real read Get_Angle write Set_Angle;
    const
      size_width = 150;
      size_heigh = 5 * size_width div 12;
  end;

implementation

constructor TGuitar.Create(const x: Integer; const y: Integer);
begin
  self.x := x;
  self.y := y;
end;

procedure TGuitar.Set_RotatingPoint(const pnt: TPoint);
begin
  round_point := pnt;
end;

function TGuitar.Get_RotatingPoint: TPoint;
begin
  result := round_point;
end;

procedure TGuitar.Set_Angle(const Alpha: Real);
begin
  angle := Alpha;
end;

function TGuitar.Get_Angle: Real;
begin
  result := angle;
end;

function Convert_x(const x, y, xc, yc: integer; const angle: real): integer;
begin
  result := Round((x - xc) * cos(angle) - (y - yc) * sin(angle));
end;

function Convert_y(const x, y, xc, yc: integer; const angle: real): integer;
begin
  result := Round((x - xc) * sin(angle) + (y - yc) * cos(angle));
end;

procedure TGuitar.RotateRectangle(const x1, y1, x3, y3: integer; const angle: real; const rot_point: TPoint; const Canvas: TCanvas);
var
  xc, yc: integer;
  x2, y2, x4, y4: integer;
  xx1, xx2, xx3, xx4: integer;
  yy1, yy2, yy3, yy4: integer;
begin
  xc := rot_point.x;
  yc := rot_point.y;
  x2 := x3;
  x4 := x1;
  y2 := y1;
  y4 := y3;
  xx1 := Convert_x(x1, y1, xc, yc, angle) + xc;
  yy1 := Convert_y(x1, y1, xc, yc, angle) + yc;
  xx2 := Convert_x(x2, y2, xc, yc, angle) + xc;
  yy2 := Convert_y(x2, y2, xc, yc, angle) + yc;
  xx3 := Convert_x(x3, y3, xc, yc, angle) + xc;
  yy3 := Convert_y(x3, y3, xc, yc, angle) + yc;
  xx4 := Convert_x(x4, y4, xc, yc, angle) + xc;
  yy4 := Convert_y(x4, y4, xc, yc, angle) + yc;
  Canvas.Polygon([Point(xx1, yy1), Point(xx2, yy2), Point(xx3, yy3), Point(xx4, yy4), Point(xx1, yy1)]);
end;

procedure TGuitar.Draw(const Canvas: TCanvas);
var
  w_1, w_2, w_g, w_c, h_1, h_2, h_g, h_c: integer;
begin

  w_1 := Round(0.33 * size_width);
  w_2 := Round(0.17 * size_width);
  w_g := Round(0.42 * size_width);
  w_c := Round(0.083 * size_width);

  h_1 := size_heigh;
  h_2 := Round(0.8 * size_heigh);
  h_g := Round(0.04 * size_heigh);
  h_c := Round(0.08 * size_heigh);

  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := $00000040;
  Canvas.Brush.Color := $00000040;

  RotateRectangle(x, y - h_g, x + w_g, y + h_g, angle, round_point, Canvas);
  RotateRectangle(x + w_g, y - h_c, x + w_c + w_g, y + h_c, angle, round_point, Canvas);

  RotatedEllipse((2 * x - w_2 - w_1) div 2, (y), (w_1) div 2, (h_1) div 2, angle, round_point, Canvas);

  Canvas.Pen.Color := $00000040;
  Canvas.Brush.Color := $00000040;
  RotatedEllipse((x - w_2 + x) div 2, (y - h_2 div 2 + y + h_2 div 2) div 2, (x - (x - w_2)) div 2, (y + h_2 div 2 - (y - h_2 div 2)) div 2, angle, round_point, Canvas);
  Canvas.Pen.Color := clBlack;
  Canvas.Brush.Color := clBlack;
  RotatedEllipse(x - w_2 div 2 - Round(0.45 * w_1), y, Round(0.15 * h_1), Round(0.15 * h_1), angle, round_point, Canvas);
end;

class procedure TGuitar.RotatedEllipse(cx, cy, a, b: integer; angle: real; const rot_point: TPoint; const Canvas: TCanvas);
const
  MP = 0.55228475;
var
  rot_x, rot_y: integer;
  x1, x3, y1, y3: integer;
  xx1, xx3: integer;
  yy1, yy3: integer;
  CA, SA, ACA, ASA, BCA, BSA: Double;
  i, CX2, CY2: Integer;
  Dot_Arr: array[0..12] of TPoint;

  function TransformPoint(X, Y: Double): TPoint;
  begin
    Result.X := Round(cx + X * ACA + Y * BSA);
    Result.Y := Round(cy - X * ASA + Y * BCA);
  end;

begin
  rot_x := rot_point.x;
  rot_y := rot_point.y;
  x1 := cx + a div 2;
  x3 := cx - a div 2;
  y1 := cy + b div 2;
  y3 := cy - b div 2;

  xx1 := Convert_x(x1, y1, rot_x, rot_y, angle) + rot_x;
  yy1 := Convert_y(x1, y1, rot_x, rot_y, angle) + rot_y;
  xx3 := Convert_x(x3, y3, rot_x, rot_y, angle) + rot_x;
  yy3 := Convert_y(x3, y3, rot_x, rot_y, angle) + rot_y;

  cx := (xx1 + xx3) div 2;
  cy := (yy1 + yy3) div 2;

  angle := -angle;
  CA := Cos(angle);
  SA := Sin(angle);
  ACA := a * CA;
  ASA := a * SA;
  BCA := b * CA;
  BSA := b * SA;
  CX2 := 2 * cx;
  CY2 := 2 * cy;

  Dot_Arr[0] := TransformPoint(1, 0);
  Dot_Arr[1] := TransformPoint(1, MP);
  Dot_Arr[2] := TransformPoint(MP, 1);
  Dot_Arr[3] := TransformPoint(0, 1);
  Dot_Arr[4] := TransformPoint(-MP, 1);
  Dot_Arr[5] := TransformPoint(-1, MP);
  for i := 0 to 5 do
    Dot_Arr[i + 6] := Point(CX2 - Dot_Arr[i].x, CY2 - Dot_Arr[i].y);
  Dot_Arr[12] := Dot_Arr[0];
  Canvas.PolyBezier(Dot_Arr);
        {��������� ������� � ����������� ����������� �����}
  Canvas.FloodFill(cx + Round(0.5 * a), cy + Round(0.5 * a), Canvas.Pen.Color, TFillStyle.fsBorder);
  Canvas.FloodFill(cx + Round(0.5 * a), cy - Round(0.5 * a), Canvas.Pen.Color, TFillStyle.fsBorder);
  Canvas.FloodFill(cx - Round(0.5 * a), cy + Round(0.5 * a), Canvas.Pen.Color, TFillStyle.fsBorder);
  Canvas.FloodFill(cx - Round(0.5 * a), cy - Round(0.5 * a), Canvas.Pen.Color, TFillStyle.fsBorder);
end;

procedure TGuitar.Circle(const rad, x, y: integer; const Canvas: TCanvas);
begin
  Canvas.Ellipse(x - rad, y - rad, x + rad, y + rad);
end;

end.

