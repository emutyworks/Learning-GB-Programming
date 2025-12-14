<?php
//====================================================================================
// Game Boy Data Compression Encoder:
// An encoder that compresses Game Boy binary data (like run-length encoding)
//
//
// RunLengthEncodeDecode
// https://github.com/emutyworks/Learning-GB-Programming/wiki/RunLengthEncodeDecode
// PackBits
// https://en.wikipedia.org/wiki/PackBits
//====================================================================================
//
// Compression File Format:
// +-----------------------------------------------------------+
// | [Tags data] 5 bytes                                       |
// |                                                           |
// | - A table of unused values will be stored.                |
// | - When values in $ff - $f0 range appear in the ROM data,  |
// | they will be temporarily replaced with unused values.     |
// |                                                           |
// |   $ff: Source dictionary data 1                           |
// |   $fe: Duplicate using dictionary data 1                  |
// |   $fd: Source dictionary data 2                           |
// |   $fc: Duplicate using dictionary data 2                  |
// |   $fb-$f0: Replicate successive values                    |
// |                                                           |
// +-----------------------------------------------------------+
// | [Game Boy ROM data]                                       |
// |                                                           |
// | Source dictionary data 1:                                 |
// | (Example) Tag: $ff + Data length + Data 1 byte            |
// |   Data: $aaaaaaaa   -> $ff03aa (Dictionary index: 00)     |
// |   Data: $bbbbbb     -> $ff02bb (Dictionary index: 01)     |
// |                                                           |
// | Duplicate using dictionary data 1:                        |
// | (Example) Tag: $fe + Dictionary index                     |
// |   Data: $aaaaaaaa   -> $fe00                              |
// |   Data: $bbbbbb     -> $fe01                              |
// |                                                           |
// | Source dictionary data 2:                                 |
// | (Example) Tag: $fd + Data length + Data                   |
// |   Data: $abcdef   -> $fd02abcdef   (Dictionary index: 00) |
// |   Data: $123456   -> $fd02123456   (Dictionary index: 01) |
// |                                                           |
// | Duplicate using dictionary data 2:                        |
// | (Example) Tag: $fc + Dictionary index                     |
// |   Data: $abcdef   -> $fc00                                |
// |   Data: $123456   -> $fc01                                |
// |   Data: $782367ab -> $fc02                                |
// |                                                           |
// | Replicate successive values:                              |
// | (Example) Tag: $fb + Data length (More than 13) + Data    |
// |   Data: $0000..00 *length 14 -> $fd0e00                   |
// |                                                           |
// |   Tag: $fa + Data: $0000..00 *length 13 -> $fa00          |
// |   Tag: $f9 + Data: $0000..00 *length 12 -> $f900          |
// |   Tag: $f8 + Data: $0000..00 *length 11 -> $f800          |
// |   Tag: $f7 + Data: $0000..00 *length 10 -> $f700          |
// |   Tag: $f6 + Data: $0000..00 *length  9 -> $f600          |
// |   Tag: $f5 + Data: $0000..00 *length  8 -> $f500          |
// |   Tag: $f4 + Data: $0000..00 *length  7 -> $f400          |
// |   Tag: $f3 + Data: $0000..00 *length  6 -> $f300          |
// |   Tag: $f2 + Data: $0000..00 *length  5 -> $f200          |
// |   Tag: $f1 + Data: $00000000 *length  4 -> $f100          |
// |   Tag: $f0 + Data: $000000   *length  3 -> $f000          |
// |                                                           |
// +-----------------------------------------------------------+
//

/**
 * Setting
 */
$p['unusedValCnt'] = 16; // Compression requires the number of unused values specified here.
$p['max_val'] = 256 - $p['unusedValCnt'];

if(count($argv) < 3){
  echo "\nUsage: php GBDataCompressEncoder.php <Input file> <Output file> <option: 'dbg'>\n\n";
  echo "- Compression requires {$p['unusedValCnt']} unused values.\n";
  echo "- 'dbg': Debug mode. Verify that the encoding result is correct.\n\n";
  echo "Example: php GBDataCompressEncoder.php road_x.bin road_x_comp.bin 16 dbg\n\n";
  exit;
}

