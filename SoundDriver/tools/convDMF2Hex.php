<?php
/*
Convert from DMF format to data for assembly program.

Example:
php convDMF2Hex.php test.dmf test.inc
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
$hex = array();
for($i=0; $i<count($list); $i++){
  $note = substr($list[$i]['NoteForThisIndex'],0,2);
  $octave = substr($list[$i]['OctaveForThisIndex'],0,2);

  if($note=='0c'){
    $note = '00';
    $octave = sprintf("%02d",((int)$octave)+1);
  }
  $key = $note.$octave;
  $hex[] = "$".str_pad(dechex($note_hash[$key]),2,0,STR_PAD_LEFT); 

  //debug
  echo 'note+octave:'.$key.' '.$musical_scale_tbl[$key]."\n";
}

$out  = 'SECTION "Sound Data Table",ROM0[$2100]'."\n";
$out .= "SoundDataTbl:\n";
$out .= " db ".implode(",",$hex).",\$FF\n";
file_put_contents('sound_data_tbl.inc', $out);

// Create musical_scale_tbl.inc
$out  = 'SECTION "Musical Scale Table",ROM0[$2000]'."\n";
$out .= "MusicalScaleTbl:\n";
$out .= implode("\n",array_values($musical_scale_tbl));
file_put_contents('musical_scale_tbl.inc', $out);

/*
%xx543210 - Scale 0-63
*/

?>
