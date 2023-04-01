function drawMap(m){
  var xx = MAP_START_X;
  var yy = MAP_START_Y;

  for(var i=0; i<map_max_y; i++){
    var row = map_table[i+map_max_y*select_view];
    for(var j=0; j<row.length; j++){
      var data = [];
      data[0] = map_part[row[j]*2];
      data[1] = map_part[row[j]*2+1];
      drawMapPart(xx+1,yy+1,data,MAP_DOT,"v");
      xx += MAP_SIZE*2;
    }
    xx = MAP_START_X;
    yy += MAP_SIZE;
  }
  drawMapView(m);
}

function drawMapView(m){
  if(m=='edit'){
    _drawMapView(select_view);
  }else{
    for(var i=0; i<4; i++){
      _drawMapView(i);
    }
  }
}
function _drawMapView(s){
  var x = mapview_start_x;
  var y = MAPVIEW_START_Y;
  var add_index = map_max_y*s;

  if(s==1){
    y += MAPVIEW_SIZE*map_max_y;
  }else
  if(s==2){
    x += MAPVIEW_SIZE*map_max_x;
  }else
  if(s==3){
    x += MAPVIEW_SIZE*map_max_x;
    y += MAPVIEW_SIZE*map_max_y;
  }else{
    //
  }
  var xx = x;
  var yy = y;

  for(var i=0; i<map_max_y; i++){
    var row = map_table[i+add_index];
    for(var j=0; j<row.length; j++){
      var data = [];
      data[0] = map_part[row[j]*2];
      data[1] = map_part[row[j]*2+1];
      drawMapPart(xx+1,yy+1,data,MAPVIEW_DOT,"v");
      xx += MAPVIEW_SIZE*2;
    }
    xx = x;
    yy += MAPVIEW_SIZE;
  }
}

function drawMapParts(){
  var xx = mappart_start_x+1;
  var yy = MAPPART_START_Y+1;
  var max_index = Math.trunc(map_part.length/2);
  var index = 0;

  lp: do{
    for(var x=0; x<BGTILES_MAX_X; x++){
      var data = [];
      data[0] = map_part[index*2];
      data[1] = map_part[index*2+1];
      drawMapPart(xx,yy,data,MAPPART_DOT,"v");
      index++
      xx += MAPPART_SIZE*2+1;
      if(index>=max_index){
        break lp;
      }
    }
    xx = mappart_start_x+1;
    yy += MAPPART_SIZE+1;
  }while(index<map_part.length);
}

function drawMapPart(xx,yy,data,dot_size,m){
  for(var j=0; j<2; j++){
    var i = parseInt(data[j],2)&0b00011111;
    var p = (parseInt(data[j],2)&0b11000000)>>6;
    var f = (parseInt(data[j],2)&0b00100000)>>5;
    drawTile(xx,yy,i,p,dot_size,f,m);
    xx += dot_size*8;
  }
}

function drawTile(xx,yy,index,p,dot_size,flip,m){
  var tile_cnt = index*8;

  for(var y=0; y<8; y++){
    var bg_data = bg_tiles[tile_cnt+y].concat();
    if(flip==1){
      bg_data = flipHorizontalTile(bg_data);
    }
    for(var x=0; x<8; x++){
      var d = Math.trunc(bg_data[x]);
      var c = gbc2htmlc(bg_palette[d+4*p]);
      if(m=="v"){
        vctx.fillStyle = c;
        vctx.fillRect(xx+x*dot_size,yy+y*dot_size,dot_size,dot_size);
      }else
      if(m=="w"){
        wctx.fillStyle = c;
        wctx.fillRect(xx+x*dot_size,yy+y*dot_size,dot_size,dot_size);
      }
    }
  }
}

function drawBgTiles(){
  var xx = bgtiles_start_x;
  var yy = BGTILES_START_Y;

  var index = 0;
  var p = 0;

  for(var x=0; x<BGTILES_MAX_X; x++){
    for(var y=0; y<BGTILES_MAX_Y; y++){
      drawTile(xx+x*(BGTILES_SIZE+1)+1,yy+y*(BGTILES_SIZE+1)+1,index,p,BGTILES_DOT,0,"v");
      index++;
    }
  }
}

