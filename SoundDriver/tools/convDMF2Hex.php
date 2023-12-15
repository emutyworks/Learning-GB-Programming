<?php
/*
Convert from DMF format to data for assembly program.

Example:
php convDMF2Hex.php test.dmf
*/
include "init.php";
include "MusicalScaleTbl.php";

if(count($argv)<2){
  print "Usage: php convDMF2Hex.php <input filename(dmf)>\n";
  exit;
}
$argv[2] = 'no_file.bin';
$mode_conv = 1;
include "AnalysisDefleMaskData.php";

//Basic data error checking
print "Basic data error checking...\n";
$scale = count($musical_scale_tbl);
$check = $check_musical_scale_tbl;
foreach ($musical_scale_tbl as $key => $val) {
  unset($check[$key]);
}
if($scale>64){
  printf("Please comment and keep \$musical_scale_tbl(MusicalScaleTbl.php) below 64 scales: Currently %s scales\n",$scale);
  exit;
}else{
  printf("\$musical_scale_tbl: %s scales. (excluded: %s)\n",$scale,implode(",",array_values($check)));
}

// Create sound_data_tbl.inc
$list = array_keys($musical_scale_tbl);
$note_hash = array();
for($i=0; $i<count($list); $i++){
  $note_hash[ $list[$i] ] = $i;
}

$list = $d['PATTERNS_DATA']['SQ1'][0]['PATTERN_MATRIX'];
//var_dump($list); exit;

$hex = array();
for($i=0; $i<count($list); $i++){
  $note = substr($list[$i]['NoteForThisIndex'],0,2);
  $octave = substr($list[$i]['OctaveForThisIndex'],0,2);
  $volume = substr($list[$i]['VolumeForThisIndex'],1,1).'0';

  if($note=='0c'){
    $note = '00';
    $octave = sprintf("%02d",((int)$octave)+1);
  }

  $key = $note.$octave;
  if(!isset($musical_scale_tbl[$key]) && $key!='0000'){
    printf("Please include %s in \$musical_scale_tbl.\n",$check_musical_scale_tbl[$key]);
    exit;
  }

  if($key!='0000'){
    $hex[] = sprintf("$%s,$%s",$volume,str_pad(dechex($note_hash[$key]),2,0,STR_PAD_LEFT));
    $s = $musical_scale_tbl[$key][1];
  }else{
    $hex[] = "$00,$00";
    $s = 'empty';
  }
  printf("note+octave,volume:%s,%s %s\n",$key,$volume,$s);
}

//exit;
$rows = "SoundDataTbl:\n";
for($i=0; $i<count($hex); $i++){
  $rows .= "  db ".$hex[$i]."\n";
}
$rows .= "  db \$FF\n";
file_put_contents('sound_data_tbl.inc', $rows);

// Create musical_scale_tbl.inc
$val = reset($musical_scale_tbl);
$hi_old = $val[0];
$cnt = 0;
$rows = array();
$row = array();
foreach ($musical_scale_tbl as $key => $val) {
  $hi_now = $val[0];
  if($hi_now==$hi_old && $cnt<31){
    $cnt++;
    $row[] = $val[1];
  }else{
    array_unshift($row,sprintf("  db $%s ;%s*32+%s",str_pad(dechex($hi_old*32+$cnt),2,0,STR_PAD_LEFT),$hi_old,$cnt));
    $rows = array_merge($rows,$row);
    $cnt = 1;
    $row = array();
    $row[] = $val[1];
    $hi_old = $hi_now;
  }
}
array_unshift($row,sprintf("  db $%s ;%s*32+%s",str_pad(dechex($hi_old*32+$cnt),2,0,STR_PAD_LEFT),$hi_old,$cnt));
$rows = array_merge($rows,$row);
$out  = sprintf("MusicalScaleTbl: ; total %s bytes (-%s bytes)\n",count($rows),128-count($rows));
$out .= implode("\n",$rows);
file_put_contents('musical_scale_tbl.inc', $out);

?>

