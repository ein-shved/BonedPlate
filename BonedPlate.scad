use <generic.scad>
use <omdl/math/bitwise.scad>

/* Types of edge walls */
EdgeWall = 0;

EdgeHole = bitwise_lsh(1, 0);
EdgePeg =  bitwise_lsh(1, 1);
EdgeHigh = bitwise_lsh(1, 2);
EdgeLow =  bitwise_lsh(1, 3);
EdgeScrew =  bitwise_lsh(1, 4);

EdgeHoleHigh = bitwise_or(EdgeHole, EdgeHigh);
EdgePegHigh = bitwise_or(EdgePeg, EdgeHigh);
EdgeHoleLow = bitwise_or(EdgeHole, EdgeLow);
EdgePegLow = bitwise_or(EdgePeg, EdgeLow);

module boneHole(d=4, h=10) {
  translate([0,0,h/2]) {
    cylinder(h=h+2, d=d+1, center=true, $fn=20);
  }
}

module boneSlice(l, w=3.8, h=10) {
  translate([0,0,h-2]) {
    polyhedron(
      points=[ [0,0,0], [w, 0, 0], [w+2,0,2], [-2, 0, 2],
                      [0,l,0], [w, l, 0], 
                       [w+2,l,2], [-2, l, 2] ],
      faces= [ [0, 1, 2, 3], [4, 5, 6, 7], 
                     [0, 1, 5, 4], [2, 3, 7, 6], 
                     [0, 3, 7, 4], [1, 2, 6, 5] ]
    );
  }
}
module boneY(l=16, w=3.8, h=10) {
  union() {
      cube([w,l,h]);
      *boneSlice(l, w, h);
  }
}
module boneX(l=16, w=3.8, h=10) {
    translate([0,w,0]) {
        rotate(a=-90, v=[0,0,1]) {
            boneY(l, w, h);
        }
    }
}
module angle(x, y, l=16, w=3.8, h=10) {
    translate([x*l+w, y*l+w, 0]) {
        union() {
            translate([l-w,0,0]) { boneY(l, w, h); }
            translate([0,l-w,0]) { boneX(l, w, h); }
        }
    }
}
module ender(r=0, w=3.8, h=10) {
    rotate(a=r, v=[0,0,1]) {
        union() {
            boneX(w,w,h);
            boneY(w,w,h);
            *translate([0,0,h-2]) {
                polyhedron(
                    points=[ [0,0,0], [0,0,2], [0, -2, 2], [-2, 0, 2] ],
                    faces= [ [0, 1, 2], [0, 1, 3],
                             [0, 2, 3], [1, 2, 3] ] );
            }
        }
    }
}

module bones(n=1, m=1, l=16, w=3.8, h=10) {
    union() {
        for (i = [0:n-1]) {
            translate([l*i, 0]) {
                boneX(l, w, h);
            }
            for (j = [0:m-1]) {
                if (i == 0) {
                    translate([0, l*j]) {
                        boneY(l, w, h);
                    }
                }
                angle(i, j, l, w, h);
            }
        }
        ender(0, w, h);
        translate( [n*l + w, 0, 0]) { ender(90, w,h); }
        translate( [n*l + w, m*l + w, 0]) { ender(180, w,h); }
        translate( [0, m*l + w, 0]) { ender(-90, w,h); }
    }
}
module skeleton(n=1, m=1, borderHoles=false,
                d=4, l=16, w=3.8, h=10)
{
    hsx = borderHoles ? 0 : 1;
    hsy = borderHoles ? 0 : 1;
    hex = n - hsx;
    hey = m - hsy;
    union() {
        difference() {
            bones(n, m, l=l, w=w, h=h);
            if (hex >= hsx && hey >= hsy) {
                for (i=[hsx:hex]) {
                    for(j=[hsy:hey]) {
                        translate([i*l+w/2,j*l+w/2,0]) {
                            boneHole(d, h);
                        }
                    }
                }
            }
        }
        if (hex >= hsx && hey >= hsy) {
            for (i=[hsx:hex]) {
                for(j=[hsy:hey]) {
                    translate([i*l+w/2,j*l+w/2,0]) {
                        screwHole(d, h, jamb=true);
                    }
                }
            }
        }
    }
}

function lh(p) = (bitwise_and(p, EdgeHigh) ? 2.5 :
                 bitwise_and(p, EdgeLow) ? -1.5 : 0);
function lhTranslate(byX, p) = ([!byX ? -lh(p) : 0, byX ? lh(p) : 0]);

