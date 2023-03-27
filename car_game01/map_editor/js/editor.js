function drawMap(){
  var xx = MAP_START_X;
  var yy = MAP_START_Y;

  for(var i=0; i<map_table.length; i++){
    var row = map_table[i];
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
}

function drawMapParts(){
  var xx = MAPPART_START_X+1;
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
    xx = MAPPART_START_X+1;
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
  var xx = BGTILES_START_X;
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
  var xx = PALETTE_START_X;
  var yy = PALETTE_START_Y;
  var loop = Math.trunc(bg_palette.length/4);
  var y = 0;
  for(var l=0; l<loop; l++){
    var x = 0;
    for(var i=0; i<4; i++){
      vctx.fillStyle = gbc2htmlc(bg_palette[i+l*4]);
      vctx.fillRect(xx+x+1,yy+y+1,PALETTE_DOT,PALETTE_DOT);
      x += PALETTE_DOT;
    }
    y += PALETTE_DOT+1;
    bdrawText(xx+PALETTE_DOT*4+3,y-3,7,l);
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
  map_table[my][mx] = cur_info['psel'];
  drawMap();
}

function selectMapTable(){
  if(!edit_flag){
    edit_flag = 'edit_maptable';
    setMes(edit_flag);
    cur_info['psel'] = cur_info['px']+MAPPART_MAX_X*cur_info['py'];
    
    var xx = MAPPART_START_X+cur_info['px']*(MAPPART_SIZE*2+1);
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
    
  var xx = WIN_START_X+MAPPART_SIZE+cur_info['wx']*MAPPART_SIZE;
  var yy = WIN_START_Y+MAPPART_SIZE;
  cctx.globalAlpha = 0.2;
  cctx.fillStyle = EDITOR_BOX;
  cctx.fillRect(xx,yy,MAPPART_SIZE,MAPPART_SIZE);
  cctx.globalAlpha = 1.0;
}

function selectMapPart(){
  if(!edit_flag){
    edit_flag = 'edit_mappart';
    setMes(edit_flag);
    cur_info['psel'] = cur_info['px']+MAPPART_MAX_X*cur_info['py'];
    
    var xx = MAPPART_START_X+cur_info['px']*(MAPPART_SIZE*2+1);
    var yy = MAPPART_START_Y+cur_info['py']*(MAPPART_SIZE+1);
    cctx.globalAlpha = 0.2;
    cctx.fillStyle = EDITOR_BOX;
    cctx.fillRect(xx,yy,MAPPART_SIZE*2+1,MAPPART_SIZE+1);
    cctx.globalAlpha = 1.0;

    editMapPart();
  }
}

function updateMapPart(m){
  var xx = WIN_START_X+MAPPART_SIZE;
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
    drawMap();
  }else{
    drawMapPart(xx,yy,cmap_part,MAPPART_DOT,"w");
  }
}

function editMapPart(m){
  var xx = WIN_START_X+MAPPART_SIZE;
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
  var xx = WIN_START_X;
  var yy = WIN_START_Y;
  wctx.fillStyle = "#ffffff";
  wctx.globalAlpha = 0.7;
  wctx.fillRect(xx,yy,WIN_WIDTH_X,WIN_HEIGHT_Y);
  wctx.globalAlpha = 1.0;
  wdrowBox(xx,yy,WIN_WIDTH_X,WIN_HEIGHT_Y,EDITOR_LINE);
  $('#win_mappart').show();
}

function resetWin(){
  var x = WIN_START_X;
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
  var x = MAPPART_START_X;
  var y = MAPPART_START_Y;
  var w = (MAPPART_SIZE*2+1)*MAPPART_MAX_X;
  var h = (MAPPART_SIZE+1)*MAPPART_MAX_Y;
  cctx.clearRect(x,y,w,h);
}

function setMapPartCursor(){
  var xx = MAPPART_START_X+cur_info['px']*(MAPPART_SIZE*2+1);
  var yy = MAPPART_START_Y+cur_info['py']*(MAPPART_SIZE+1);
  cdrowBox(xx,yy,MAPPART_SIZE*2+1,MAPPART_SIZE+1,EDITOR_LINE);
}

function resetBgTablesCursor(){
  var x = BGTILES_START_X;
  var y = BGTILES_START_Y;
  var w = BGTILES_MAX_X*(BGTILES_SIZE+1);
  var h = BGTILES_MAX_Y*(BGTILES_SIZE+1);
  cctx.clearRect(x,y,w,h);
}

function setBgTablesCursor(){
  var xx = BGTILES_START_X+cur_info['bx']*(BGTILES_SIZE+1);
  var yy = BGTILES_START_Y+cur_info['by']*(BGTILES_SIZE+1);
  cdrowBox(xx,yy,BGTILES_SIZE+1,BGTILES_SIZE+1,EDITOR_LINE);
}

function resetMapTableCursor(){
  var x = MAP_START_X;
  var y = MAP_START_Y;
  var w = MAP_SIZE*MAP_MAX_X+1;
  var h = MAP_SIZE*MAP_MAX_Y+1;
  cctx.clearRect(x,y,w,h);
}

function setMapTableCursor(){
  var xx = MAP_START_X+cur_info['mx']*MAP_SIZE*2;
  var yy = MAP_START_Y+cur_info['my']*MAP_SIZE;
  cdrowBox(xx,yy,MAP_SIZE*2+1,MAP_SIZE+1,EDITOR_LINE);
}

function resetChangeMapPartCursor(){
  var x = WIN_START_X+MAPPART_SIZE;
  var y = WIN_START_Y+MAPPART_SIZE;
  var w = WIN_START_X+MAPPART_SIZE+MAPPART_SIZE*2;
  var h = WIN_START_Y+MAPPART_SIZE+MAPPART_SIZE;
  cctx.clearRect(x,y,w,h);
}

function setChangeMapPartCursor(){
  var xx = WIN_START_X+MAPPART_SIZE+cur_info['wx']*MAPPART_SIZE;
  var yy = WIN_START_Y+MAPPART_SIZE;
  cdrowBox(xx,yy,MAPPART_SIZE,MAPPART_SIZE,EDITOR_LINE);
}

function checkMapTableArea(){
  if(cur_info['x']>MAP_START_X
    && cur_info['y']>MAP_START_Y
    && cur_info['x']<MAP_START_X+MAP_SIZE*MAP_MAX_X
    && cur_info['y']< MAP_START_Y+MAP_SIZE*MAP_MAX_Y
    ){
    return true;
  }
  return false;
}

function checkMapPartArea(){
  if(cur_info['x']>MAPPART_START_X
    && cur_info['y']>MAPPART_START_Y
    && cur_info['x']<MAPPART_START_X+(MAPPART_SIZE*2+1)*MAPPART_MAX_X
    && cur_info['y']<MAPPART_START_Y+(MAPPART_SIZE+1)*MAPPART_MAX_Y
    ){
    return true;
  }
  return false;
}

function checkWinArea(){
  if(cur_info['x']>WIN_START_X
    && cur_info['y']>WIN_START_Y
    && cur_info['x']<WIN_START_X+WIN_WIDTH_X
    && cur_info['y']<WIN_START_Y+WIN_HEIGHT_Y
    ){
    return true;
  }
  return false;
}

function checkChangeMapPartArea(){
  if(cur_info['x']>WIN_START_X+MAPPART_SIZE
    && cur_info['y']>WIN_START_Y+MAPPART_SIZE
    && cur_info['x']<WIN_START_X+MAPPART_SIZE+MAPPART_SIZE*2
    && cur_info['y']<WIN_START_Y+MAPPART_SIZE+MAPPART_SIZE
    ){
    return true;
  }
  return false;
}

function checkBgTilesArea(){
  if(cur_info['x']>BGTILES_START_X
    && cur_info['y']>BGTILES_START_Y
    && cur_info['x']<BGTILES_START_X+(BGTILES_SIZE+1)*BGTILES_MAX_X
    && cur_info['y']<BGTILES_START_Y+(BGTILES_SIZE+1)*BGTILES_MAX_Y
    ){
    return true;
  }
  return false;
}

function showGrid(){
  if($('#show_grid').prop('checked')){
    gctx.fillStyle = EDITOR_LINE;
    gctx.globalAlpha = 0.2;
    for(var y=1; y<MAP_MAX_Y; y++){
      gctx.fillRect(MAP_START_X+1,MAP_START_Y+y*MAP_SIZE,MAP_SIZE*MAP_MAX_X,1);
    }
    for(var x=2; x<MAP_MAX_X; x+=2){
      gctx.fillRect(MAP_START_X+MAP_SIZE*x+1,MAP_START_Y+1,1,MAP_SIZE*MAPPART_MAX_Y);
    }
    gctx.globalAlpha = 1.0;
  }else{
    gctx.clearRect(MAP_START_X+1,MAP_START_Y,MAP_SIZE*MAP_MAX_X,MAP_SIZE*MAP_MAX_Y);
  }
}
