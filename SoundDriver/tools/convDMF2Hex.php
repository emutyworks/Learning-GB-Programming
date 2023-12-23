<?php
/*
Generate Assembly code from DefleMask .DMF file.

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

// Generate sound_data_tbl.inc
$list = $d['PATTERNS_DATA']['SQ1'][0]['PATTERN_MATRIX'];

$hex = array();
$octave_old = null;
$empty_cnt = -1;
$total_bytes = 0;
$uses_wram = 0;
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

//printf("%s:%s|%s|%s|%s\n",$i,$note,$octave,$volume,$instrument);
//continue;

  // Set Volume Envelope
  if($instrument!==null){
    $row = $d['INSTRUMENTS_DATA'][$instrument]['PER_SYSTEM_DATA'];
    $hi = dechex($row['EnvelopeVolume']);
    $low = dechex(($row['EnvelopeDirection'] << 3) + $row['EnvelopeLength']);
    $hex[] = sprintf("%s,\$%s ; Set Envelope",SD_ENVELOPE,$hi.$low);
    $total_bytes += 2;
    $uses_wram += 2;
    //$hex[] = sprintf("%s,\$%s,\$%s ; Set Volume Envelope",SD_VOLUMEENVELOPE,$hi.$low,dec2hex($row['SoundLength']));
    //$total_bytes += 3;
    print_r($row);
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
          $uses_wram++;
        }else{
          $hex[] = sprintf("%s%s ; Set Empty",SD_EMPTY,dechex($empty_cnt));
          $total_bytes++;
          $uses_wram++;
          $empty_cnt = -1;
        }
      }while($empty_cnt>-1);
      $hex[] = $row;
      $total_bytes++;
      $uses_wram++;
    }else{
      $hex[] = $row;
      $total_bytes++;
      $uses_wram++;
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
      $uses_wram++;
    }else{
      $hex[] = sprintf("%s%s ; Set Empty",SD_EMPTY,dechex($empty_cnt));
      $total_bytes++;
      $uses_wram++;
      $empty_cnt = -1;
    }
  }while($empty_cnt>-1);
}

for($i=0; $i<count($hex); $i++){
  printf("$%s\n",$hex[$i]);
}

$rows = null;
for($i=0; $i<count($hex); $i++){
  $rows .= "  db $".$hex[$i]."\n";
}
$rows .= sprintf("  db %s\n",SD_ENDDATA);
$total_bytes++;
$uses_wram++;

printf("*Total %s bytes of data, Uses %s bytes of WRAM\n",$total_bytes,$uses_wram);

$tpl = file_get_contents(dirname(__FILE__).'/templates/sound_data_tbl.inc');
$out = str_replace('{{TOTAL_BYTES}}',$total_bytes,$tpl);
$out = str_replace('{{USES_WRAM}}',$uses_wram,$out);
$out = str_replace('{{DATA}}',$rows,$out);
file_put_contents(FN_SOUND_DATA_TBL,$out);

/*
[INSTRUMENTS_DATA][0][PER_SYSTEM_DATA]=> Array
(
  [EnvelopeVolume] => 9
  [EnvelopeDirection] => 1
  [EnvelopeLength] => 3
  [SoundLength] => 49
(

; [Envelope]
ld a,%7654xxxx ; EnvelopeVolume - Initial value of envelope
     %xxxx3xxx ; EnvelopeDirection - Envelope 1:UP/0:DOWN
     %xxxxx210 ; EnvelopeLength - Number of envelope sweep (# 0-7)
ldh [rAUD1ENV],a

; [Sound length/Wave pattern duty]
ld a,%76xxxxxx ; - Wave Pattern Duty (00:12.5% 01:25% 10:50% 11:75%)
     %xx543210 ; SoundLength - Sound length data (# 0-63)
ldh [rAUD1LEN],a

-----
[PATTERNS_DATA][SQ1][0][PATTERN_MATRIX] => Array
(
  [0] => Array
    (
      [NoteForThisIndex] => 0100
      [OctaveForThisIndex] => 0100 (NoteForThisIndex:0000 + OctaveForThisIndex:0000 = Empty)
      [VolumeForThisIndex] => 0100 (ffff = Empty)
    )
)

; [Envelope]
ld a,%7654xxxx ; VolumeForThisIndex - Initial value of envelope
ldh [rAUD1ENV],a

; NoteForThisIndex + OctaveForThisIndex -> GameBoy Sound Table
ld a,%76543210
ldh [rAUD1LOW],a ; Frequency low byte
ld a,%xxxxx210
ldh [rAUD1HIGH],a ; Frequency high byte

- Reference
Specs for DMF (DefleMask Module Format, for DefleMask v1.0.0 and above)
https://www.deflemask.com/DMF_SPECS.txt
Pan Docs: Audio Registers
https://gbdev.io/pandocs/Audio_Registers.html
hardware.inc: Gameboy Hardware definitions
https://github.com/gbdev/hardware.inc/tree/master
*/
?>

