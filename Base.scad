include <Plate.scad>
include <stm32.scad>

module Supports(x, y, wallWidth, separation, size, height, angle, padding) {
    for (i = [0:x/2]) {
        for (j = [0:y-1]) {
            if (i && j && i % 2 == 0 && j % 2 == 0) {
                translate([wallWidth+padding+(size+separation)*i-2.5, wallWidth+padding+(size+separation)*j-2.5, 0])
                rotate([0, angle, 0])
                    cylinder(h=height, d=4, $fn=50);
            }
        }
    }
}

module Hole(wallSize, holeSize) {
    rotate([-90, 0, 0])
        cylinder(h=wallSize, d=holeSize, $fn=6);
}

module Holes(baseWidth, wallSize, width, length, holeSize) {
    holeSeparation = holeSize/2;
    holesCount = floor((width-(wallSize*2)+holeSeparation)/(holeSize+holeSeparation));
    echo(holesCount);
    holesWidth = (holesCount*holeSize)+((holesCount-1)*holeSeparation);
    holesOffset = wallSize+holeSize/2;
    for (i = [0:holesCount-1]) {
        translate([holesOffset+((holeSize+holeSeparation)*i), 0, (holeSize/2)+baseWidth])
            Hole(wallSize, holeSize);

        translate([holesOffset+((holeSize+holeSeparation)*i), length-wallSize, (holeSize/2)+baseWidth])
            Hole(wallSize, holeSize);
    }
}

module BaseWithCutout(width, length, height, separation, baseWidth, wallWidth, stm32Offset, usbOutOrientation, angle) {
    difference() {
        slopeHeight = (tan(angle)*width);
        union() {
            cube([width, length, height]);

            translate([0, 0, height]) {
                polyhedron(
                points = [[0, 0, 0], [0, length, 0], [width, length, 0], [width, 0, 0], [0, 0, slopeHeight], [0, length, slopeHeight]],
                faces = [[0, 1, 2, 3], [5, 4, 3, 2], [0, 4, 5, 1], [0, 3, 4], [5, 2, 1]]
                );
            }
        }

        translate([wallWidth, wallWidth, baseWidth])
        cube([width-(wallWidth*2), length-(wallWidth*2), height-baseWidth+slopeHeight]);

        // STM32 cutout
        if (usbOutOrientation == 2) {
            translate([0, wallWidth, baseWidth])
                cube([wallWidth, STM32Size.x, STM32Size.z + stm32Offset + 3]);
        } else {
            translate([0, wallWidth, baseWidth])
                cube([wallWidth, STM32Size.y, STM32Size.z + stm32Offset + 3]);
        }
    }
}

module STM32CaseBase(stm32Offset, wallWidth, baseWidth) {
    ceilingWidth = 3;
    cube([STM32Size.x+wallWidth, STM32Size.y+(wallWidth*2), STM32Size.z+stm32Offset+ceilingWidth+baseWidth]);
}

module STM32Case(stm32Offset, caseWallWidth, baseWidth, wallWidth, usbOutOrientation) {
    difference() {
        STM32CaseBase(stm32Offset, caseWallWidth, baseWidth);

        if (usbOutOrientation == 2) {
            translate([0, 0, baseWidth+2])
            cube([STM32Size.x+caseWallWidth, STM32Size.y+(caseWallWidth*1), STM32Size.z+stm32Offset+3+baseWidth]);
        }

        // Inside cutout
        translate([caseWallWidth, caseWallWidth, baseWidth])
            cube([STM32Size.x+wallWidth, STM32Size.y, STM32Size.z+stm32Offset]);

        // USB plug
        usbWidth = 13;
        usbHeight = 5;
        translate([caseWallWidth+STM32Size.x/2-usbWidth/2, usbOutOrientation == 1 || usbOutOrientation == 2 ? STM32Size.y+caseWallWidth : 0, baseWidth+0.5])
            cube([usbWidth, usbHeight, 8]);
    }
}

module Clip() {
    cube([5, 0.9, 4.1]);
    l=5;
    w=1;
    h=1;
    translate([0, 0.9, 3.1]) {
        polyhedron(
            points = [[0, 0, 0], [l, 0, 0], [l, w, 0], [0, w, 0], [0, 0, h], [l, 0, h]],
            faces = [[0, 1, 2, 3], [5, 4, 3, 2], [0, 4, 5, 1], [0, 3, 4], [5, 2, 1]]
        );
    }
}

module Base(x, y, heightOffset, baseWidth, wallWidth, size, separation, angle, holeSize, usbOutOrientation, withPlate = false) {
    assert(separation >= 5, "Separation of switches cannot be less than 5 otherwise keycaps won't go in");
    padding = 1;
    width = (wallWidth + (size+separation)*x) + padding*2;
    length = (wallWidth + (size+separation)*y)  + padding*2;
    holesSize = 7;
    height = holesSize+baseWidth+heightOffset; //(tan(angle)*width)
    stm32CaseWallSize = 4;
    stm32Offset = 4;

    difference() {
        union() {
            BaseWithCutout(width, length, height, separation, baseWidth, wallWidth, stm32Offset, usbOutOrientation, angle);
            Supports(x, y, wallWidth, separation, size, height, angle, padding);

            translate([0, 0, height]) {
                clipSeparationX = width/2.22;
                clipSeparationY = length/2.19;
                clipWidth = 5;
                for (i = [0:width/(clipWidth+clipSeparationX)-1]) {
                    translate([clipSeparationX/2+((clipWidth+clipSeparationX)*i), 0, 0]) Clip();
                }
                rotate([0, 0, -180]) {
                    for (i = [0:width/(clipWidth+clipSeparationX)-1]) {
                        translate([(clipSeparationX/2+((clipWidth+clipSeparationX)*i))-width, -length, 0]) Clip();
                    }
                }
                rotate([0, 0, 90]) {
                    for (i = [0:length/(clipWidth+clipSeparationY)-1]) {
                        translate([clipSeparationY/2+((clipWidth+clipSeparationY)*i), -width, 0]) Clip();
                    }
                }
                rotate([0, 0, -90]) {
                    for (i = [0:length/(clipWidth+clipSeparationY)-1]) {
                        translate([(clipSeparationY/2+((clipWidth+clipSeparationY)*i))-length, 0, 0]) Clip();
                    }
                }
            }


            if (usbOutOrientation == 2) {
                translate([STM32Size.y+(stm32CaseWallSize*2), wallWidth-stm32CaseWallSize, 0])
                rotate([0, 0, 90])
                    STM32Case(stm32Offset, stm32CaseWallSize, baseWidth, wallWidth, usbOutOrientation);
            } else {
                translate([-(STM32Size.x + stm32CaseWallSize), wallWidth - stm32CaseWallSize, 0])
                    STM32Case(stm32Offset, stm32CaseWallSize, baseWidth, wallWidth, usbOutOrientation);
            }
        }
        Holes(baseWidth, wallWidth, width, length, holeSize);

        // Clear underside
        translate([0, 0, -1])
            cube([width, length, 1]);
    }

    if (withPlate) {
        translate([0, 0, height])
            rotate([0, 0, 180])
                translate([-width+padding, -length+padding, 0])
                    rotate([0, - angle, 0])
                        Plate(rows, cols, wallWidth, switchSize, switchSeparation);
    }
}