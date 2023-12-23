<?php
// .inc filename
define('FN_SOUND_DATA_TBL','sound_data_tbl.inc');

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
?>