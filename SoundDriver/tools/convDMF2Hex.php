<?php
/*
Convert from DMF format to data for assembly program.

Example:
php convDMF2Hex.php test.dmf
*/
include 'init.php';

if(count($argv)<2){
  print "Usage: php convDMF2Hex.php <input filename(dmf)>\n";
  exit;
}
$argv[2] = 'no_file.bin';
$mode_conv = 1;
include 'AnalysisDefleMaskData.php';

// Create sound_data_tbl.inc
$list = $d['PATTERNS_DATA']['SQ1'][0]['PATTERN_MATRIX'];
//var_dump($list); exit;

$hex = array();
$octave_old = null;
$empty_cnt = 0;
for($i=0; $i<count($list); $i++){
  $note = substr($list[$i]['NoteForThisIndex'],1,1);
  $octave = (int)substr($list[$i]['OctaveForThisIndex'],1,1);
  $volume = substr($list[$i]['VolumeForThisIndex'],1,1);

  if($note=='c'){
    $note = '0';
    $octave = $octave + 1;
  }
  if($octave>=2 && $octave<=7 && $octave_old!=$octave){
    $hex[] = sprintf("D%s ;change to %s octaves",$octave-2,$octave);
    $octave_old = $octave;
  }
  $row = sprintf("%s%s ; volume,note",$volume,$note);

  if($note.$octave=='00' && $empty_cnt<15){
    $empty_cnt++;
  }else{
    if($empty_cnt!=0){
      $hex[] = sprintf("C%s ;empty count",dechex($empty_cnt));
      $hex[] = $row;
      $empty_cnt = 0;
    }else{
      $hex[] = $row;
    }
  }
}
if($empty_cnt!=0){
  $hex[] = sprintf("C%s ; empty count",dechex($empty_cnt));
}

for($i=0; $i<count($hex); $i++){
  printf("$%s\n",$hex[$i]);
}
printf("- Total %s bytes of data, Uses %s bytes of WRAM\n",count($hex),count($list)*2+1);

$rows = null;
for($i=0; $i<count($hex); $i++){
  $rows .= "  db $".$hex[$i]."\n";
}
$rows .= "  db \$FF\n";
$tpl = file_get_contents(dirname(__FILE__).'/templates/sound_data_tbl.inc');
$out = str_replace('{{TOTAL_DATA}}',count($hex),$tpl);
$out = str_replace('{{USE_WRAM}}',count($list)*2+1,$out);
$out = str_replace('{{DATA}}',$rows,$out);
file_put_contents(FN_SOUND_DATA_TBL,$out);

?>

