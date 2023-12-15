<?php
/*
Analaysis DefleMask Module Format Data

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
  print "Usage: php AnalysisDefleMaskData.php <input filename(dmf)> <output filename(bin)>\n";
  exit;
}

$inpit_file = $argv[1];
$output_file = $argv[2];

$in_array = str_split(bin2hex(zlib_decode(file_get_contents($inpit_file))),2);

if(!isset($mode_conv)){
  $bin = null;
  for($i=0; $i<count($in_array); $i++){
    $row = $in_array[$i];
    $bin .= pack("c",hexdec($row));
  }
  file_put_contents($output_file, $bin);
}

// View Data
$channel_name = array('SQ1','SQ2','WAV','NOI');
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
$d['MODULE_INFORMATION']['TOTAL_ROWS_PER_PATTERN'] = hexdec(array_shift($in_array));
array_shift($in_array);
array_shift($in_array);
array_shift($in_array);
$d['MODULE_INFORMATION']['TOTAL_ROWS_IN_PATTERN_MATRIX'] = hexdec(array_shift($in_array));

$d['PATTERN_MATRIX_VALUES'] = array();
for($i=0; $i<$d['SYSTEM_TOTAL_CHANNELS']; $i++){
  $rows = array();
  for($j=0; $j<$d['MODULE_INFORMATION']['TOTAL_ROWS_IN_PATTERN_MATRIX']; $j++){
    $rows[$j] = array_shift($in_array).array_shift($in_array);
  }
  $d['PATTERN_MATRIX_VALUES'][$channel_name[$i]] = $rows;
}

$cnt = hexdec(array_shift($in_array));
for($i=0; $i<$cnt; $i++){
  $ccnt = hexdec(array_shift($in_array));
  $d['INSTRUMENTS_DATA'][$i]['InstrumentNameCharsCount'] = $ccnt;
  $d['INSTRUMENTS_DATA'][$i]['InstrumentNameChars'] = null;
  for($j=0; $j<$ccnt; $j++){
    $d['INSTRUMENTS_DATA'][$i]['InstrumentNameChars'] .= hex2bin(array_shift($in_array));
  }
  $d['INSTRUMENTS_DATA'][$i]['InstrumentMode'] = hexdec(array_shift($in_array));

  $loop = hexdec(array_shift($in_array));
  $d['INSTRUMENTS_DATA'][$i]['ARPEGGIO_MACRO']['ENVELOPE_SIZE'] = $loop;
  $value = array();
  for($j=0; $j<$loop; $j++){
    $value[$j] = hexdec(array_shift($in_array)) - 12;
    if($value[$j]>127){
      $value[$j] = -(256 - $value[$j]);
    }
    array_shift($in_array);
    array_shift($in_array);
    array_shift($in_array);
  }
  $d['INSTRUMENTS_DATA'][$i]['ARPEGGIO_MACRO']['ENVELOPE_VALUE'] = $value;
  if($loop>0){
    $pos = hexdec(array_shift($in_array));
    if($pos>127){
      $pos = -1;
    }
    $d['INSTRUMENTS_DATA'][$i]['ARPEGGIO_MACRO']['LOOP_POSITION'] = $pos;
  }
  $d['INSTRUMENTS_DATA'][$i]['ARPEGGIO_MACRO']['ARPEGGIO_MACRO_MODE'] = hexdec(array_shift($in_array));

  $loop = hexdec(array_shift($in_array));
  $d['INSTRUMENTS_DATA'][$i]['DUTY/NOISE_MACRO']['ENVELOPE_SIZE'] = $loop;
  $value = array();
  for($j=0; $j<$loop; $j++){
    $value[$j] = hexdec(array_shift($in_array));
    array_shift($in_array);
    array_shift($in_array);
    array_shift($in_array);
  }
  $d['INSTRUMENTS_DATA'][$i]['DUTY/NOISE_MACRO']['ENVELOPE_VALUE'] = $value;
  if($loop>0){
    $pos = hexdec(array_shift($in_array));
    if($pos>127){
      $pos = -1;
    }
    $d['INSTRUMENTS_DATA'][$i]['DUTY/NOISE_MACRO']['LOOP_POSITION'] = $pos;
  }

  $loop = hexdec(array_shift($in_array));
  $d['INSTRUMENTS_DATA'][$i]['WAVETABLE_MACRO']['ENVELOPE_SIZE'] = $loop;
  $value = array();
  for($j=0; $j<$loop; $j++){
    $value[$j] = hexdec(array_shift($in_array));
    array_shift($in_array);
    array_shift($in_array);
    array_shift($in_array);
  }
  $d['INSTRUMENTS_DATA'][$i]['WAVETABLE_MACRO']['ENVELOPE_VALUE'] = $value;
  if($loop>0){
    $pos = hexdec(array_shift($in_array));
    if($pos>127){
      $pos = -1;
    }
    $d['INSTRUMENTS_DATA'][$i]['WAVETABLE_MACRO']['LOOP_POSITION'] = $pos;
  }
  $d['INSTRUMENTS_DATA'][$i]['PER_SYSTEM_DATA']['EnvelopeVolume'] = hexdec(array_shift($in_array));
  $d['INSTRUMENTS_DATA'][$i]['PER_SYSTEM_DATA']['EnvelopeDirection'] = hexdec(array_shift($in_array));
  $d['INSTRUMENTS_DATA'][$i]['PER_SYSTEM_DATA']['EnvelopeLength'] = hexdec(array_shift($in_array));
  $d['INSTRUMENTS_DATA'][$i]['PER_SYSTEM_DATA']['SoundLength'] = hexdec(array_shift($in_array));
}

$cnt = hexdec(array_shift($in_array));
$d['WAVETABLES_DATA']['TOTAL_WAVETABLES'] = $cnt;

for($i=0; $i<$cnt; $i++){
  $loop = hexdec(array_shift($in_array));
  $d['WAVETABLES_DATA'][$i]['WAVETABLE_SIZE'] = $loop;
  array_shift($in_array);
  array_shift($in_array);
  array_shift($in_array);
  $value = array();
  for($j=0; $j<$loop; $j++){
    $value[$j] = hexdec(array_shift($in_array));
    array_shift($in_array);
    array_shift($in_array);
    array_shift($in_array);
  }
  $d['WAVETABLES_DATA'][$i]['WavetableData'] = $value;
}

$cnt = $d['SYSTEM_TOTAL_CHANNELS'];
for($i=0; $i<$cnt; $i++){
  $d['PATTERNS_DATA'][$channel_name[$i]]['CHANNEL_EFFECTS_COLUMNS_COUNT'] = hexdec(array_shift($in_array));
  for($j=0; $j<$d['MODULE_INFORMATION']['TOTAL_ROWS_IN_PATTERN_MATRIX']; $j++){
    $value = array();
    for($k=0; $k<$d['MODULE_INFORMATION']['TOTAL_ROWS_PER_PATTERN']; $k++){
      $value[$k]['NoteForThisIndex'] = array_shift($in_array).array_shift($in_array);
      $value[$k]['OctaveForThisIndex'] = array_shift($in_array).array_shift($in_array);
      $value[$k]['VolumeForThisIndex'] = array_shift($in_array).array_shift($in_array);

      $effect = array();
      for($e=0; $e<$d['PATTERNS_DATA'][$channel_name[$i]]['CHANNEL_EFFECTS_COLUMNS_COUNT']; $e++){
        $effect[$e]['EffectCodeForThisIndex'] = array_shift($in_array).array_shift($in_array);
        $effect[$e]['EffectValueForThisIndex'] = array_shift($in_array).array_shift($in_array);
      }
      $value[$k]['Effect'] = $effect;
      $value[$k]['InstrumentForThisIndex'] = array_shift($in_array).array_shift($in_array);
    }
    $d['PATTERNS_DATA'][$channel_name[$i]][$j]['PATTERN_MATRIX'] = $value;
  }
}

if(!isset($mode_conv)){
  print "*This tool only targets SYSTEM_GAMEBOY (SYSTEM_SET = 0x04)\n";
  print_r($d);
}

?>