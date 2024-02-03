<?php
//==========================================================
// Convert map_editor.txt to bg_tile0.inc/bg_tile0.inc
//
// https://github.com/emutyworks/GBCMapEditor/wiki
//==========================================================

$option = isset($argv[1])?$argv[1]:'';

$in_file = file_get_contents(sprintf("map_editor%s.txt",$option));
$in_rows = explode("\n",$in_file);

$out = array();
$out_flg = false;
for($i=0; $i<count($in_rows); $i++){
  if(strpos($in_rows[$i],"ShowGrid")!=false){
    $out_flg = true;
  }elseif($out_flg){
    if(strpos($in_rows[$i],"AttributesTbl")!=false){
      file_put_contents(sprintf("bg_tile%s0.inc",$option), $out);
      break;
    }
    if($in_rows[$i]!=""){
      $out[] = $in_rows[$i]."\n";
    }
  }
}

$out = array();
for($j=($i+1); $j<count($in_rows); $j++){
  if($in_rows[$i]!=""){
    $out[] = $in_rows[$j]."\n";
  }
}
file_put_contents(sprintf("bg_tile%s1.inc",$option), $out);
?>