module edgePeg(h, d, j, p)
{
    byX = j % 2 == 0;
    dist = j > 2;
    translate(lhTranslate(byX, p)) {
        rotate(v=[0, (j >0 && j < 3) ? 1 : 0,0], a=180) {
            union() {
                translate ([0,0, -0.5]) {
                    cylinder(h=h-1, d=d, center=true, $fn=30);
                }
                translate([0, 0, h/2 -0.5]) {
                    cylinder(h=1.1, d1=d, d2=d-1, center=true, $fn=30);
                }
            }
        }
    }
}
module edgeHole(w, d, j, p)
{
    byX = j % 2 == 0;
    dist = j > 1;
    translate(lhTranslate(byX,p)) {
        cylinder(h=w+2, d=d, center=true, $fn=30);
    }
}
module edgeScrew(w, d, h, j, p, diffMode)
{
    byX = (j % 2 == 0);
    dist = j > 1;
    if (diffMode) {
        translate([0,0, (byX ? -w/2 : w/2)]) {
            edgeHole(w, d+0.2, j, p);
        }
        translate([0,0, (byX ? -w/2 + 3 : w/2 - 3)]) {
            edgeHole(w+2, d+1.6, j, p);
        }
    } else {
        cube([byX ? l : h, byX ? h : l , 5], center=true);
    }
}
module edgeWalls(num, from, prog, l, h, d, w, diffMode, j)
{
    s=len(prog);
    byX = (j % 2 == 0);
    dist = j > 1;
    for (i=[0:num-1]) {
        translate ([from[0] + (byX ? i*l + w/2 : 0),
                    from[1] + (byX ? 0 : i*l + w/2), h/2])
        {
            p = prog[i % s];
            rotate (a=90, v = [byX ? 1 : 0, byX ? 0 : 1, 0]) {
                if (bitwise_and(p, EdgeHole) && diffMode) {
                    translate([0,0, (byX ? -w/2 : w/2)]) {
                        edgeHole(w, d+0.9, j, p);
                    }
                } else if (bitwise_and(p, EdgePeg) && !diffMode) {
                    if (j <= 1) {
                        translate([0, 0, byX ? w/2 : -w/2]) {
                            edgePeg(w, d+0.6, j, p);
                        }
                    } else {
                        translate([0, 0, byX ? -w*1.5 : w*1.5]) {
                            edgePeg(w, d+0.6, j, p);
                        }
                    }
                } else if (bitwise_and(p, EdgeScrew)) {
                    edgeScrew(w, d, h, j, p, diffMode);
                }
            }
        }
    }
}
module edgeWallCycle(n, m, edgeWalls, d, l, w, h, diffMode)
{
    for (i=[0:3]) {
        s = edgeWalls[i];
        byX = (i % 2 == 0);
        dist = (i > 1);
        edgeWalls( (byX ? n : m),
            [(byX ? l/2 : (dist ? l*n : 0)),
             (byX ? (dist ? l*m : 0) : l/2 )],
             s, l, h, d, w, diffMode, i);
    }
}

module bonedPlate (n=1, m=1, borderHoles=false,
                   edgeWalls = [[EdgeWall], [EdgeWall], [EdgeWall], [EdgeWall]],
                   d=4, l=16, w=3.8, h=10)
{
    difference() {
        union() {
            skeleton(n, m, borderHoles, d, l, w, h);
            translate([0,0,h]) { cube([l*n + w, l*m + w, w/2]); }
            edgeWallCycle(n, m, edgeWalls, d, l, w, h, false);
        }
        edgeWallCycle(n, m, edgeWalls, d, l, w, h, true);
    }
}

module hang(n=1, d=4, e=0.1, l=16, w=3.8, h=10, hatHole=true)
{
    difference() {
        translate([-(w*2 + d + 2) / 2, 0, - (h/2)] ) {
            cube( [2*w + (d+2), (n-1)*l, h + (h/4) ]);
        }
        translate([ - l - ((w+e*2)/2), - l/2  - (w + e*2)/2, 0]) {
            skeleton(2, n+1, false, w=w+e*2, d=d+e);
        }
        for(i=[1:n-1]) {
            translate([0, l*i - l/2, -h]) {
                cylinder(d=d+e, h=h*2, $fn=20);
            }
            if (hatHole) {
                translate([0, l*i - l/2, -h - h/2 + d/2]) {
                    cylinder(d=d*2.5, h=h, $fn=20);

                }
            }
        }
        translate([-(d/2),0,0]) {
            cube( [d, n*l, h + (h/4) ]);
        }
    }
}
module __calcedTriangleBone(a, b, c, ba, ca, h)
{
    m = max(b, c);
    _ba = (ba > 90) ? 180 - ba : ba;
    _px = c * cos(_ba);
    _py = c * sin(_ba);
    hull() {
        polyhedron( [ [0,0,0], [0,0,h], [a,0,0], [a,0,h], 
                      [_px, _py, 0], [_px, _py, h] ],
                    [ [0, 1, 3, 2], [0, 1, 5, 4], [ 2, 3, 5, 4 ],
                      [0, 2, 4], [1, 3, 5] ]);
    }
}

/**
 * creates flat triangle width widh of h and
 *  - either side of length a and angles of ba and ca degrees
 *  - either sides of length a, b and angle ca degrees
 *  - or sides of length a, b, c
 *
 * ba  _c_
 *    |  /
 *  a | /  b
 *    |/
 *    ca
 */
module triangleBone(a=0, b=0, c=0, ba=0, ca=0, h=1)
{
    assert(a>0);
    if (ba == 0 && ca == 0) {
        assert(b > 0 && c > 0);
        assert(a + b > c && a + c > b && b + c > a);
        _ba = acos ( (a*a + c*c - b*b)/(2*a*c));
        _ca = acos ( (a*a + b*b - c*c)/(2*a*b));
        __calcedTriangleBone(a, b, c, _ba, _ca, h);
    } else if (ba == 0) {
        assert (ca < 180);
        assert (b > 0 && c == 0);
        _c = sqrt(a*a + b*b - 2*a*b*cos(ca));
        _ba = acos ( (a*a + _c*_c - b*b)/(2*a*_c));
        __calcedTriangleBone(a, b, _c, _ba, ca, h);
    } else if (ca == 0) {
        assert (ba < 180);
        assert (c > 0 && b == 0);
        _b = sqrt(a*a + c*c - 2*a*c*cos(ba));
        _ca = acos ( (a*a + c*c - b*b)/(2*a*c));
        __calcedTriangleBone(a, _b, c, ba, _ca, h);
    } else {
        assert (ba + ca < 180);
        aa = 180 - ba - ca;
        _c = a * sin(ca) / sin(aa);
        _b = a * sin(ba) / sin(aa);
        __calcedTriangleBone(a, _b, _c, ba, ca, h);
    }
}
