<?php
/*
Analaysis DefleMask Module Format Data *I've only implemented it halfway.

This tool only targets SYSTEM_GAMEBOY (SYSTEM_SET = 0x04)

Reference:
- Specs for DMF (DefleMask Module Format, for DefleMask v1.0.0 and above)
https://www.deflemask.com/DMF_SPECS.txt
- gzip圧縮されたデータの展開方法いろいろ(Various ways to expand gzip compressed data)
https://qiita.com/mpyw/items/eb6ef5e444c2250361b5

Example:
php AnalysisDefleMaskData.php test.dmf test.bin
*/

if(count($argv)<3){
  echo "Usage: php AnalysisDefleMaskData.php <input filename(dmf)> <output filename(bin)>\n";
  exit;
}

$inpit_file = $argv[1];
$output_file = $argv[2];

$in_array = str_split(bin2hex(zlib_decode(file_get_contents($inpit_file))),2);

$bin = null;
for($i=0; $i<count($in_array); $i++){
  $row = $in_array[$i];
  $bin .= pack("c",hexdec($row));
}
file_put_contents($output_file, $bin);

// View Data
$str = null;
for($i=0; $i<16; $i++){
  $str .= array_shift($in_array);
}
$d = array();
$d['FORMAT_FLAGS'] = hex2bin($str);
$d['File_Version'] = hexdec(array_shift($in_array));
$d['SYSTEM_SET'] = array_shift($in_array);
$d['SYSTEM_TOTAL_CHANNELS'] = 4;

$cnt = hexdec(array_shift($in_array));
$d['VISUAL_INFORMATION']['SongNameCharsCount'] = $cnt;
$d['VISUAL_INFORMATION']['SongNameChars'] = null;
for($i=0; $i<$cnt; $i++){
  $d['VISUAL_INFORMATION']['SongNameChars'] .= hex2bin(array_shift($in_array));
}
$cnt = hexdec(array_shift($in_array));
$d['VISUAL_INFORMATION']['SongAuthorCharsCount'] = $cnt;
$d['VISUAL_INFORMATION']['SongAuthorChars'] = null;
for($i=0; $i<$cnt; $i++){
  $d['VISUAL_INFORMATION']['SongAuthorChars'] .= hex2bin(array_shift($in_array));
}
$d['VISUAL_INFORMATION']['HighlightAInPatterns'] = hexdec(array_shift($in_array));
$d['VISUAL_INFORMATION']['HighlightBInPatterns'] = hexdec(array_shift($in_array));

$d['MODULE_INFORMATION']['TimeBase'] = hexdec(array_shift($in_array));
$d['MODULE_INFORMATION']['TickTime1'] = hexdec(array_shift($in_array));
$d['MODULE_INFORMATION']['TickTime2'] = hexdec(array_shift($in_array));
$d['MODULE_INFORMATION']['FramesMode'] = hexdec(array_shift($in_array));
$d['MODULE_INFORMATION']['UsingCustomHZ'] = hexdec(array_shift($in_array));
$d['MODULE_INFORMATION']['CustomHZvalue1'] = hexdec(array_shift($in_array));
$d['MODULE_INFORMATION']['CustomHZvalue2'] = hexdec(array_shift($in_array));
$d['MODULE_INFORMATION']['CustomHZvalue3'] = hexdec(array_shift($in_array));
$num = 0;
for($i=0; $i<4; $i++){
  $num .= array_shift($in_array);
}
$d['MODULE_INFORMATION']['TOTAL_ROWS_PER_PATTERN'] = hexdec($num);
$d['MODULE_INFORMATION']['TOTAL_ROWS_IN_PATTERN_MATRIX'] = hexdec(array_shift($in_array));

echo "*This tool only targets SYSTEM_GAMEBOY (SYSTEM_SET = 0x04)\n";
print_r($d);





?>