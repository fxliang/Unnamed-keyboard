$fn = 256;
pcb_edge_file = "dxfs/unnamed-Edge_Cuts.dxf";
// board parameters, unit: mm
socket_1350_thickness = 1.8;
solder_thickness = 0.2;
board_thickness = 1.6;
shell_thickness = 2.5;
asm_gap = 0.2;
// case cut info, top left 0, 0
type_c_cut_x = 133.5;
type_c_cut_y = -61.5;
type_c_cut_width = 15.8;
type_c_cut_height = 13;
trrs_cut_x = 119;
trrs_cut_y = 0;
trrs_cut_width = 16;
trrs_cut_height = 10;
// board info
board_width = 140;
board_height = 95.0130;
// gap between two cases
case_gap_l2r = 4;
// ----------------------------------------------------------------------------

total_case_height = shell_thickness + socket_1350_thickness + solder_thickness 
+ board_thickness + asm_gap;
shell_diff_height = total_case_height;
case_width = (asm_gap+shell_thickness)*2 + board_width;
offset_base_pcb = shell_thickness + asm_gap;
// ----------------------------------------------------------------------------
// case outline with offset 
module offset_shape() {
  offset(r=offset_base_pcb) import(pcb_edge_file);
}

// extrude base body, from z = 0
module base(){
  linear_extrude(height=total_case_height, center=false) {
    offset_shape();
  }
}

// add asm gap for assembly
module shape_of_shell_diff() {
    offset(r=asm_gap) import(pcb_edge_file);
}

// extrude shape for diff shell
module shell_diff() {
  translate([0, 0, shell_thickness ])
  linear_extrude(height = shell_diff_height, center = false) {
    shape_of_shell_diff();
  }
}
// type_c connector cut
module type_c_diff() {
  translate([type_c_cut_x, type_c_cut_y - type_c_cut_height, shell_thickness])
  cube([type_c_cut_width, type_c_cut_height, total_case_height]);
}

// trrs connector cut
module trrs_diff() {
  translate([trrs_cut_x, trrs_cut_y, shell_thickness])
  // mirror y axis
  mirror([0, -1, 0])
  cube([trrs_cut_width, trrs_cut_height, total_case_height]);
}

// shell case difference by  base() and shell_diff()
module shell_shape() {
  difference(){
    base();
    // cut type_c_diff
    type_c_diff();
    // cut trrs_diff
    trrs_diff();
    // cut shell
    shell_diff();
  }
}

module mount_poles() {
  translate([19.1, -31.6, shell_thickness]) {
    cylinder(h = socket_1350_thickness + solder_thickness, r = shell_thickness);
  }
  translate([19.1, -50.5, shell_thickness]) {
    cylinder(h = socket_1350_thickness + solder_thickness, r = shell_thickness);
  }
  translate([67.0, -59.5, shell_thickness]) {
    cylinder(h = socket_1350_thickness + solder_thickness, r = shell_thickness);
  }
  translate([95.9, -27.6, shell_thickness]) {
    cylinder(h = socket_1350_thickness + solder_thickness, r = shell_thickness);
  }
  translate([126.5, -27.6, shell_thickness]) {
    cylinder(h = socket_1350_thickness + solder_thickness, r = shell_thickness);
  }
  translate([123, -73.5, shell_thickness]) {
    cylinder(h = socket_1350_thickness + solder_thickness, r = shell_thickness);
  }
}
module mount_holes() {
  translate([19.1, -31.6, -shell_thickness]) {
    cylinder(h = total_case_height*2, r = 1);
  }
  translate([19.1, -50.5, -shell_thickness]) {
    cylinder(h = total_case_height*2, r = 1);
  }
  translate([67.0, -59.5, -shell_thickness]) {
    cylinder(h = total_case_height*2, r = 1);
  }
  translate([95.9, -27.6, -shell_thickness]) {
    cylinder(h = total_case_height*2, r = 1);
  }
  translate([123, -73.5, -shell_thickness]) {
    cylinder(h = total_case_height*2, r = 1);
  }
}
// left case
module left_case() {
  // move the left of case to x = 0
  difference() {
    translate([(shell_thickness + asm_gap), 0, 0]){
        mount_poles();
        shell_shape();
    }
    translate([(shell_thickness + asm_gap), 0, 0]){
        mount_holes();
    }
  }
}

// right case
module right_case() {
  // move to the right, add case_gap_l2r
  translate([case_width*2 + case_gap_l2r, 0, 0])
  // mirror x axis
  mirror([-1,0,0])
  // left case
  left_case();
}
// use modules
left_case();
right_case();
