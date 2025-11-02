<?php
//==========================================================
// Run-length Decoder
// *This is a test implementation for data comparison.
// 
// https://github.com/emutyworks/Learning-GB-Programming/wiki/RunLengthEncodeDecode
//==========================================================

if(count($argv)<3){
  echo "Usage: php test_RunLengthDecoder.php <input filename(compression)> <output filename(bin)>\n";
  exit;
}
$input_file = $argv[1];
$output_file = $argv[2];

$in_array = str_split(bin2hex(file_get_contents($input_file)),2);

$val_past = array_shift($in_array);
$val_next = null;
$cnt = 0;
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
  $cnt = hexdec(array_shift($in_array));
  echo "|$cnt:";
  for($i=0; $i<($cnt-2); $i++){
    echo $val_next;
    $out_array[] = $val_next;
  }
  echo "\n";
  $val_past = array_shift($in_array);
}while(count($in_array)!=0);

//var_dump($out_array);
//var_dump(count($out_array));

$bin = null;
for($i=0; $i<count($out_array); $i++){
  $bin .= pack("c",hexdec($out_array[$i]));
}
file_put_contents($output_file, $bin);

/*
php test_RunLengthDecoder.php bg_tile0_compress.bin test_1024.bin

*/

?>