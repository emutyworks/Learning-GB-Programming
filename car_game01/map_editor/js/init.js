var PALETTE_DOT = 14;
var BGTILES_DOT = 2;
var MAPPART_DOT = 2;
var MAP_DOT = 2;
var MAPVIEW_DOT = 1;
var BGTILES_SIZE = BGTILES_DOT*8;
var MAPPART_SIZE = MAPPART_DOT*8;
var MAP_SIZE = MAP_DOT*8;
var MAPVIEW_SIZE = MAPVIEW_DOT*8;
var BGTILES_MAX_X = 8;
var BGTILES_MAX_Y = 4;
var BGTILES_MAX = 32;
var MAPPART_MAX_X = 8;
var MAPPART_MAX_Y = 32;
var OFFSET_X = 8;
var OFFSET_Y = 94;
var MAP_START_X = 0;
var MAP_START_Y = 0;

var map_max_x = 20;
var map_max_y = 32;
var right_start = BGTILES_SIZE*map_max_x+16;

var bgtiles_start_x = right_start;
var BGTILES_START_Y = 0;
var palette_start_x = right_start+BGTILES_SIZE*8+8+16;
var PALETTE_START_Y = BGTILES_START_Y;
var mappart_start_x = right_start;
var MAPPART_START_Y = BGTILES_START_Y+BGTILES_SIZE*4+4+20;
var mapview_start_x = right_start+MAPPART_SIZE*2*MAPPART_MAX_X+8+16
var MAPVIEW_START_Y = BGTILES_START_Y;
var win_start_x = MAP_START_X+MAP_SIZE*(map_max_x-19)+1
var WIN_START_Y = MAP_START_Y+MAP_SIZE+1;
var WIN_WIDTH_X = MAP_SIZE*18-1;
var WIN_HEIGHT_Y = MAP_SIZE*9;
var EDITOR_LINE = '#ff0000';
var EDITOR_BOX = '#ff0000';
var EDITOR_BOX2 = '#0000ff';

var VIEW_MAX_X = 1350;
var VIEW_MAX_Y = 700;

var base = null;
var view = null;
var grid = null;
var win = null;
var cursor = null;
var bctx = null;
var vctx = null;
var gctx = null;
var wctx = null;
var cctx = null;

var mouse_down = false;
var help_flag = false;
var edit_flag = false;
var bin_upload = false;
var reverse_map = false;
var flag = false;
var show_grid = false;
var select_view = 0;

var bg_tiles = [];
var bg_palette = [];
var map_part = [];
var map_table = [];
var cmap_part = [];

var cur_info = {
  org_x: 0,
  org_y: 0,
  x: 0,
  y: 0,
  cx: 0,
  cy: 0,
  //bg tiles
  bx: 0,
  by: 0,
  //map part
  px: 0,
  py: 0,
  wx: 0,
  wy: 0,
  psel: null,
  wsel: null,
  //map table
  mx: 0,
  my: 0,
  //map view
  vx: 0,
  vy: 0,
  vsel: null
};

var help_cancel = '[ESC or RM] Cancel';
var help_mes = {
  change_mappart: '[LM] Click to change Map Part '+help_cancel,
  edit_maptable: '[LM] Click to set Map Table '+help_cancel,
  select_mappart: '[LM] Click to edit Map Table [Shift + LM] Click to edit Map Part [Ctrl + LM] Click to copy Map Part ',
  edit_mappart: '[ESC] Cancel/Close',
  copy_mappart: '[LM] Click to paste Map Part '+help_cancel,
  start: 'Please Upload tiles.bin and map_editor.txt',
  reset: '[LM] Left Mouse click [RM] Right Mouse click ',
};

function setMapSize(m){
  if(!bin_upload){ return; }

  if(m=="confirm"){
    flag = edit_confirm_alert('The data being edited will be reset. Resize Map Table?');
  }else{
    flag = true;
  }
  if(flag){
    map_max_x = $('[name="map_size"]:selected').val();
  }else{
    $('[name="map_size"]').val(map_max_x).prop('selected',true);
  }

  var x = 0;
  var y = 0;
  var w = VIEW_MAX_X;
  var h = VIEW_MAX_Y;
  bctx.clearRect(x,y,w,h);
  vctx.clearRect(x,y,w,h);
  gctx.clearRect(x,y,w,h);
  wctx.clearRect(x,y,w,h);

  right_start = BGTILES_SIZE*map_max_x+16;
  bgtiles_start_x = right_start;
  palette_start_x = right_start+BGTILES_SIZE*8+8+16;
  mappart_start_x = right_start;
  mapview_start_x = right_start+MAPPART_SIZE*2*MAPPART_MAX_X+8+16
  win_start_x = MAP_START_X+MAP_SIZE*(map_max_x-19)+1;

  $('#bg_tiles_title').css({ 'left': (right_start+8)+'px' });
  $('#bg_palette_title').css({ 'left': (right_start+160)+'px' });
  $('#map_view_title').css({ 'left': (right_start+288)+'px' });
  $('#map_part_title').css({ 'left': (right_start+8)+'px' });
  $('#help_mes').css({ 'width': (right_start+MAPVIEW_SIZE*map_max_x*2+282)+'px' });
  $('#win_mappart').css({ 'width': (MAP_SIZE*(map_max_x-2))+'px' });

  refill_map_table();
  initView();
  drawBgTiles();
  drawMapParts();
  showGrid();
  selectMapView();
  edit_flag = false;
}

