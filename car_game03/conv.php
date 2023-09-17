<?php
//==========================================================
// Convert map_editor.txt to bg_tile0.inc/bg_tile0.inc
//
// https://github.com/emutyworks/GBCMapEditor/wiki
//==========================================================
$inpit_file = "map_editor.txt";
$output_file0 = "bg_tile0.inc"; // Tile Indexes
$output_file1 = "bg_tile1.inc"; // BG Map Attributes

$in_file = file_get_contents($inpit_file);
$in_rows = explode("\n",$in_file);

$out = array();
$out_flg = false;
for($i=0; $i<count($in_rows); $i++){
  if(mb_strpos($in_rows[$i],"ShowGrid")!=false){
    $out_flg = true;
  }elseif($out_flg){
    if(mb_strpos($in_rows[$i],"AttributesTbl")!=false){
      file_put_contents($output_file0, $out);
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
file_put_contents($output_file1, $out);
?>