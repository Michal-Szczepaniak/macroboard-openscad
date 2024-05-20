 include <Base.scad>

rows = 5;
cols = 14;
baseWidth = 1;
wallWidth = 5;
switchSize = 14;
switchSeparation = 5;
padding = 0;
angle = 0;
height = 4;
holeSize = 9;
usbOutOrientation = 2; // 0 = left, 1 = right, 2 = top

/*if (user == 0) {
    angle = 0;
    height = 4;
    holeSize = 8;
    usbOutOrientation = 2;
} else if (user == 1) {
    angle = 5;
    height = 4;
    holeSize = 8;
    usbOutOrientation = 0;
}*/

Base(rows, cols, height, baseWidth, wallWidth, switchSize, switchSeparation, angle, holeSize, usbOutOrientation, padding, false, true);

//Plate(rows, cols, wallWidth, switchSize, switchSeparation);