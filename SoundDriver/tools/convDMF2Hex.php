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
$total_bytes = 0;

$rows1 = getPatternsData('SQ1',$d,$total_bytes);
$rows2 = getPatternsData('SQ2',$d,$total_bytes);

printf("*Total %s bytes of data.\n",$total_bytes);

$tpl = file_get_contents(dirname(__FILE__).'/templates/'.FN_SOUND_DATA_TBL);
$out = str_replace('{{TOTAL_BYTES}}',$total_bytes,$tpl);
$out = str_replace('{{DATA_SQ1}}',$rows1,$out);
$out = str_replace('{{DATA_SQ2}}',$rows2,$out);
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

