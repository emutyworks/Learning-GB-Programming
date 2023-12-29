<?php
// .inc filename
define('FN_SOUND_DATA_TBL','gbsd_sound_data_tbl.inc');

// Sound Data
//define('SD_VOLUMEENVELOPE','C0');
define('SD_ENVELOPE','C0');
define('SD_OCTAVE','D');
define('SD_EMPTY','E');
define('SD_NOTE','F');
define('SD_ENDDATA','$FF');
define('SD_EMPTY_CNT_MAX',16);

function dec2hex($val,$num=2){
  return str_pad(dechex($val),$num,0,STR_PAD_LEFT);
}

function getPatternsData($key,$d,&$total_bytes){
  $hex = array();
  $octave_old = null;
  $empty_cnt = -1;

  $list = $d['PATTERNS_DATA'][$key][0]['PATTERN_MATRIX'];

  for($i=0; $i<count($list); $i++){
    $note = substr($list[$i]['NoteForThisIndex'],1,1);
    $octave = (int)substr($list[$i]['OctaveForThisIndex'],1,1);

    if($list[$i]['VolumeForThisIndex']!='ffff'){
      $volume = substr($list[$i]['VolumeForThisIndex'],1,1);
    }else{
      $volume = null;
    }
    if($list[$i]['InstrumentForThisIndex']!='ffff'){
      $instrument = hexdec(substr($list[$i]['InstrumentForThisIndex'],0,2));
    }else{
      $instrument = null;
    }

    // Set Volume Envelope
    if($instrument!==null){
      $row = $d['INSTRUMENTS_DATA'][$instrument]['PER_SYSTEM_DATA'];
      $hi = dechex($row['EnvelopeVolume']);
      $low = dechex(($row['EnvelopeDirection'] << 3) + $row['EnvelopeLength']);
      $hex[] = sprintf("%s,\$%s ; Set Envelope",SD_ENVELOPE,$hi.$low);
      $total_bytes += 2;
    }

    // Set Octave
    if($note=='c'){
      $note = '0';
      $octave = $octave + 1;
    }
    if($octave>=2 && $octave<=7 && $octave_old!=$octave){
      $hex[] = sprintf("%s%s ; Set Octave",SD_OCTAVE,$octave-2,$octave);
      $octave_old = $octave;
      $total_bytes++;
    }
    
    // Set Note
    if($volume===null){
      $row = sprintf("%s%s",SD_NOTE,$note);
    }else{
      $row = sprintf("%s%s",$note,$volume);
    }

    // Set Empty
    if($note.$octave=='00'){
      $empty_cnt++;
    }else{
      if($empty_cnt!=-1){
        do{
          if($empty_cnt>=SD_EMPTY_CNT_MAX){
            $hex[] = sprintf("%s%s ; Set Empty",SD_EMPTY,dechex(SD_EMPTY_CNT_MAX-1));
            $empty_cnt -= SD_EMPTY_CNT_MAX;
            $total_bytes++;
          }else{
            $hex[] = sprintf("%s%s ; Set Empty",SD_EMPTY,dechex($empty_cnt));
            $total_bytes++;
            $empty_cnt = -1;
          }
        }while($empty_cnt>-1);
        $hex[] = $row;
        $total_bytes++;
      }else{
        $hex[] = $row;
        $total_bytes++;
      }
    }
  }

  // Set Empty
  if($empty_cnt!=-1){
    do{
      if($empty_cnt>=SD_EMPTY_CNT_MAX){
        $hex[] = sprintf("%s%s ; Set Empty",SD_EMPTY,dechex(SD_EMPTY_CNT_MAX-1));
        $empty_cnt -= SD_EMPTY_CNT_MAX;
        $total_bytes++;
      }else{
        $hex[] = sprintf("%s%s ; Set Empty",SD_EMPTY,dechex($empty_cnt));
        $total_bytes++;
        $empty_cnt = -1;
      }
    }while($empty_cnt>-1);
  }

  // debug
  for($i=0; $i<count($hex); $i++){
    printf("$%s\n",$hex[$i]);
  }
  
  $rows = null;
  for($i=0; $i<count($hex); $i++){
    $rows .= "  db $".$hex[$i]."\n";
  }
  $rows .= sprintf("  db %s",SD_ENDDATA);
  $total_bytes++;

  return $rows;
}
?>