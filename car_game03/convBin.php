<?php
//==========================================================
// Convert map_editor.txt to bg_tile0.bin/bg_tile0.bin
//
// https://github.com/emutyworks/GBCMapEditor/wiki
//==========================================================
$inpit_file = "map_editor.txt";
$output_file0 = "bg_tile0"; // Tile Indexes
$output_file1 = "bg_tile1"; // BG Map Attributes

$in_file = file_get_contents($inpit_file);
$in_rows = explode("\n",$in_file);

$out = null;
$out_flg = false;
for($i=0; $i<count($in_rows); $i++){
  if(mb_strpos($in_rows[$i],"ShowGrid")!=false){
    $out_flg = true;
  }elseif($out_flg){
    if(mb_strpos($in_rows[$i],"AttributesTbl")!=false){
      $out_array = explode(",",$out);
      $bin = null;
      for($j=0; $j<count($out_array)-1; $j++){
        $bin .= pack("c",hexdec($out_array[$j]));
      }
      file_put_contents($output_file0.".bin", $bin);
      break;
    }
    if($in_rows[$i]!=""){
      $out .= substr(trim($in_rows[$i].","),3);
    }
  }
}

$out = null;
for($j=($i+1); $j<count($in_rows); $j++){
  if($in_rows[$j]!=""){
    $out .= substr(trim($in_rows[$j].","),3);
  }
}

$out_array = explode(",",$out);
$bin = null;
for($j=0; $j<count($out_array)-1; $j++){
  $bin .= pack("c",hexdec($out_array[$j]));
}
file_put_contents($output_file1.".bin", $bin);

$com = sprintf("php RunLengthEncoder.php %s.bin %s_comp.bin",$output_file0,$output_file0);
exec($com, $output, $retval);
$com = sprintf("php RunLengthEncoder.php %s.bin %s_comp.bin",$output_file1,$output_file1);
exec($com, $output, $retval);

$com = "php RunLengthEncoder.php sprites.bin sprites_comp.bin";
exec($com, $output, $retval);
$com = "php RunLengthEncoder.php tiles.bin tiles_comp.bin";
exec($com, $output, $retval);


?>