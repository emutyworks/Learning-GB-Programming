window.onload = function(){
  base = document.getElementById('base');
  bctx = base.getContext('2d');

  view = document.getElementById('view');
  vctx = view.getContext('2d');

  grid = document.getElementById('grid');
  gctx = grid.getContext('2d');

  win = document.getElementById('win');
  wctx = win.getContext('2d');

  cursor = document.getElementById('cursor');
  cctx = cursor.getContext('2d');

  loadInitData(init_load_data.split('\n'));
  initView();

  $(window).keydown(function(e){
    if(bin_upload){
      if(e.keyCode===27){
        if(edit_flag=='change_mappart'){
          changeMapPartCancel();
        }else{
          editCancel();
        }
        return false;
      }
    }
  });

  $(document).on('contextmenu',function(e){
    return false;
  });
  function onMouseUp(e){
    mouse_down = false;
    mousePos(e);
  }
  function onMouseDown(e){
    mouse_down = true;
    mousePos(e);

    if(e.which==3){
      if(edit_flag=='change_mappart'){
        changeMapPartCancel();
      }else{
        editCancel();
      }
      return false;
    }

    if(bin_upload){
      if(checkMapPartArea() && !edit_flag){
        setMes('select_mappart');
        resetMapPartCursor();
        setMapPartCursor();

        if(e.shiftKey){
          selectMapPart('edit');
        }else
        if(e.ctrlKey){
          selectMapPart('copy');
        } 
        else{
          selectMapTable();
        }
      }else
      if(checkMapPartArea() && edit_flag=='copy_mappart'){
        copyMapPart();
      }else
      if(checkMapTableArea() && edit_flag=='edit_maptable'){
        setMes('edit_maptable');
        resetMapTableCursor();
        setMapTableCursor();
        editMapTable();
      }
      if(checkWinArea() && edit_flag=='edit_mappart'){
        setMes('edit_mappart');
        if(checkChangeMapPartArea()){
          setMes('change_mappart');
          resetChangeMapPartCursor();
          setChangeMapPartCursor();
          changeMapPart();
        }
      }else
      if(checkBgTilesArea() && edit_flag=='change_mappart'){
        resetBgTablesCursor();
        setBgTablesCursor();
        setMapPart();
      }
    }
  }
  function onMouseMove(e){
    mousePos(e);
    help_flag = false;

    if(bin_upload){
      if(checkMapPartArea() && !edit_flag){
        setMes('select_mappart');
        resetMapPartCursor();
        setMapPartCursor();
      }else
      if(checkMapPartArea() && edit_flag=='copy_mappart'){
        resetMapPartCursor();
        setMapPartCursor();
      }else
      if(checkMapTableArea() && edit_flag=='edit_maptable'){
          setMes('edit_maptable');
          resetMapTableCursor();
          setMapTableCursor();
          if(mouse_down){
            editMapTable();
          }
      }else
      if(checkWinArea() && edit_flag=='edit_mappart'){
        setMes('edit_mappart');
        if(checkChangeMapPartArea()){
          setMes('change_mappart');
          resetChangeMapPartCursor();
          setChangeMapPartCursor();
        }
      }else
      if(checkBgTilesArea() && edit_flag=='change_mappart'){
        resetBgTablesCursor();
        setBgTablesCursor();
      }else
      if(!help_flag && !edit_flag){
        editCancel();
      }else
      if(edit_flag=='edit_maptable'){
        resetMapTableCursor();
      }
    }
  }
  cursor.addEventListener('mouseup', onMouseUp, false);
  cursor.addEventListener('mousedown', onMouseDown, false);
  cursor.addEventListener('mousemove', onMouseMove, false);

  function mousePos(e){
    var org_x = e.clientX;
    var org_y = e.clientY;
    var x = org_x-OFFSET_X;
    var y = org_y-OFFSET_Y;

    var bx = 0;
    var by = 0;
    if(x>bgtiles_start_x && y>BGTILES_START_Y
    && x<bgtiles_start_x+(BGTILES_SIZE+1)*BGTILES_MAX_X
    && y<BGTILES_START_Y+(BGTILES_SIZE+1)*BGTILES_MAX_Y
    ){
      bx = Math.trunc((x-bgtiles_start_x)/(BGTILES_SIZE+1));
      by = Math.trunc((y-BGTILES_START_Y)/(BGTILES_SIZE+1));
    }

    var px = 0;
    var py = 0;
    if(x > mappart_start_x && y > MAPPART_START_Y
      && x < mappart_start_x+(MAPPART_SIZE*2+1)*MAPPART_MAX_X
      && y < MAPPART_START_Y+(MAPPART_SIZE+1)*MAPPART_MAX_Y
    ){
      px = Math.trunc((x-mappart_start_x)/(MAPPART_SIZE*2+1));
      py = Math.trunc((y-MAPPART_START_Y)/(MAPPART_SIZE+1));
    }

    var wx = 0;
    var wy = 0;
    if(x > win_start_x+MAPPART_SIZE*15-3
      && y > WIN_START_Y+MAPPART_SIZE
      && x < win_start_x+MAPPART_SIZE+MAPPART_SIZE*16-3
      && y < WIN_START_Y+MAPPART_SIZE+MAPPART_SIZE
    ){
      wx = Math.trunc((x-(win_start_x+MAPPART_SIZE*15-3))/MAPPART_SIZE);
      wy = 0;
    }

    var mx = 0;
    var my = 0;
    if(x>MAP_START_X && y>MAP_START_Y
    && x<MAP_START_X+MAP_SIZE*map_max_x
    && y<MAP_START_Y+MAP_SIZE*map_max_y
    ){
      mx = Math.trunc((x-MAP_START_X)/(MAP_SIZE*2));
      my = Math.trunc((y-MAP_START_Y)/MAP_SIZE);
    }

    cur_info = {
      org_x: org_x,
      org_y: org_y,
      x: x,
      y: y,
      cx: cur_info['cx'],
      cy: cur_info['cy'],
      //bg tiles
      bx: bx,
      by: by,
      //map part
      px: px,
      py: py,
      wx: wx,
      wy: wy,
      psel: cur_info['psel'],
      wsel: cur_info['wsel'],
      //map table
      mx: mx,
      my: my,
    };
  }
}