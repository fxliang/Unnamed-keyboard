$fn = 1000;
pcb_edge_file = "dxfs/unnamed-Edge_Cuts.dxf";
socket_1350_thickness = 1.8;
solder_thickness = 0.2;
board_thickness = 1.6;
shell_thickness = 2.5;
asm_gap = 0.5;
total_case_height = shell_thickness + socket_1350_thickness + solder_thickness + board_thickness + asm_gap;
shell_diff_height = total_case_height;
case_width = (asm_gap+shell_thickness)*2 + 140;
offset_base_pcb = shell_thickness + asm_gap;

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
  translate([119, -13, shell_thickness])
  cube([15.8, 13, total_case_height]);
}

// trrs connector cut
module trrs_diff() {
  translate([133.5, -61.5, shell_thickness])
  // mirror y axis
  mirror([0, -1, 0])
  cube([16, 10, total_case_height]);
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

// left case
module left_case() {
  // move the left of case to x = 0
  translate([(shell_thickness + asm_gap), 0, 0])
  shell_shape();
}

// right case
module right_case() {
  // move to the right, add 2mm
  translate([case_width*2 + 2, 0, 0])
  // mirror x axis
  mirror([-1,0,0])
  // left case
  left_case();
}

// use modules
left_case();
right_case();
