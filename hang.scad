include <BonedPlate.scad>

l=16;
w=3.8;
h=10;
d=4;
ep=0.1;

translate([-l -w/2,0,0.0]) {
    bonedPlate(3,3, boltHoles=[1,1,1,1]);
}
module hangComplex() {
    union() {
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
            cube([2*w+d+2, 6, 1.7*w + 43]);
        }
        translate([-(2*w+d+2)/2, -l, - w - 1.2 ]) {
            rotate(v=[0,0,1], a=180) {
                rotate(v=[0,1,0], a=-90) {
                    triangleBone(a=47.66, b=10, ca=90, h=w/1.5);
                }
            }
        }
        translate([(2*w+d+2)/2 - w/1.5, -l, - w - 1.2 ]) {
            rotate(v=[0,0,1], a=180) {
                rotate(v=[0,1,0], a=-90) {
                    triangleBone(a=47.66, b=10, ca=90, h=w/1.5);
                }
            }
        }
        translate([0,-l - 2.23, 43]) {
            cube([2*w + d + 2, 1.7*w + 10, w], center=true);
        }
    }
}
module hangSimple() {
    module hangBone() {
        rotate(v=[0,0,1], a=180) {
            rotate(v=[0,1,0], a=-90) {
                triangleBone(a=w/2 + l + 20, b=20, ca=90, h=w/1.5);
            }
        }
    }
    difference() {
        union() {
            translate([-l/2, -l, 0]) {
                cube([l, w*1.5, w/2 + l + 35 + w/2]);
            }
            translate([-l/2, -l]) {
                hangBone();
            }
            translate([l/2 - w/1.5, -l]) {
                hangBone();
            }
            translate([0, - l - 10, w/2 + l + 20 - w/2 + w/2]) {
                cube([l, 20, w], center=true);
            }
        }
        translate([ 0, -l/2, h/2]) {
            rotate(a=90, v= [1,0,0]) {
                cylinder(d=d+ep, h=3*w, $fn=30);
            }
        }
        translate([ 0, -l/2, w/2 + l + 30 + w/2]) {
            rotate(a=90, v= [1,0,0]) {
                cylinder(d=d+ep, h=3*w, $fn=30);
            }
        }
        translate([ 0, -l - 15, w/2 + l + 20 - 1.5*w]) {
            cylinder(d=d+ep, h=3*w, $fn=30);
        }
    }
}

*translate([0, l/2 + w/2, 0]){
    hangComplex();
}
translate([l/2, l/2 + w/2, 0]){
    hangSimple();
}
