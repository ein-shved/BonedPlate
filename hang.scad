include <BonedPlate.scad>

l=16;
w=3.8;
h=10;
d=4;
ep=0.1;

translate([-l -w/2,0,0.5]) {
    bonedPlate(3,3);
}
translate([0, l/2 + w/2, 0]){
    hang(3, hatHole=false);
    difference() {
        translate([0,-l/2, h/8]) {
            cube([2*w+d+2, l, h+h/4], center=true);
        }
        translate([-l -(w+ep*2)/2,-l/2 - (w+ep*2)/2,0]) {
            skeleton(2,2, w=w+ep*2);
        }
    }
    translate([-(2*w+d+2)/2, -16, h - w]) {
        cube([2*w+d+2, 6, 1.7*w + 30]);
    }
}