@$p['input_file'] = $argv[1];
@$p['output_file'] = $argv[2];
@$p['dbg'] = ($argv[3]=='dbg')?true:false;
$p['input'] = str_split(bin2hex(file_get_contents( $p['input_file'] )),2);


/**
 * Check for unused values
 */
echo "\nCheck for unused values >>>>>>>>>>>>>>>\n";
$p['unusedVal'] = checkUnusedVal($p);

if(count( $p['unusedVal'] ) < $p['unusedValCnt']){
  echo "Compression requires {$p['unusedValCnt']} unused values.\n\n";
  exit;
}else{
  setUnusedVal($p);
  $p['rom'] = replaceRomToUnusedVal(implode('',$p['input']),$p['RomToUnusedVal']);
  printf("%s values: %s\n\n",count( $p['unusedVal'] ),implode(',',$p['unusedVal']));
}


/**
 * Compress binary
 */
echo "Compression binary >>>>>>>>>>>>>>>\n";
compressBinary($p);


/**
 * Encoding result
 */
$input_size = strlen(implode('',$p['input']))/2;
$output_size = strlen( $p['rom'] )/2 + $p['unusedValCnt'];
$diff_size = $input_size - $output_size;
$diff_percent = sprintf('%.2f',($output_size / $input_size) * 100);

echo "Compression completed <<<<<<<<<<<<<<<\n\n";
printf("Input: %s bytes\n",$input_size);
printf("Output: %s bytes (%s%% -%s bytes)\n\n",$output_size,$diff_percent,$diff_size);
//echo "[Compression resource requirements]\n";
//echo "WRAM: 512 bytes\n";
//echo "ROM: 3000 bytes\n";

// 4096 bytes ->
// 4079 bytes 99% -17 bytes *Run-length
// 3690 bytes 90% -406 bytes
// 3528 bytes 86% -568 bytes
// 3033 bytes 74% -1063 bytes



/**
 * Verify the compression results
 */
if($p['dbg']){
  echo "Verify the compression results >>>>>>>>>>>>>>>\n";
  verifyCompression($p);
}



//====================================================================================
function compressBinary(&$p){
//====================================================================================
  $rom = implode('',$p['input']);

  // $aaaaaa -> '######'
  [$out,$dic_list1] = _checkDuplicateVal($p,'##');
  $p['rom'] = _createRomData($p,$out,$dic_list1,'##');
}

function _createRomData($p,$rom,$dic_list,$tag){
  $rom_pos = 0;
  $out = '';

  foreach($dic_list as $row){
    $out .= substr($rom,2*$rom_pos,2*($row['pos'] - $rom_pos));
    $out .= encodeDicTag($row);
    $rom_pos = $row['pos']+$row['len'];
  }
  $out .= substr($rom,2*$rom_pos);

  return $out;
}

