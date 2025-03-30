<?php
//==========================================================
// Create HBlank Road X Position Table
// Create Rival Car X Position Table
//
// https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
//==========================================================

$scrollBaseX = 8*6;
$rCarPosX = 8*9;

$y0 = 0;
$y1 = 8*8;

$int_x = 9;
$x0 = 8*6;
$x1_list = [      //L 1-7|8|9-15 R
  0,              //-
  $x0 - $int_x*7, //1
  $x0 - $int_x*6, //2
  $x0 - $int_x*5, //3
  $x0 - $int_x*4, //4
  $x0 - $int_x*3, //5
  $x0 - $int_x*2, //6
  $x0 - $int_x*1, //7
  0,              //8
  $x0 + $int_x*1, //9
  $x0 + $int_x*2, //10
  $x0 + $int_x*3, //11
  $x0 + $int_x*4, //12
  $x0 + $int_x*5, //13
  $x0 + $int_x*6, //14
  $x0 + $int_x*7  //15
];

echo "SECTION \"HBlank Road X Position Table\",ROM0[$4000]\n";
echo "RoadXPosTbl:\n";
for($i=0; $i<=15; $i++){
  if($x1_list[$i]==0){
    $hex = [];
    for($j=0; $j<64; $j++){
      $hex[] = sprintf("$%02x", $scrollBaseX);
    }
    printf("  db %s\n",implode(",", $hex));
  }else{
    $x1 = $x1_list[$i];
    $out = calcRoadLine($y0,$x0,$y1,$x1);
    $hex = [];
    foreach($out as $key=>$val){
      if($val < 0){
        $hex[] = sprintf("$%02x", 256 + $val);
      }else{
        $hex[] = sprintf("$%02x", $val);
      }
    }
    printf("  db %s\n",implode(",", $hex));
  }
}

echo "\nSECTION \"Rival Car X Position Table\",ROM0[$4400]\n";
echo "RCarXPosTbl:\n";

$int_x = 11;
$x0 = 8*9;
$x1_list = [      //L 1-7|8|9-15 R
  0,              //-
  $x0 + $int_x*7, //1
  $x0 + $int_x*6, //2
  $x0 + $int_x*5, //3
  $x0 + $int_x*4, //4
  $x0 + $int_x*3, //5
  $x0 + $int_x*2, //6
  $x0 + $int_x*1, //7
  0,              //8
  $x0 - $int_x*1, //9
  $x0 - $int_x*2, //10
  $x0 - $int_x*3, //11
  $x0 - $int_x*4, //12
  $x0 - $int_x*5, //13
  $x0 - $int_x*6, //14
  $x0 - $int_x*7  //15
];

for($i=0; $i<=15; $i++){
  if($x1_list[$i]==0){
    $hex = [];
    for($j=0; $j<64; $j++){
      $hex[] = sprintf("$%02x", $rCarPosX);
    }
    printf("  db %s\n",implode(",", $hex));
  }else{
    $x1 = $x1_list[$i];
    $out = calcRoadLine($y0,$x0,$y1,$x1);
    $hex = [];
    foreach($out as $key=>$val){
      if($val < 0){
        $hex[] = sprintf("$%02x", 256 + $val);
      }else{
        $hex[] = sprintf("$%02x", $val);
      }
    }
    printf("  db %s\n",implode(",", $hex));
  }
}

function calcRoadLine($y0,$x0,$y1,$x1){
  $road_x = [];

  if (($x0>=$x1 && $y0>=$y1) || ($y0>=$y1)){
    list($y0,$x0,$y1,$x1) = array($y1,$x1,$y0,$x0);
  }

  $dy = $y1 - $y0;

  if($x0<=$x1 && $y0<=$y1){
    $dx = $x1 - $x0;
    $ax = 1;
  }else{
    $dx = $x0 - $x1;
    $ax = -1;
  }

  $dy2 = $dy *2;
  $dx2 = $dx *2;

  if($dx > $dy){
    $d = -$dx;
    $y = $y0;
    if($ax==1){
      for($x=$x0; $x<$x1; $x+=$ax){
        if($d > 0){
          $y += 1;
          $d -= $dx2;
        }
        $d += $dy2;
        $road_x[ $y ] = $x;
      }
    }else{
      for($x=$x0; $x>$x1; $x+=$ax){
        if($d > 0){
          $y += 1;
          $d -= $dx2;
        }
        $d += $dy2;
        $road_x[ $y ] = $x;
      }
    }

  }else{
    $d = -$dy;
    $x = $x0;
    for($y=$y0; $y<$y1; $y++){
      if($d > 0){
        $x += $ax;
        $d -= $dy2;
      }
      $d += $dx2;
      $road_x[ $y ] = $x;
    }
  }
  return $road_x;
}

?>
