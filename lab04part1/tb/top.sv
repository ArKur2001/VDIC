import shape_pkg::*;

module top;
  initial begin : main_loop
    pts_t lines_of_pts[$];
    points_t points[$];
    int fd;     
    string line;                
    int offset, offset_prev;
    int eol;
    int x_y_index;
    int space_cnt;
    string slice;
  
    shape_c shape;
    polygon_c polygon_h;
    rectangle_c rectangle_h;
    triangle_c triangle_h;
    circle_c circle_h;
         
    fd = $fopen("/student/akurnik/VDIC/lab04part1/tb/lab04part1_shapes.txt", "r");
    if(fd == 0) $fatal(1, {"File was not opened succesfully : ", fd});

      while (!$feof(fd)) begin
        $fgets(line, fd);
        x_y_index = 0;  
        offset = 0;
        eol = line.len()-1;

          while (offset <= eol) begin
            $sscanf(line.substr(offset,eol), "%f %f", points[x_y_index].x, points[x_y_index].y);
            space_cnt = 0;
            offset += 1;
            slice = line.substr(offset,eol);
           
            foreach(slice[i]) begin
              if(slice[i] == " ") space_cnt +=1;

              if((space_cnt == 2) || ((space_cnt != 2) && (i == slice.len()-1))) begin 
                x_y_index++;
                offset += i;
                break;
              end
            end

            if((offset_prev == offset-1) || (eol <= offset+1)) break;
            offset_prev = offset;
          end

          if(points.size() > 0)
            lines_of_pts.push_back(points);
          points.delete();
        end

        $fclose(fd);

        foreach(lines_of_pts[i])begin
          if(lines_of_pts[i].size() == 2) begin
            if(!$cast(circle_h ,shape_factory::make_shape("circle", lines_of_pts[i])))
              $fatal(1, "Failed to cast shape factory result to circle_h");
            shape_reporter#(circle_c)::store_shape(circle_h);
          end
          else if(lines_of_pts[i].size() == 3) begin
            if(!$cast(triangle_h ,shape_factory::make_shape("triangle", lines_of_pts[i])))
              $fatal(1, "Failed to cast shape factory result to triangle_h");
            shape_reporter#(triangle_c)::store_shape(triangle_h);
          end
          else if(lines_of_pts[i].size() == 4) begin
            if(!$cast(rectangle_h ,shape_factory::make_shape("rectangle", lines_of_pts[i])))
              $fatal(1, "Failed to cast shape factory result to rectangle_h");
            shape_reporter#(rectangle_c)::store_shape(rectangle_h);
          end
          else if(lines_of_pts[i].size() > 4) begin
            if(!$cast(polygon_h ,shape_factory::make_shape("polygon", lines_of_pts[i])))
              $fatal(1, "Failed to cast shape factory result to polygon_h");
            shape_reporter#(polygon_c)::store_shape(polygon_h);
          end
        end

        shape_reporter#(circle_c)::report_shapes();
        shape_reporter#(triangle_c)::report_shapes();
        shape_reporter#(rectangle_c)::report_shapes();
        shape_reporter#(polygon_c)::report_shapes();

        $finish();
    end : main_loop
endmodule : top