function drawPallette(){
  var xx = palette_start_x;
  var yy = PALETTE_START_Y;
  var loop = Math.trunc(bg_palette.length/4);
  var y = 0;
  for(var l=0; l<loop; l++){
    var x = 0;
    for(var i=0; i<4; i++){
      vctx.fillStyle = gbc2htmlc(bg_palette[i+l*4]);
      vctx.fillRect(xx+x+1,yy+y+1,PALETTE_DOT,PALETTE_DOT);
      x += PALETTE_DOT+1;
    }
    y += PALETTE_DOT+1;
    bdrawText(xx+PALETTE_DOT*4+7,y-3,7,l);
  }
}

function flipHorizontalTile(v){
  var r = [];
  var cnt = 0;
  for(var i=7; i>=0; i--){
    r[cnt] = v[i].concat();
    cnt++;
  }
  return r;
}

function editMapTable(){
  var mx = cur_info['mx'];
  var my = cur_info['my'];
  map_table[my+map_max_y*select_view][mx] = cur_info['psel'];
  drawMap('edit');
}

function selectMapTable(){
  if(!edit_flag){
    edit_flag = 'edit_maptable';
    setMes(edit_flag);
    cur_info['psel'] = cur_info['px']+MAPPART_MAX_X*cur_info['py'];
    
    var xx = mappart_start_x+cur_info['px']*(MAPPART_SIZE*2+1);
    var yy = MAPPART_START_Y+cur_info['py']*(MAPPART_SIZE+1);
    cctx.globalAlpha = 0.2;
    cctx.fillStyle = EDITOR_BOX;
    cctx.fillRect(xx,yy,MAPPART_SIZE*2+1,MAPPART_SIZE+1);
    cctx.globalAlpha = 1.0;
  }
}

function setMapPart(){
  var i = cur_info['bx']*BGTILES_MAX_Y+cur_info['by'];
  var part = cmap_part[cur_info['wsel']];
  var data = parseInt(part,2)&0b11100000;
  cmap_part[cur_info['wsel']] = dec2bin8(data|i);
  editMapPart("change");
}

function changeMapPart(){
  edit_flag = 'change_mappart';
  setMes(edit_flag);
  cur_info['wsel'] = cur_info['wx'];
    
  var xx = win_start_x+(MAPPART_SIZE*15-3)+cur_info['wx']*MAPPART_SIZE;
  var yy = WIN_START_Y+MAPPART_SIZE;
  cctx.globalAlpha = 0.2;
  cctx.fillStyle = EDITOR_BOX;
  cctx.fillRect(xx,yy,MAPPART_SIZE,MAPPART_SIZE);
  cctx.globalAlpha = 1.0;
}

function selectMapPart(m){
  if(!edit_flag){
    cur_info['psel'] = cur_info['px']+MAPPART_MAX_X*cur_info['py'];
    
    var xx = mappart_start_x+cur_info['px']*(MAPPART_SIZE*2+1);
    var yy = MAPPART_START_Y+cur_info['py']*(MAPPART_SIZE+1);
    cctx.globalAlpha = 0.2;
    cctx.fillStyle = EDITOR_BOX;
    cctx.fillRect(xx,yy,MAPPART_SIZE*2+1,MAPPART_SIZE+1);
    cctx.globalAlpha = 1.0;

    if(m=='edit'){
      edit_flag = 'edit_mappart';
      setMes(edit_flag);
      editMapPart();
    }else{
      cur_info['cx'] = cur_info['px'];
      cur_info['cy'] = cur_info['py'];
      edit_flag = 'copy_mappart';
      setMes(edit_flag);
    }
  }
}

function copyMapPart(){
  var i = cur_info['psel'];
  var ci =  cur_info['px']+MAPPART_MAX_X*cur_info['py'];
  map_part[ci*2] = map_part[i*2].concat();
  map_part[ci*2+1] = map_part[i*2+1].concat();
  drawMapParts();
  drawMap('edit');
}

