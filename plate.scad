include <BonedPlate.scad>

dir = [ EdgeHoleHigh, EdgePegLow ];
rev = [ EdgePegHigh,  EdgeHoleLow ];
wall = [EdgeWall];
screw = [EdgeScrew];

n=8;
m=8;
l=16;
w=3.8;
sp = 0;

function place(x,y) = ([ x * (n * l + sp + w),
                         y * (m * l + sp + w)]);

module putPlate(x, y, edgeWalls) {
    translate (place(x,y)) {
        bonedPlate(n, m, false, w=3.8, edgeWalls=edgeWalls);
    }
}
//grid 2 x 3
//putPlate(0, 0, [ wall, wall, dir, dir ] );
//putPlate(1, 0, [ wall, rev, dir, dir ]);
//putPlate(2, 0, [ wall, rev, dir, screw ]);

putPlate(0, 1, [ rev, wall, screw, dir ] );
//putPlate(1, 1, [ rev, rev, screw, dir ]);
//putPlate(2, 1, [ rev, rev, screw, screw ]);