function decodeDicTag($rom,&$rom_pos,&$dic1,&$dic2,$p){
  $rep_tag = [
    // Replicate successive values
    // tag => len
    'fa' => '13',
    'f9' => '12',
    'f8' => '11',
    'f7' => '10',
    'f6' => '9' ,
    'f5' => '8' ,
    'f4' => '7' ,
    'f3' => '6' ,
    'f2' => '5' ,
    'f1' => '4' ,
    'f0' => '3' ,
  ];

  $tag = substr($rom,2*$rom_pos,2);
  $out = '';

  if($tag == 'ff'){
    // Source dictionary data 1
    // $ff: tag,len,val
    $len = hexdec(substr($rom,2*($rom_pos+1),2))+1;
    $val = substr($rom,2*($rom_pos+2),2);
    $out = str_repeat($val,$len);
    $rom_pos += 2;
    $dic1[] = $out;
  }else
  if($tag == 'fe'){
    // Duplicate using dictionary data 1
    // $fe: tag,idx
    $idx = hexdec(substr($rom,2*($rom_pos+1),2));
    $out = $dic1[$idx];
    $rom_pos++;
  }else
  if($tag == 'fb'){
    // Replicate successive values
    // $fb: tag,len,val
    $len = hexdec(substr($rom,2*($rom_pos+1),2))+1;
    $val = substr($rom,2*($rom_pos+2),2);
    $out = str_repeat($val,$len);
    $rom_pos += 2;
  }else
  if($tag == 'fd'){
    // Source dictionary data 2
    $len = hexdec(substr($rom,2*($rom_pos+1),2))+1;
    $out = substr($rom,2*($rom_pos+2),2*$len);
    $rom_pos += 1+$len;
    $dic2[] = $out;
  }else
  if($tag == 'fc'){
    // Duplicate using dictionary data 2
    // $fe: tag,idx
    $idx = hexdec(substr($rom,2*($rom_pos+1),2));
    $out = $dic2[$idx];
    $rom_pos++;
  }else{
    // $f0 - $fa: tag(len),val
    $len = $rep_tag[$tag];
    $val = substr($rom,2*($rom_pos+1),2);
    $out = str_repeat($val,$len);
    $rom_pos++;
  }

  return $out;
}

function encodeDicTag($row){
  $rep_tag = [
    // Replicate successive values
    // len-1 => tag
    '12' => 'fa', // len 13 (0-12)
    '11' => 'f9', // len 12 (0-11)
    '10' => 'f8', // len 11 (0-10)
    '9'  => 'f7', // len 10 (0-9)
    '8'  => 'f6', // len 9  (0-8)
    '7'  => 'f5', // len 8  (0-7)
    '6'  => 'f4', // len 7  (0-6)
    '5'  => 'f3', // len 6  (0-5)
    '4'  => 'f2', // len 5  (0-4)
    '3'  => 'f1', // len 4  (0-3)
    '2'  => 'f0', // len 3  (0-2)
  ];

  $len = $row['len']-1;
  $val = $row['val'];

  if($row['dic_num'] == '1'){
    /**
     * dic_list1
     */
    if($row['dic_flg']){
      // Source dictionary data 1
      // $ff: tag,len,val
      $tag = sprintf("ff%02x%s",$len,$val);
    }else
    if($row['rep_flg']){
      // Replicate successive values
      if($len > 12){
        // $fb: tag,len,val
        $tag = sprintf("fb%02x%s",$len,$val);
      }else{
        // $f0 - $fa: tag(len),val
        $tag = sprintf("%s%s",$rep_tag[$len],$val);
      }
    }else{
      // Duplicate using dictionary data 1
      // $fe: tag,idx
      $tag = sprintf("fe%02x",$row['idx']);
    }
  }else
  if($row['dic_num'] == '2'){
    /**
     * dic_list2
     */
    if($row['dic_flg']){
      // Source dictionary data 2
      // $fd: tag,len,val
      $tag = sprintf("fd%02x%s",$len,$val);
    }else{
      // Duplicate using dictionary data 2
      // $fc: tag,idx
      $tag = sprintf("fc%02x",$row['idx']);
    }
  }else{
    // error
    echo "Error:".print_r($row,true);
    exit;
  }

  return $tag;
}