function updateMapPart(m){
  var xx = win_start_x+MAPPART_SIZE*15-3;
  var yy = WIN_START_Y+MAPPART_SIZE;

  var i = cur_info['psel'];
  var left_pal = $('input:radio[name="left_pal"]:checked').val();
  var right_pal = $('input:radio[name="right_pal"]:checked').val();
  var left_flip = $('input:checkbox[name="left_flip"]:checked').val();
  var right_flip = $('input:checkbox[name="right_flip"]:checked').val();

  if(left_pal===undefined){ left_pal = 0; }
  if(right_pal===undefined){ right_pal = 0; }
  if(left_flip===undefined){ left_flip = 0; }
  if(right_flip===undefined){ right_flip = 0; }
  left_pal = left_pal<<6;
  right_pal = right_pal<<6;
  left_flip = left_flip<<5;
  right_flip = right_flip<<5;

  cmap_part[0] = parseInt(cmap_part[0],2)&0b00011111;
  cmap_part[1] = parseInt(cmap_part[1],2)&0b00011111;
  cmap_part[0] = dec2bin8(left_pal | left_flip | cmap_part[0]);
  cmap_part[1] = dec2bin8(right_pal | right_flip | cmap_part[1]);
  if(m=="save"){
    map_part[i*2] = cmap_part[0].concat();
    map_part[i*2+1] = cmap_part[1].concat();
    drawMapParts();
    drawMap('edit');
  }else{
    drawMapPart(xx,yy,cmap_part,MAPPART_DOT,"w");
  }
}

function editMapPart(m){
  var xx = win_start_x+MAPPART_SIZE*15-3;
  var yy = WIN_START_Y+MAPPART_SIZE;
  var i = cur_info['psel'];

  if(m!='change'){
    showWin();
    cmap_part[0] = map_part[i*2].concat();
    cmap_part[1] = map_part[i*2+1].concat();
  }
  drawMapPart(xx,yy,cmap_part,MAPPART_DOT,"w");

  var left_pal = [];
  var right_pal = [];
  var left_flip = [];
  var right_flip = [];
  left_pal[0] = (parseInt(cmap_part[0],2)&0b11000000)>>6;
  right_pal[0] = (parseInt(cmap_part[1],2)&0b11000000)>>6;
  left_flip[0] = (parseInt(cmap_part[0],2)&0b00100000)>>5;
  right_flip[0] = (parseInt(cmap_part[1],2)&0b00100000)>>5;

  $('input:radio[name="left_pal"]').val(left_pal);
  $('input:radio[name="right_pal"]').val(right_pal);
  $('input:checkbox[name="left_flip"]').val(left_flip);
  $('input:checkbox[name="right_flip"]').val(right_flip);
}

function showWin(){
  var xx = win_start_x;
  var yy = WIN_START_Y;
  wctx.fillStyle = "#ffffff";
  wctx.globalAlpha = 0.7;
  wctx.fillRect(xx,yy,WIN_WIDTH_X,WIN_HEIGHT_Y);
  wctx.globalAlpha = 1.0;
  $('#win_mappart').show();
  $("input[name='download_file']").focus();
}

function resetWin(){
  var x = win_start_x;
  var y = WIN_START_Y;
  var w = WIN_WIDTH_X+1;
  var h = WIN_HEIGHT_Y+1;
  wctx.clearRect(x,y,w,h);
  $('#win_mappart').hide();
}

function setMes(key){
  $('#help_mes').html("&nbsp "+help_mes[key]);
}

function changeMapPartCancel(){
  edit_flag = 'edit_mappart';
  resetChangeMapPartCursor();
  resetBgTablesCursor();
}

function editCancel(){
  resetWin();
  setMes('reset');
  resetMapPartCursor();
  resetMapTableCursor();
  edit_flag = false;
  mouse_down = false;
}

function resetMapPartCursor(){
  var x = mappart_start_x;
  var y = MAPPART_START_Y;
  var w = (MAPPART_SIZE*2+1)*MAPPART_MAX_X;
  var h = (MAPPART_SIZE+1)*MAPPART_MAX_Y;
  cctx.clearRect(x,y,w,h);
}

