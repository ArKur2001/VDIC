typedef struct {
  real x;
  real y;
}points_t;

typedef points_t pts_t[$];

virtual class shape_c;
  protected string name;
  protected points_t points[$];

  function new(string n, points_t p[$]);
    name = n;
    points = p;
  endfunction

  function void print();
    $display("--------------------------------------------------------------------------------");
    $display("This is: %0s", name);
    foreach(points[i])
      $display("  (%0.2f, %0.2f)", points[i].x, points[i].y);
    if(name == "circle") $display("radius: %0.2f",get_radius());
    if(name == "polygon") $display("Area is: can not be calculated for generic polygon.");
    else $display("Area is: %0.2f",get_area());
  endfunction

  pure virtual function real get_area();

  virtual function real get_radius();
  $fatal(1,"Cant call radius from shape_c");
endfunction	

endclass

class polygon_c extends shape_c;
  protected string name;
  protected points_t points [$];

  function new(string n, points_t p[$]);
    super.new(n, p);
    name = n;

    if(p.size() >= 4) 
      foreach(p[i]) points.push_back(p[i]);    
    else $fatal(1,{"That is not a polygon"});    

  endfunction

  function real get_area();
    return -1;
  endfunction

endclass

class rectangle_c extends shape_c;
  protected string name;
  protected points_t points [$];

  function new(string n, points_t p[$]);

      super.new(n, p);
      name = n;

      if(p.size() >= 4) 
          foreach(p[i]) points.push_back(p[i]);
      else  $fatal(1,{"Thats not a rectangle"});

  endfunction 

  function real get_area();
    real a = $sqrt((points[1].x - points[0].x)**2 + (points[1].y - points[0].y)**2);
    real b = $sqrt((points[2].x - points[1].x)**2 + (points[2].y - points[1].y)**2);
                
    return a*b;

  endfunction
endclass 

class triangle_c extends shape_c;
  protected string name;
  protected points_t points [$];

  function new(string n, points_t p[$]);

    super.new(n, p);
    name = n;

    if(p.size() >= 3)
      foreach(p[i]) points.push_back(p[i]);
    else $fatal(1,{"This is not a triangle"});
   
  endfunction

  function real get_area();
    real area = -0.5*(points[0].x*(points[1].y-points[2].y) + points[1].x*(points[2].y-points[0].y) + points[2].x*(points[0].y-points[1].y));
             
    return area;
  endfunction
endclass

class circle_c  extends shape_c;
  protected string name;
  protected points_t points [$];
  protected real r;

  function new(string n, points_t p[$]);

    super.new(n, p);
    name = n;

    if(p.size() >= 2) 
        foreach(p[i]) points.push_back(p[i]);
    else $fatal(1,{"This is not a circle"});
  
  endfunction

  function real get_radius();
    r = $sqrt((points[1].x-points[0].x)**2 + (points[1].y-points[0].y)**2);
    return r;
  endfunction

  function real get_area();
    real area;
               
    r = get_radius();
    area = 3.14*(r**2);

    return area;
  endfunction
endclass 

class shape_factory;

  static function shape_c make_shape(string shape, points_t points[$]);

    polygon_c polygon;
    rectangle_c rectangle;
    triangle_c triangle;
    circle_c circle;

    case (shape) 
      "polygon" :   begin
                      polygon = new(shape, points);
                      return polygon;
                    end
      "rectangle" : begin
                      rectangle = new(shape, points);
                      return rectangle;
                    end
      "triangle" :  begin
                      triangle = new(shape, points);
                      return triangle;
                    end
      "circle" :    begin
                      circle = new(shape, points);
                      return circle;
                    end
      default : 
          $error({"Theat is not a shape: ", shape});
      endcase 

  endfunction
endclass

class shape_reporter #(type T = shape_c);

  protected static T storage [$];

  static function void store_shape(T l);

      storage.push_back(l);

  endfunction 

  static function void report_shapes();

      foreach(storage[i]) storage[i].print();

  endfunction 
endclass