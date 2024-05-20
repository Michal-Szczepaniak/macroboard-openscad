include <Plate.scad>
include <stm32.scad>
include <usbc.scad>

module Supports(x, y, wallWidth, separation, size, height, angle, padding, baseWidth) {
    width = (wallWidth + (size+separation)*x);
    for (i = [0:x/2]) {
        for (j = [0:y-1]) {
            if (i && j && i % 2 == 0 && j % 2 == 0) {
                d = 5;
                sx = d/2+(size+separation)*i;
                sy = wallWidth+padding+(size+separation)*j-(d/2);
                sz = height + sin(angle)*(width);
                sh = ((sin(angle)*sx)+(height+baseWidth))/cos(angle);
                ox = (d/2)-(cos(angle)*(d/2));
                oz = sin(angle)*(d/2);
                rotate([0, -180, 0])
                translate([-width-padding, 0, -height])
                rotate([0, angle, 0])
                translate([sx, sy, 0])
                color("red") cylinder(h=sh, d=5, $fn=50);
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
    stm32WidthOffset = 4;
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

            if (usbOutOrientation == 2) {
                w = USBCSize.y;
                l = wallWidth+STM32Size.x+stm32WidthOffset;
                /*translate([-w, 0, 0])
                    cube([w, l, baseWidth*2+STM32Size.z+stm32Offset]);*/

                translate([0, 0, height])
                cube([width, wallWidth+STM32Size.x, 3]);

            }
        }
        difference() {
            translate([wallWidth, wallWidth, baseWidth])
                cube([width - (wallWidth * 2), length - (wallWidth * 2), height - baseWidth + slopeHeight]);

            translate([STM32Size.y+wallWidth+1, 0, 0])
                cube([width-STM32Size.y+1, wallWidth+(STM32Size.x), height]);
        }

        // STM32 cutout
        if (usbOutOrientation == 2) {
            usbWidth = 13;
            usbHeight = 8;

            translate([0, wallWidth+(STM32Size.x+stm32WidthOffset)/2-usbWidth/2-1, baseWidth+0.5])
                color("green") cube([wallWidth, usbWidth+1, usbHeight]);

/*            rotate([0, 0, -90])
            translate([-STM32Size.x-wallWidth, -USBCSize.y+wallWidth/2, baseWidth])
            color("blue") cube([STM32Size.x, STM32Size.y, STM32Size.z+stm32Offset]);

            translate([-USBCSize.y, (wallWidth+STM32Size.x+stm32WidthOffset)/2-usbWidth/2, baseWidth+0.5])
            color("green") cube([wallWidth/2, usbWidth, usbHeight]);

            stm32PolyhedronCutoutWidth = wallWidth/2;
            stm32PolyhedronCutoutLength = STM32Size.y;
            translate([-USBCSize.y+wallWidth/2, wallWidth/2, baseWidth+STM32Size.z+stm32Offset-wallWidth/2]) color("yellow") polyhedron(
            points = [
                    [0, 0, 0],
                    [stm32PolyhedronCutoutLength, 0, 0],
                    [stm32PolyhedronCutoutLength, stm32PolyhedronCutoutWidth, 0],
                    [0, stm32PolyhedronCutoutWidth, 0],
                    [0, stm32PolyhedronCutoutWidth, stm32PolyhedronCutoutWidth],
                    [stm32PolyhedronCutoutLength, stm32PolyhedronCutoutWidth, stm32PolyhedronCutoutWidth]
                ],
            faces = [[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
            );

            translate([-USBCSize.y+wallWidth/2, wallWidth/2, baseWidth])
            cube([stm32PolyhedronCutoutLength, stm32PolyhedronCutoutWidth, STM32Size.z+stm32Offset-wallWidth/2]);*/
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
            translate([0, 0, baseWidth+4])
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
    thicc = 0.9;
    clearance = 0.1;
    translate([0, -clearance+(1-thicc), 0])
    cube([5, thicc, 4]);
    l=5;
    w=0.7;
    h=0.7;
    translate([0, 1-clearance, 3.3]) {
        polyhedron(
            points = [[0, 0, 0], [l, 0, 0], [l, w, 0], [0, w, 0], [0, 0, h], [l, 0, h]],
            faces = [[0, 1, 2, 3], [5, 4, 3, 2], [0, 4, 5, 1], [0, 3, 4], [5, 2, 1]]
        );
    }
}

module Base(x, y, heightOffset, baseWidth, wallWidth, size, separation, angle, holeSize, usbOutOrientation, padding, clips = false, withPlate = false) {
    assert(separation >= 5, "Separation of switches cannot be less than 5 otherwise keycaps won't go in");
    width = (wallWidth + (size+separation)*x) + padding*2;
    length = (wallWidth + (size+separation)*y)  + padding*2 + ((usbOutOrientation == 2) ? wallWidth+STM32Size.x : 0);
    holesSize = 7;
    height = holesSize+baseWidth+heightOffset; //(tan(angle)*width)
    stm32CaseWallSize = 4;
    stm32Offset = 4;

    difference() {
        union() {
            BaseWithCutout(width, length, height, separation, baseWidth, wallWidth, stm32Offset, usbOutOrientation, angle);
            translate([0, (usbOutOrientation == 2) ? wallWidth*2 : 0, 0]) Supports(x, y, wallWidth, separation, size, height, angle, padding, baseWidth);

            if (clips) {
                translate([0, 0, height]) {
                    clipSeparationX = width / 2.22;
                    clipSeparationY = length / 2.19;
                    clipWidth = 5;
                    for (i = [0:width / (clipWidth + clipSeparationX) - 1]) {
                        x = clipSeparationX / 2 + ((clipWidth + clipSeparationX) * i);
                        translate([x, 0, (tan(angle) * (width - x))])
                            rotate([0, angle, 0])
                                Clip();
                    }
                    rotate([0, 0, - 180]) {
                        for (i = [0:width / (clipWidth + clipSeparationX) - 1]) {
                            x = (clipSeparationX / 2 + ((clipWidth + clipSeparationX) * i)) - width;
                            translate([x, - length, (tan(angle) * (width + x))])
                                rotate([0, - angle, 0])
                                    Clip();
                        }
                    }
                    rotate([0, 0, 90]) {
                        for (i = [0:length / (clipWidth + clipSeparationY) - 1]) {
                            translate([clipSeparationY / 2 + ((clipWidth + clipSeparationY) * i), - width, 0])
                                rotate([angle, 0, 0])
                                    Clip();
                        }
                    }
                    rotate([0, 0, - 90]) {
                        angleOffset = width - (width / cos(angle));
                        for (i = [0:length / (clipWidth + clipSeparationY) - 1]) {
                            translate([(clipSeparationY / 2 + ((clipWidth + clipSeparationY) * i)) - length, 0, (tan(
                            angle) * width)])
                                rotate([- angle, 0, 0])
                                    translate([0, - angleOffset, 0])
                                        Clip();
                        }
                    }
                }
            }

            if (usbOutOrientation == 2) {
//                translate([STM32Size.y-7.5+wallWidth/2, 0, baseWidth])
//                    cube([2, STM32Size.x, 3]);
            } else {
                translate([-(STM32Size.x + stm32CaseWallSize), wallWidth - stm32CaseWallSize, 0])
                    STM32Case(stm32Offset, stm32CaseWallSize, baseWidth, wallWidth, usbOutOrientation);
            }
        }
//        Holes(baseWidth, wallWidth, width, length, holeSize);

        // Clear underside
        translate([0, 0, -10])
            cube([width, length, 10]);
    }

    echo(wallWidth);
    echo(switchSize);
    echo(switchSeparation);
    if (withPlate) {
        translate([0, 0, height])
            rotate([0, 0, 180])
                translate([-width+padding, -length+padding, 0])
                    rotate([0, - angle, 0])
                        Plate(rows, cols, wallWidth, switchSize, switchSeparation);
    }
}