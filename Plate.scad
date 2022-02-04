module SwitchHoles(x, y, wallWidth, switchSize, separation, padding = 0) {
    for (i = [0:x-1]) {
        for (j = [0:y-1]) {
            translate([(5-padding/2)+(switchSize+separation)*i, (5-padding/2)+(switchSize+separation)*j, 0])
                cube([switchSize+padding, switchSize+padding, 2]);
        }
    }
}

module Plate(x, y, wallWidth, switchSize, switchSeparation) {
    width = wallWidth+(switchSize+switchSeparation)*x;
    length = wallWidth+(switchSize+switchSeparation)*y;
    difference() {
        cube([width, length, 1.5]);
        SwitchHoles(x, y, wallWidth, switchSize, switchSeparation);
    }
    translate([0,0,1.5])
    difference() {
        cube([width, length, 1.5]);
        SwitchHoles(x, y, wallWidth, switchSize, switchSeparation, 1.6);
    }
}

//Plate(5, 6, 5, 14, 5);