function setMapPartCursor(){
  var xx = mappart_start_x+cur_info['px']*(MAPPART_SIZE*2+1);
  var yy = MAPPART_START_Y+cur_info['py']*(MAPPART_SIZE+1);
  cdrowBox(xx,yy,MAPPART_SIZE*2+1,MAPPART_SIZE+1,EDITOR_LINE);

  if(edit_flag=='copy_mappart'){
    xx = mappart_start_x+cur_info['cx']*(MAPPART_SIZE*2+1);
    yy = MAPPART_START_Y+cur_info['cy']*(MAPPART_SIZE+1);
    cctx.globalAlpha = 0.2;
    cctx.fillStyle = EDITOR_BOX;
    cctx.fillRect(xx,yy,MAPPART_SIZE*2+1,MAPPART_SIZE+1);
    cctx.globalAlpha = 1.0;
  }
}

function resetBgTablesCursor(){
  var x = bgtiles_start_x;
  var y = BGTILES_START_Y;
  var w = BGTILES_MAX_X*(BGTILES_SIZE+1);
  var h = BGTILES_MAX_Y*(BGTILES_SIZE+1);
  cctx.clearRect(x,y,w,h);
}

function setBgTablesCursor(){
  var xx = bgtiles_start_x+cur_info['bx']*(BGTILES_SIZE+1);
  var yy = BGTILES_START_Y+cur_info['by']*(BGTILES_SIZE+1);
  cdrowBox(xx,yy,BGTILES_SIZE+1,BGTILES_SIZE+1,EDITOR_LINE);
}

function resetMapTableCursor(){
  var x = MAP_START_X;
  var y = MAP_START_Y;
  var w = MAP_SIZE*map_max_x+1;
  var h = MAP_SIZE*map_max_y+1;
  cctx.clearRect(x,y,w,h);
}

function setMapTableCursor(){
  var xx = MAP_START_X+cur_info['mx']*MAP_SIZE*2;
  var yy = MAP_START_Y+cur_info['my']*MAP_SIZE;
  cdrowBox(xx,yy,MAP_SIZE*2+1,MAP_SIZE+1,EDITOR_LINE);
}

function resetChangeMapPartCursor(){
  var x = win_start_x+MAPPART_SIZE+MAPPART_SIZE*14-3;
  var y = WIN_START_Y+MAPPART_SIZE-1;
  var w = MAPPART_SIZE*2+2;
  var h = MAPPART_SIZE+2;
  cctx.clearRect(x,y,w,h);
}

function setChangeMapPartCursor(){
  var xx = win_start_x+(MAPPART_SIZE*15-3)+cur_info['wx']*MAPPART_SIZE;
  var yy = WIN_START_Y+MAPPART_SIZE;
  cdrowBox(xx,yy,MAPPART_SIZE,MAPPART_SIZE,EDITOR_LINE);
}

function checkMapTableArea(){
  if(cur_info['x']>MAP_START_X
    && cur_info['y']>MAP_START_Y
    && cur_info['x']<MAP_START_X+MAP_SIZE*map_max_x
    && cur_info['y']< MAP_START_Y+MAP_SIZE*map_max_y
    ){
    return true;
  }
  return false;
}

function checkMapPartArea(){
  if(cur_info['x']>mappart_start_x
    && cur_info['y']>MAPPART_START_Y
    && cur_info['x']<mappart_start_x+(MAPPART_SIZE*2+1)*MAPPART_MAX_X
    && cur_info['y']<MAPPART_START_Y+(MAPPART_SIZE+1)*MAPPART_MAX_Y
    ){
    return true;
  }
  return false;
}

function checkWinArea(){
  if(cur_info['x']>win_start_x
    && cur_info['y']>WIN_START_Y
    && cur_info['x']<win_start_x+WIN_WIDTH_X
    && cur_info['y']<WIN_START_Y+WIN_HEIGHT_Y
    ){
    return true;
  }
  return false;
}