function initView(){
  $('#base').attr({
    width: VIEW_MAX_X+'px',
    height: VIEW_MAX_Y+'px',
  });
  $('#view').attr({
    width: VIEW_MAX_X+'px',
    height: VIEW_MAX_Y+'px',
  });
  $('#grid').attr({
    width: VIEW_MAX_X+'px',
    height: VIEW_MAX_Y+'px',
  });
  $('#win').attr({
    width: VIEW_MAX_X+'px',
    height: VIEW_MAX_Y+'px',
  });
  $('#cursor').attr({
    width: VIEW_MAX_X+'px',
    height: VIEW_MAX_Y+'px',
  });

  $("input[name='download_file']").val("map_editor");

  drawPallette();
  drawBase();
  setMes('start');
}

function drawBase(){

  //BG Palette
  var xx = palette_start_x;
  var yy = PALETTE_START_Y;
  bdrowBox(xx,yy,PALETTE_DOT*4+4,PALETTE_DOT*4+4,EDITOR_BOX);

  //BG Tiles
  xx = bgtiles_start_x;
  yy = BGTILES_START_Y;
  bdrowBox(xx,yy,BGTILES_SIZE*BGTILES_MAX_X+BGTILES_MAX_X,BGTILES_SIZE*BGTILES_MAX_Y+BGTILES_MAX_Y,EDITOR_BOX);

  // Map Part
  xx = mappart_start_x;
  yy = MAPPART_START_Y;
  bdrowBox(xx,yy,MAPPART_SIZE*MAPPART_MAX_X*2+MAPPART_MAX_X,MAPPART_SIZE*MAPPART_MAX_Y+MAPPART_MAX_Y,EDITOR_BOX);

  // Map Table
  xx = MAP_START_X;
  yy = MAP_START_Y;
  bdrowBox(xx,yy,MAP_SIZE*map_max_x+1,MAP_SIZE*map_max_y+1,EDITOR_BOX);

  // Map View
  xx = mapview_start_x;
  yy = MAPVIEW_START_Y;
  bdrowBox(xx,yy,MAPVIEW_SIZE*map_max_x*2+1,MAPVIEW_SIZE*map_max_y*2+1,EDITOR_BOX);

  gctx.fillStyle = EDITOR_LINE;
  gctx.globalAlpha = 0.2;
  gctx.fillRect(xx+MAPVIEW_SIZE*map_max_x,yy,1,MAPVIEW_SIZE*map_max_y*2+1);
  gctx.fillRect(xx,yy+MAPVIEW_SIZE*map_max_y,MAPVIEW_SIZE*map_max_x*2+1,1);
  gctx.globalAlpha = 1.0;
}

function bdrowBox(x,y,w,h,c){
  bctx.fillStyle = c;
  bctx.fillRect(x,y,1,h);
  bctx.fillRect(x,y,w,1);
  bctx.fillRect(x+w,y,1,h);
  bctx.fillRect(x,y+h,w+1,1);
}
function vdrowBox(x,y,w,h,c){
  vctx.fillStyle = c;
  vctx.fillRect(x,y,1,h);
  vctx.fillRect(x,y,w,1);
  vctx.fillRect(x+w,y,1,h);
  vctx.fillRect(x,y+h,w+1,1);
}
function wdrowBox(x,y,w,h,c){
  wctx.fillStyle = c;
  wctx.fillRect(x,y,1,h);
  wctx.fillRect(x,y,w,1);
  wctx.fillRect(x+w,y,1,h);
  wctx.fillRect(x,y+h,w+1,1);
}
function cdrowBox(x,y,w,h,c){
  cctx.fillStyle = c;
  cctx.fillRect(x,y,1,h);
  cctx.fillRect(x,y,w,1);
  cctx.fillRect(x+w,y,1,h);
  cctx.fillRect(x,y+h,w+1,1);
}

function bdrawText(xx,yy,pt,str){
  bctx.fillStyle = '#000000';
  bctx.font = pt+'pt sans-serif lighter';
  bctx.fillText(str,xx,yy);
}

function gbc2htmlc(v){
  var gbc = dec2bin16(v);
  var b = bin2hex(gbc.substring(1,6)+"000");
  var g = bin2hex(gbc.substring(6,11)+"000");
  var r = bin2hex(gbc.substring(11,16)+"000");
  return "#" + r + g + b;
  //Bit 0-4   Red Intensity   ($00-1F)
  //Bit 5-9   Green Intensity ($00-1F)
  //Bit 10-14 Blue Intensity  ($00-1F)
}

function dec2bin16(v){
  v = parseInt(v,10);
  var len = v.toString(2).length;
  return ('0000000000000000'+v.toString(2)).substring(len,len+16);
}
function dec2bin8(v){
  v = parseInt(v,10);
  var len = v.toString(2).length;
  return ('00000000'+v.toString(2)).substring(len,len+8);
}

function hex2bin8(v){
  v = parseInt(v, 16);
  var len = v.toString(2).length;
  return ('00000000'+v.toString(2)).substring(len,len+8);
}

function bin2hex(v){
  return dec2hex(bin2dec(v));
}

function dec2hex(v){
  var len = v.toString(16).length;
  return (('00'+v.toString(16).toUpperCase()).substring(len,len+2));
}

function bin2dec(v){
  return parseInt(v,2);
}

function hex2dec(v){
  return parseInt(v,16);
}

function edit_confirm_alert(mes){
  return window.confirm(mes);
}