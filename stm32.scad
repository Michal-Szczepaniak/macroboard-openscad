STM32Size = [20.7, 54, 5];

module STM32Cube() {
    cube([STM32Size.x, STM32Size.y, STM32Size.z]);
}
module STM32() {
    cube([STM32Size.x, STM32Size.y, 2]);
    translate([5.85, 0, 2]) cube([9, 7.5, 3]);
}