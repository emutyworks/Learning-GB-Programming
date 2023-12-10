<?php
/*
Convert from DMF format to data for assembly program.

Example:
php convDMF2Hex.php test.dmf
*/
include "init.php";
include "MusicalScaleTbl.php";

if(count($argv)<2){
	echo "Usage: php convDMF2Hex.php <input filename(dmf)>\n";
	exit;
}
$argv[2] = 'no_file.bin';
$mode_conv = 1;
include "AnalysisDefleMaskData.php";

//Basic data error checking
echo "Basic data error checking...\n";
$scale = count($musical_scale_tbl);
$check = $check_musical_scale_tbl;
foreach ($musical_scale_tbl as $key => $val) {
  unset($check[$key]);
}
if($scale>64){
  echo 'Please comment and keep $musical_scale_tbl(MusicalScaleTbl.php) below 64 scales: Currently '.$scale." scales\n";
  exit;
}else{
  echo '$musical_scale_tbl: '.$scale.' scales. (excluded: '.implode(",",array_values($check)).")\n";
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
    echo 'Please include '.$check_musical_scale_tbl[$key].' in $musical_scale_tbl.'."\n";
    exit;
  }

  if($key!='0000'){
    $hex[] = "$$volume,$".str_pad(dechex($note_hash[$key]),2,0,STR_PAD_LEFT);
    $s = $musical_scale_tbl[$key];
  }else{
    $hex[] = "$00,$00";
    $s = 'empty';
  }
  echo 'note+octave,volume:'.$key.",$volume ".$s."\n";
}

//exit;
$out  = 'SECTION "Sound Data Table",ROM0[$2100]'."\n";
$out .= "SoundDataTbl:\n";
for($i=0; $i<count($hex); $i++){
  $out .= " db ".$hex[$i]."\n";
}
$out .= " db \$FF\n";
file_put_contents('sound_data_tbl.inc', $out);

// Create musical_scale_tbl.inc
$out  = 'SECTION "Musical Scale Table",ROM0[$2000]'."\n";
$out .= "MusicalScaleTbl:\n";
$out .= implode("\n",array_values($musical_scale_tbl));
file_put_contents('musical_scale_tbl.inc', $out);

?>