function checkChangeMapPartArea(){
  if(cur_info['x']>win_start_x+MAPPART_SIZE*15-3
    && cur_info['y']>WIN_START_Y+MAPPART_SIZE
    && cur_info['x']<win_start_x+MAPPART_SIZE+MAPPART_SIZE*16-3
    && cur_info['y']<WIN_START_Y+MAPPART_SIZE+MAPPART_SIZE
    ){
    return true;
  }
  return false;
}

function checkBgTilesArea(){
  if(cur_info['x']>bgtiles_start_x
    && cur_info['y']>BGTILES_START_Y
    && cur_info['x']<bgtiles_start_x+(BGTILES_SIZE+1)*BGTILES_MAX_X
    && cur_info['y']<BGTILES_START_Y+(BGTILES_SIZE+1)*BGTILES_MAX_Y
    ){
    return true;
  }
  return false;
}

function checkMapViewArea(){
  if(cur_info['x']>mapview_start_x
    && cur_info['y']>MAPVIEW_START_Y
    && cur_info['x']<mapview_start_x+MAPVIEW_SIZE*map_max_x*2
    && cur_info['y']<MAPVIEW_START_Y+MAPVIEW_SIZE*map_max_y*2
    ){
    return true;
  }
  return false;
}

function resetMapViewCursor(){
  var x = mapview_start_x;
  var y = MAPVIEW_START_Y;
  var w = MAPVIEW_SIZE*map_max_x*2+1;
  var h = MAPVIEW_SIZE*map_max_y*2+1;
  cctx.clearRect(x,y,w,h);
}

function setMapViewCursor(){
  var xx = mapview_start_x+cur_info['vx']*(MAPVIEW_SIZE*map_max_x);
  var yy = MAPVIEW_START_Y+cur_info['vy']*(MAPVIEW_SIZE*map_max_y);
  cdrowBox(xx,yy,MAPVIEW_SIZE*map_max_x,MAPVIEW_SIZE*map_max_y,EDITOR_LINE);
}

function selectMapView(){
  cur_info['vsel'] = cur_info['vx']*2+cur_info['vy'];
  select_view = cur_info['vsel'];
    
  var xx = mapview_start_x;
  var yy = MAPVIEW_START_Y;
  gctx.clearRect(xx,yy,MAPVIEW_SIZE*map_max_x*2+1,MAPVIEW_SIZE*map_max_y*2+1);
  gctx.fillStyle = EDITOR_LINE;
  gctx.globalAlpha = 0.2;
  gctx.fillRect(xx+MAPVIEW_SIZE*map_max_x,yy,1,MAPVIEW_SIZE*map_max_y*2+1);
  gctx.fillRect(xx,yy+MAPVIEW_SIZE*map_max_y,MAPVIEW_SIZE*map_max_x*2+1,1);

  xx = mapview_start_x+MAPVIEW_SIZE*map_max_x*cur_info['vx'];
  yy = MAPVIEW_START_Y+MAPVIEW_SIZE*map_max_y*cur_info['vy'];
  gctx.fillRect(xx,yy,MAPVIEW_SIZE*map_max_x,MAPVIEW_SIZE*map_max_y);
  gctx.globalAlpha = 1.0;
  drawMap();
}

function showGrid(){
  if($('#show_grid').prop('checked')){
    show_grid = true;
    gctx.fillStyle = EDITOR_LINE;
    gctx.globalAlpha = 0.2;
    for(var y=1; y<map_max_y; y++){
      gctx.fillRect(MAP_START_X+1,MAP_START_Y+y*MAP_SIZE,MAP_SIZE*map_max_x,1);
    }
    for(var x=2; x<map_max_x; x+=2){
      gctx.fillRect(MAP_START_X+MAP_SIZE*x+1,MAP_START_Y+1,1,MAP_SIZE*MAPPART_MAX_Y);
    }
    gctx.globalAlpha = 1.0;
  }else{
    show_grid = false;
    gctx.clearRect(MAP_START_X+1,MAP_START_Y,MAP_SIZE*map_max_x,MAP_SIZE*map_max_y);
  }
}