function _checkDuplicateVal($p,$tag){
  $rom = $p['rom'];
  $max_val = $p['max_val'];
  $rom_pos = 0;
  $rom_max_pos = strlen($rom)/2;
  $val_list1 = array();
  $val_hash1 = array();
  $dic_list1 = array();
  $out = '';

  /**
   * Source dictionary data 1
   *   $bbbbbb -> $ff02bb (Dictionary index: 01)
   * Duplicate using dictionary data 1
   *   $bbbbbb -> $fe01
   * Replicate successive values
   *   $020202 -> $fd0202
   */
  while(strlen($rom) != strlen($out)){

    if(strlen(substr($rom,2*$rom_pos)) >= 2*3){
      if(getHex($rom,$rom_pos) == getHex($rom,$rom_pos+1)
      && getHex($rom,$rom_pos) == getHex($rom,$rom_pos+2)){

        $rom_len = 3;
        while(getHex($rom,$rom_pos) == getHex($rom,$rom_pos+$rom_len)
          && $rom_len <= $max_val){
            $rom_len++;
        }

        $row = substr($rom,2*$rom_pos,2*$rom_len);
        $val_list1[$rom_pos] = [
          'val' => $row,
          'len' => strlen($row)/2,
          'pos' => $rom_pos
        ];

        $out .= str_repeat($tag,$rom_len);
        $rom_pos += $rom_len;
      }else{
        // Skip
        $out .= substr($rom,2*$rom_pos,2);
        $rom_pos++;
      }
    }else{
      // Completed
      $out .= substr($rom,2*$rom_pos);
    }
  }

  /**
   * Set dictionary 1
   */
  foreach($val_list1 as $row){
    @$val_hash1[ $row['val'] ]['cnt']++;
    @$val_hash1[ $row['val'] ]['len'] = strlen($row['val'])/2;
    @$val_hash1[ $row['val'] ]['flg'] = false;
    @$val_hash1[ $row['val'] ]['idx'] = false;
  }

  $idx = 0;
  ksort($val_list1);
  foreach($val_list1 as $row){
    $val = $row['val'];
    $cnt = $val_hash1[$val]['cnt'];
    $flg = $val_hash1[$val]['flg'];
    $dic_flg = false;
    $rep_flg = false;

    if($cnt > 1 && !$flg){
      if($idx < $p['max_val']){
        $dic_flg = true;
        $val_hash1[$val]['flg'] = true;
        $val_hash1[$val]['idx'] = $idx;
        $idx++;
      }else{
        $rep_flg = true;
      }
    }

    if($cnt == 1){
      $rep_flg = true;
    }

    $dic_list1[ $row['pos'] ] = [
      'val' => substr($val,0,2),
      'len' => $row['len'],
      'pos' => $row['pos'],
      'cnt' => $cnt,
      'idx' => ($cnt > 1)?$val_hash1[$val]['idx']:false,
      'dic_flg' => $dic_flg,
      'rep_flg' => $rep_flg,
      'dic_num' => 1
    ];
  }


  /**
   * Source dictionary data 2
   *   $123456 -> $fc02123456 (Dictionary index: 01)
   * Duplicate using dictionary data 2
   *   $123456 -> $fb01
   */
  $val_list2 = array();
  $val_hash2 = array();
  $dic_list2 = array();
  for($len = 30; $len >= 3; $len--){
    $out_pos = 0;

    while(strlen(substr($out,2*$out_pos,2*$len)) >= 2*$len){
      $row = substr($out,2*$out_pos,2*$len);
      
      if(strpos($row,$tag) !== false){
        $out_pos++;
        continue;
      }

      preg_match_all("/{$row}/",$out,$m,PREG_OFFSET_CAPTURE);

      if(!isset($m[0]) || count($m[0]) < 2){
        $out_pos++;
        continue;
      }

      $val_tmp = $m[0];
      $val_key = $val_tmp[0][0];
      $val_cnt = count($val_tmp);
      if(!isset($val_hash2[ $val_key ]) && count($val_hash2) <= $p['max_val']){
        $out = str_replace($val_key,str_repeat($tag,strlen($val_key)/2), $out);
        $val_hash2[ $val_key ] = '1';

        foreach($val_tmp as $val){
          $val_list2[ $val[1] ] = [
            'val' => $val[0],
            'len' => strlen($val[0])/2,
            'pos' => $val[1]/2,
            'cnt' => $val_cnt
          ];
        }
      }
      $out_pos++;
    }
  }

  /**
   * Set dictionary 2
   */
  $val_hash2 = array();
  foreach($val_list2 as $row){
    @$val_hash2[ $row['val'] ]['len'] = strlen($row['val'])/2;
    @$val_hash2[ $row['val'] ]['flg'] = false;
    @$val_hash2[ $row['val'] ]['idx'] = false;
  }

  $idx = 0;
  ksort($val_list2);
  foreach($val_list2 as $row){
    $val = $row['val'];
    $flg = $val_hash2[$val]['flg'];
    $dic_flg = false;

    if(!$flg){
      $dic_flg = true;
      $val_hash2[$val]['flg'] = true;
      $val_hash2[$val]['idx'] = $idx;
      $idx++;
    }

    $dic_list2[ $row['pos'] ] = [
      'val' => $val,
      'len' => $row['len'],
      'pos' => $row['pos'],
      'cnt' => $row['cnt'],
      'idx' => $val_hash2[$val]['idx'],
      'dic_flg' => $dic_flg,
      'dic_num' => 2
    ];
  }

  $dic_list = $dic_list1 + $dic_list2;
  ksort($dic_list);

  return [$out,$dic_list];
}

