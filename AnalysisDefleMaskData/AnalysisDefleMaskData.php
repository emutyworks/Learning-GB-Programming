<?php
// Reference:
// - gzip圧縮されたデータの展開方法いろいろ(Various ways to expand gzip compressed data)
// https://qiita.com/mpyw/items/eb6ef5e444c2250361b5

if(count($argv)<3){
  echo "Usage: php AnalysisDefleMaskData.php <input filename(dmf)> <output filename(bin)>\n";
  exit;
}
// Example:
// php AnalysisDefleMaskData.php test.dmf test.bin

$inpit_file = $argv[1];
$output_file = $argv[2];

$in_array = str_split(bin2hex(zlib_decode(file_get_contents($inpit_file))),2);

$bin = null;
for($i=0; $i<count($in_array); $i++){
  $row = $in_array[$i];
  $bin .= pack("c",hexdec($row));
}
file_put_contents($output_file, $bin);

// View Data *I've only implemented it halfway.
// - Specs for DMF (DefleMask Module Format, for DefleMask v1.0.0 and above)
// https://www.deflemask.com/DMF_SPECS.txt
$str = null;
for($i=0; $i<16; $i++){
  $str .= array_shift($in_array);
}
echo "FORMAT FLAGS: ".hex2bin($str)."\n";
echo "File Version: ".array_shift($in_array)."\n";
echo "SYSTEM SET: ".array_shift($in_array)."\n";




?>