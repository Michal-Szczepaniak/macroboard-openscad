include <Base.scad>

rows = 5;
cols = 6;
baseWidth = 1;
wallWidth = 5;
switchSize = 14;
switchSeparation = 5;
angle = 0;
height = 5;
holeSize = 8;
usbOutOrientation = 2; // 0 = left, 1 = right, 2 = top

Base(rows, cols, height, baseWidth, wallWidth, switchSize, switchSeparation, angle, holeSize, usbOutOrientation, false);
