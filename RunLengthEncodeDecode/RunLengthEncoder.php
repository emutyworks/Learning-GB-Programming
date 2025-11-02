<?php
//==========================================================
// Run-length Encoder
//
// https://github.com/emutyworks/Learning-GB-Programming/wiki/RunLengthEncodeDecode
//==========================================================

if(count($argv)<3){
  echo "Usage: php RunLengthEncoder.php <input filename(bin)> <output filename(compression)>\n";
  exit;
}
$input_file = $argv[1];
$output_file = $argv[2];

$in_array = str_split(bin2hex(file_get_contents($input_file)),2);

$val_past = array_shift($in_array);
$val_next = null;
$out_array = array();
do{
  echo $val_past;
  $out_array[] = $val_past;
  $val_next = array_shift($in_array);
  if($val_past!=$val_next){
    $val_past = $val_next;
    continue;
  }
  echo $val_next;
  $out_array[] = $val_next;
  $cnt = 2;
  while(1){
    $val_past = array_shift($in_array);
    if($val_next!=$val_past || $cnt==255){
      echo ":$cnt\n";
      $out_array[] = dechex($cnt);
      break;
    }else{
      echo $val_past;
    }
    $cnt++;
  }
}while(count($in_array)!=0);

echo "\n----\ntotal: ".count($out_array)." bytes\n";

$bin = null;
for($i=0; $i<count($out_array); $i++){
  $bin .= pack("c",hexdec($out_array[$i]));
}
file_put_contents($output_file, $bin);

/*
php RunLengthEncoder.php bg_tile0_1024.bin bg_tile0_compress.bin

*/

?>