//====================================================================================
function verifyCompression($p){
//====================================================================================
  $rom = $p['rom'];
  $rom_pos = 0;
  $dic1 = array();
  $dic2 = array();
  $out = '';

  while(($row = substr($rom,2*$rom_pos,2))){
    // Check Dictionary Tag
    if(hexdec($row) >= $p['max_val']){
      $row = decodeDicTag($rom,$rom_pos,$dic1,$dic2,$p);
    }
    $out .= $row;
    $rom_pos++;

    if($p['dbg']){
      $tmp_len = strlen($out);
      $tmp_input = substr(implode('',$p['input']),0,$tmp_len);
      $tmp_rom = substr($rom,0,$tmp_len);
      $tmp_out1 = substr($out,0,$tmp_len);
      $tmp_out2 = substr(replaceUnusedValToRom($out,$p['unusedValToRom']),0,$tmp_len);
      if($tmp_input != $tmp_out2){
        echo "\n== rom_tmp ==\n$tmp_rom\n";
        echo "-- tmp_out1 ---\n$tmp_out1\n";
        echo "-- input_tmp --\n$tmp_input\n";
        echo "-- tmp_out2 ---\n$tmp_out2\n";
        echo "Error!! <<<\n";
        exit;
      }
    }
  }

  echo "Verification successful\n";
}



function hexlen($hex){
  return strlen($hex)/2;
}

function getHex($hex,$hex_len){
  return substr($hex,2*$hex_len,2);
}

function replaceUnusedValToRom($rom,$unusedVal){
  $out = '';
  for($i=0; $i<strlen($rom)/2; $i++){
    $row = substr($rom,2*$i,2);
    $out .= (isset($unusedVal[ $row ]))?$unusedVal[ $row ]:$row;
  }
  return $out;
}

function replaceRomToUnusedVal($input,$unusedVal){
  $out = '';
  for($i=0; $i<strlen($input)/2; $i++){
    $row = substr($input,2*$i,2);
    $out .= (isset($unusedVal[ $row ]))?$unusedVal[ $row ]:$row;
  }
  return $out;
}

function setUnusedVal(&$p){
  $unusedVal = $p['unusedVal'];
  $max_val = $p['max_val'];

  for($i=$max_val; $i<256; $i++){
    $key = dechex($i);

    if(isset($unusedVal[$key])){
      $p['RomToUnusedVal'][$key] = $unusedVal[$key];
      unset($unusedVal[$key]);
    }else{
      $p['RomToUnusedVal'][$key] = false;
    }
  }

  for($i=$max_val; $i<256; $i++){
    $key = dechex($i);

    if(!$p['RomToUnusedVal'][$key]){
      @$p['RomToUnusedVal'][$key] = array_pop($unusedVal);
      unset($unusedVal[$key]);
    }
  }

  foreach($p['RomToUnusedVal'] as $key => $val){
    $p['unusedValToRom'][$val] = $key;
  }
}

function checkUnusedVal($p){
  for($i=0; $i<256; $i++){
    $key = sprintf("%02x",$i);
    $list[$key] = $key;
  }

  foreach($p['input'] as $row){
    unset($list[$row]);
  }

  return $list;
}

?>