pico-8 cartridge // http://www.pico-8.com
version 5
__lua__
-- foxy (we must play the fox)
-- entry for #lowrezjam 2016
-- miles, misato, mapedorr, cannonfiddle

-- change resolution to 64x64
poke(0x5f2c,3)

-- config stuff
config = {}
config.debug = false
config.music = true

tile_size = 8
-- total map size (we use 120 and up for splash
cols = 118
rows = 32
world_width = cols * tile_size
world_height = rows * tile_size
-- visible area
scene_width = 64
scene_height = 64
-- used for the scroll
camera_x = 0
camera_y = 0
splash = true

-- we'll use this one to limit the animation to certain frames. otherwise it's too fast.
animation_frames = 0

foxy = {}
foxy.position_x = 2
foxy.position_y = 2
foxy.speed = 1
foxy.lifes = 3
foxy.heart_sprite = 121
foxy.catch_wait = 10
-- indexes start in 1 in lua. wtf!
foxy.animation_index = 1
foxy.is_idle = false
-- this is to avoid calling table.getn(foxy.animation) every time.
-- i just read that if it can't return the size, it will traverse the array.
foxy.animation_size = 8
-- arrays containing the animation sprites
foxy.animation_idle = { 48, 49, 50, 51, 52, 53, 54, 55 }
foxy.animation_walk = { 16, 17, 16, 17, 16, 17, 16, 17 }
foxy.animation_speed = 3
foxy.current_animation = foxy.animation_idle

foxy.animations = {};
foxy.animations.walk = {};
foxy.animations.walk.left = { 34, 35, 34, 35, 34, 35, 34, 35 };
foxy.animations.walk.right = { 32, 33, 32, 33, 32, 33, 32, 33 };
foxy.animations.walk.up = { 18, 19, 18, 19, 18, 19, 18, 19 };
foxy.animations.walk.down = { 16, 17, 16, 17, 16, 17, 16, 17 };

foxy.animations.action = {};
foxy.animations.action.left = { 38, 39, 38, 39, 38, 39, 38, 39 };
foxy.animations.action.right = { 36, 37, 36, 37, 36, 37, 36, 37 };
foxy.animations.action.up = { 22, 23, 22, 23, 22, 23, 22, 23 };
foxy.animations.action.down = { 20, 21, 20, 21, 20, 21, 20, 21 };

foxy.animations.idle = {};
foxy.animations.idle.calm = { 0, 0, 0, 1, 0, 0, 0, 7 };
foxy.animations.idle.medium = { 48, 49, 50, 51, 51, 50, 49, 48 };
foxy.animations.idle.alert = { 0, 1, 2, 3, 4, 4, 6, 7 };


foxy.animations.victory_dance = { 54, 55, 54, 55, 53, 53, 52, 52 };
foxy.animations.rotation = { 0, 1, 2, 3, 4, 5, 6, 7 };

-- vars for chkickens creation
chickens_amount = 10
-- chickens_amount = 1
chickens = {}
chickens.animation_size = 8
chickens.chickens_array = {}
chickens.animations = {}
chickens.alert = {}
chickens.alert.sprite = 104
chickens.alert.visible = false
chickens.alert.position_x = 0
chickens.alert.position_y = 0
chickens.fieldview_sprite = 120
chickens.fox_found = false

chickens.animations.walk = {}
chickens.animations.walk.animation_speed = 7
chickens.animations.walk.down = { 80, 81, 80, 81, 80, 81, 80, 81 }
chickens.animations.walk.up = { 82, 83, 82, 83, 82, 83, 82, 83 }
chickens.animations.walk.left = { 66, 67, 66, 67, 66, 67, 66, 67 }
chickens.animations.walk.right = { 64, 65, 64, 65, 64, 65, 64, 65 }

chickens.animations.idle = {}
chickens.animations.idle.animation_speed = 3
chickens.animations.idle.peck = { 105, 106, 107, 108, 105, 105, 105, 105 }

-- game states
-- there are no enum in lua so followed the advice from here: https://www.allegro.cc/forums/thread/605178
game_states = {
    splash = 0,
    game = 1, 
    gameover = 2
}

state = game_states.splash

-- game functions

function _init()
	cls()
	generate_map()
    -- init music
	if config.music then
		music(0,1000,3)
	end
end

function _update()
    if state == game_states.splash then
        update_splash()
    elseif state == game_states.game then
        update_game()
    elseif state == game_states.gameover then
        update_game_over()
    end
end

function _draw()
    if state == game_states.splash then
        draw_splash()
    elseif state == game_states.game then
        draw_game()
    elseif state == game_states.gameover then
        draw_game_over()
    end
end


-- state change
function change_state()
	cls()
    if state == game_states.splash then
        state = game_states.game
        -- change music
		
		if config.music then
			music(8,0,3)
		end
		
        -- lets add some chickens endemoniados
        for i = 1, chickens_amount do
            -- chickens[0] has the animations for the chickens
            chickens.chickens_array[i] = create_chicken()
        end
    elseif state == game_states.game then
        state = game_states.gameover
    elseif state == game_states.gameover then
        -- state = game_states.splash
        music(12,1000,3)
    end
end

-- update states

-- this function is done for code consistency, because we only want to check the buttons here so it won't be necesary.
function update_splash()
    handle_buttons_splash()
end

function update_game()
    if foxy.lifes == 0 then
        state = game_states.gameover
        change_state()
        return
    end

    if chickens.alert.visible then
        foxy.catch_wait -= 1
        if foxy.catch_wait > 0 then
            return
        else
            foxy.catch_wait = 10
            foxy.position_x = 2
            foxy.position_y = 2
        end
    end

    -- move chickens! move!
    chickens.fox_found = false
    for i = 1, chickens_amount do
        chicken = chickens.chickens_array[i]

        update_chicken_timers(chicken)

        -- check if foxy is in front of me...yikes!
        -- if not chickens.alert.visible then
            update_chicken_movement(chicken)
            update_chicken_animation(chicken)
        -- end

        if not chickens.fox_found then
            lookfor_foxy(chicken)
        end
    end

    foxy.animation_speed -= 1
    -- if not chickens.fox_found then
        has_moved = handle_buttons_game()
    -- end

    if foxy.animation_speed == 0 then
      foxy.animation_speed = 10

      if has_moved then
        -- step sound
		if(config.music) then
			sfx(63,3)
		end
        foxy.animation_speed = 7
        foxy.is_idle = false
      elseif not foxy.is_idle then
        foxy.is_idle = true
        set_foxy_idle()
        foxy.animation_speed = 20
      end

      animate_foxy()
    end

  animation_frames += 1

  scroll_map()
end

function update_game_over()
    -- todo handle buttons game over
end

-- drawing states

function draw_splash()
    camera(camera_x,camera_y)
     -- draw the splash
    map(120,0, 0,0, pixels_to_tile(world_width), pixels_to_tile(world_height))
end



function draw_game()
    -- set camera in the desired position (used for the scroll)
    camera(camera_x,camera_y)

    -- draw the complete map
    map(0,0, 0,0, pixels_to_tile(world_width), pixels_to_tile(world_height))

    -- draw chickens field of view
    for i = 1, chickens_amount do
        chicken = chickens.chickens_array[i]
        spr(chickens.fieldview_sprite, chicken.fieldview_x, chicken.fieldview_y)
    end

    -- draw chickens
    for i = 1, chickens_amount do
        chicken = chickens.chickens_array[i]
        spr(chicken.current_animation[chicken.animation_index], chicken.position_x, chicken.position_y)
    end

	foxy_drawn = false
	for decor_index=1,decor_size do
		if (camera_x-8) < decor[decor_index].x and decor[decor_index].x < camera_x+72 and (camera_y-8) < decor[decor_index].y and decor[decor_index].y < camera_y+72 then
			if(not foxy_drawn and (foxy.position_y < decor[decor_index].y) ) then
				-- draw foxy
				spr(foxy.current_animation[foxy.animation_index], foxy.position_x, foxy.position_y)
				foxy_drawn= true
			end
			spr(decor[decor_index].sprite, decor[decor_index].x, decor[decor_index].y)
		end
	end
	if (not foxy_drawn) then 
		-- draw foxy
		spr(foxy.current_animation[foxy.animation_index], foxy.position_x, foxy.position_y)
	end
    if chickens.alert.visible then
        spr(chickens.alert.sprite, chickens.alert.position_x, chickens.alert.position_y)
    end

    -- draw the lifes of the fox
    for hearts=1,foxy.lifes do
        -- pset(camera_x+fox_x+48, camera_y+fox_y+48,9)
        spr(foxy.heart_sprite, camera_x + (scene_width - 8) - (tile_size * (hearts % foxy.lifes)), camera_y + 1)
    end

	if not config.debug then
		draw_minimap()
	else 
		draw_debug_minimap()
	end
end

function draw_game_over()
    camera(camera_x,camera_y)
     -- draw the splash
    map(120,8, 0,0, pixels_to_tile(world_width), pixels_to_tile(world_height))
end


-- input

function handle_buttons_splash()
    -- go to main game if you press any button (z,x or n,m)
    if btn(4) or btn(5) then
        change_state()
        sfx(62,3)
    end
end

function handle_buttons_game()
    has_moved = false
    -- left
    if btn(0) then
        if can_move(foxy.position_x - foxy.speed, foxy.position_y) then
            foxy.position_x -= foxy.speed
            has_moved = true
			foxy.current_animation = foxy.animations.walk.left
        end

    -- right
    elseif btn(1) then
        if can_move(foxy.position_x + foxy.speed, foxy.position_y) then
            foxy.position_x += foxy.speed
            has_moved = true
			foxy.current_animation = foxy.animations.walk.right
        end

    -- up
    elseif btn(2) then
        if can_move(foxy.position_x, foxy.position_y - foxy.speed) then
            foxy.position_y -= foxy.speed
            has_moved = true
			foxy.current_animation = foxy.animations.walk.up
        end

    -- down
    elseif btn(3) then
        if can_move(foxy.position_x, foxy.position_y + foxy.speed) then
            foxy.position_y += foxy.speed
            has_moved = true
			foxy.current_animation = foxy.animations.walk.down
        end
    end

    return has_moved
end

-- collision detection 

-- objects to collide with. these will be windows, walls, etc
collision_objects = { 71, 86, 87, 102, 103 }

function can_move(x, y)
    -- check the edges of the world first
    if x < 0 or x > world_width  or 
       y < 0 or y > world_height then
        return false
    end

    -- check if the tile is a collision object
    local tile = mget(pixels_to_tile(x),pixels_to_tile(y))


    for _ , value in pairs(collision_objects) do
        if value == tile then
            return false
        end
    end 

    return true
end

-- enemies behavior
function lookfor_foxy(chicken)
    chickens.alert.visible = false
    if (chicken.current_animation == chickens.animations.walk.down or chicken.current_animation == chickens.animations.idle.peck) then
        if (foxy_is_below(chicken)) then
            chickens.fox_found = true
            chickens.alert.visible = true
        end

    elseif (chicken.current_animation == chickens.animations.walk.right) then
        if (foxy_is_rightside(chicken)) then
            chickens.fox_found = true
            chickens.alert.visible = true
        end

    elseif (chicken.current_animation == chickens.animations.walk.up) then
        if (foxy_is_above(chicken)) then
            chickens.fox_found = true
            chickens.alert.visible = true
        end

    elseif (chicken.current_animation == chickens.animations.walk.left) then
        if (foxy_is_leftside(chicken)) then
            chickens.fox_found = true
            chickens.alert.visible = true
        end
    end

    if chickens.alert.visible then
        foxy.lifes -= 1
        chickens.alert.position_x = chicken.position_x
        chickens.alert.position_y = chicken.position_y - tile_size
        sfx(61,3)
    end
end

function foxy_is_below(chicken)
    if (foxy.position_y >= chicken.position_y and foxy.position_y <= (chicken.position_y + tile_size) + (chicken.fieldview_size * tile_size) - 3) then
        if ((foxy.position_x + 5 > chicken.position_x and foxy.position_x + 5 < chicken.position_x + tile_size) or (foxy.position_x >= chicken.position_x and foxy.position_x <= chicken.position_x + 4)) then
            return true
        end
    end
    return false
end

function foxy_is_rightside(chicken)
    if (foxy.position_x >= chicken.position_x and foxy.position_x <= (chicken.position_x + tile_size) + (chicken.fieldview_size * tile_size)) then
        if ((foxy.position_y + 5 > chicken.position_y and foxy.position_y + 5 < chicken.position_y + tile_size) or (foxy.position_y >= chicken.position_y and foxy.position_y <= chicken.position_y + 4)) then
            return true
        end
    end
    return false
end

function foxy_is_above(chicken)
    if (foxy.position_y + tile_size <= chicken.position_y and foxy.position_y + tile_size >= (chicken.position_y - tile_size * chicken.fieldview_size)) then
        if ((foxy.position_x + 5 > chicken.position_x and foxy.position_x + 5 < chicken.position_x + tile_size) or (foxy.position_x >= chicken.position_x and foxy.position_x <= chicken.position_x + 4)) then
            return true
        end
    end
    return false
end

function foxy_is_leftside(chicken)
    if ((foxy.position_x + 5 >= chicken.position_x - tile_size and foxy.position_x + 5 < chicken.position_x) or (foxy.position_x <= chicken.position_x and foxy.position_x >= chicken.position_x - tile_size)) then
        if ((foxy.position_y + 5 > chicken.position_y and foxy.position_y + 5 < chicken.position_y + tile_size) or (foxy.position_y >= chicken.position_y and foxy.position_y <= chicken.position_y + 4)) then
            return true
        end
    end
    return false
end


-- movement
function update_chicken_movement(chicken)
    if (chicken.in_idle == 0 and chicken.movement_speed == 0) then
        if (chicken.patrol_dir == 1) then
            chicken.position_y += chicken.movement_dir
        elseif (chicken.patrol_dir == 2) then
            chicken.position_x += chicken.movement_dir
        end

        if chicken.movement_dir == 1 then
            if (chicken.patrol_dir == 1) then
                if chicken.position_y >= chicken.original_y + chicken.max_distance then
                    chicken.movement_dir = -1
                    chicken.in_idle = chicken.wait_idle
                end
            elseif (chicken.patrol_dir == 2) then
                if chicken.position_x >= chicken.original_x + chicken.max_distance then
                    chicken.movement_dir = -1
                    chicken.in_idle = chicken.wait_idle
                end
            end
        elseif chicken.movement_dir == -1 then
            if (chicken.patrol_dir == 1) then
                if chicken.position_y <= chicken.original_y then
                    chicken.movement_dir = 1
                    chicken.in_idle = chicken.wait_idle
                end
            elseif (chicken.patrol_dir == 2) then
                if chicken.position_x <= chicken.original_x then
                    chicken.movement_dir = 1
                    chicken.in_idle = chicken.wait_idle
                end
            end
        end
    end
end

-- animations

function animate_foxy()
    foxy.animation_index += 1
    if foxy.animation_index > foxy.animation_size then
        foxy.animation_index = 1
    end
end

function set_foxy_idle()
	animind = flr(rnd(3))
	foxy.animation_index = 1
	if(animind==0) then
		foxy.current_animation = foxy.animations.idle.calm
	elseif (animind==1) then
		foxy.current_animation = foxy.animations.idle.medium
	else
		foxy.current_animation = foxy.animations.idle.alert
	end
end

function update_chicken_animation(chicken)
    if chicken.animation_speed == 0 then
        chicken.animation_index += 1
        if chicken.animation_index > chickens.animation_size then
            chicken.animation_index = 1
        end

        chicken.fieldview_x = chicken.position_x
        chicken.fieldview_y = chicken.position_y
        if (chicken.in_idle > 0) then
            chicken.current_animation = chickens.animations.idle.peck
            chicken.current_animation_speed = chickens.animations.idle.animation_speed
            chicken.fieldview_y = chicken.position_y + tile_size
        else
            chicken.current_animation_speed = chickens.animations.walk.animation_speed
            if (chicken.movement_dir == 1) then
                if (chicken.patrol_dir == 1) then
                    chicken.current_animation = chickens.animations.walk.down
                    chicken.fieldview_y = chicken.position_y + tile_size
                elseif (chicken.patrol_dir == 2) then
                    chicken.current_animation = chickens.animations.walk.right
                    chicken.fieldview_x = chicken.position_x + tile_size
                end
            elseif (chicken.movement_dir == -1) then
                if (chicken.patrol_dir == 1) then
                    chicken.current_animation = chickens.animations.walk.up
                    chicken.fieldview_y = chicken.position_y - tile_size
                elseif (chicken.patrol_dir == 2) then
                    chicken.current_animation = chickens.animations.walk.left
                    chicken.fieldview_x = chicken.position_x - tile_size
                end
            end
        end
    end
end

-- scroll

function coord_to_scroll(player_position, world_size, scene_size)
    if player_position <= scene_size/2 then
        return 0
    elseif player_position > (world_size - scene_size/2) then
        return world_size - scene_size
    else
        return player_position - scene_size / 2
    end
end

function scroll_map()
    -- update camera coordenates
    camera_x = coord_to_scroll(foxy.position_x, world_width, scene_width)
    camera_y = coord_to_scroll(foxy.position_y, world_height, scene_height)
end

-- util

-- since there's no math.ceil, we have to implement ourselves. 
-- solution seen in https://gist.github.com/josefnpat/bfe4aaa5bbb44f572cd0
function ceil(x) 
    return -flr(-x)
end

function tile_to_pixels(tile)
    return tile * tile_size
end

function pixels_to_tile(pixel)
    return ceil(pixel / tile_size)
end

function create_chicken()
    chicken = {}

    -- properties for drawing position
    chicken.position_x = tile_to_pixels(flr(rnd(18)))
    -- chicken.position_x = 20
    chicken.original_x = chicken.position_x
    chicken.position_y = tile_to_pixels(flr(rnd(6)) + 1)
    -- chicken.position_y = 20
    chicken.original_y = chicken.position_y

    -- properties for movement handling
    chicken.movement_dir = 1
    chicken.patrol_dir = flr(rnd(2)+1)
    -- chicken.patrol_dir = 1
    chicken.movement_speed = 1
    chicken.ori_movement_speed = chicken.movement_speed
    chicken.max_distance = tile_to_pixels(4 + rnd(4))
    if (chicken.patrol_dir == 1 and tile_to_pixels(chicken.position_y + chicken.max_distance) > world_height - 8) then
        chicken.max_distance = ((world_height - 8) - tile_to_pixels(chicken.position_y)) / 8
    elseif (chicken.patrol_dir == 2 and tile_to_pixels(chicken.position_x + chicken.max_distance) > world_width - 8) then
        chicken.max_distance = ((world_width - 8) - tile_to_pixels(chicken.position_x)) / 8
    end

    -- properties for animation
    chicken.current_animation = chickens.animations.idle.peck
    chicken.current_animation_speed = chickens.animations.idle.animation_speed
    chicken.animation_speed = chicken.current_animation_speed
    chicken.animation_index = 1

    -- properties for timers
    chicken.wait_idle = 60
    chicken.in_idle = chicken.wait_idle

    -- properties for field of view
    chicken.fieldview_size = 1
    chickens.alert_visible = false

    return chicken
end

function update_chicken_timers(chicken)
    if (chicken.in_idle > 0) then
        chicken.in_idle -= 1
    end
    
    if (chicken.movement_speed > 0) then
        chicken.movement_speed -= 1
    else
        chicken.movement_speed = chicken.ori_movement_speed
    end

    if (chicken.animation_speed > 0) then
        chicken.animation_speed -= 1
    else
        chicken.animation_speed = chicken.current_animation_speed
    end
end

-- map generator
foliage ={84, 89, 90, 91}
decors = {76, 77, 78, 79, 92, 93, 94, 95}
decor = {}
decor_size = 0;

function generate_map()
	-- initialize grass
	add_grass()
	
	-- dungeon maze hybrid
	generate_base()
	
	-- add foliage and decor
	 add_decor()
	
	-- add chickens and eggs
	 
end

rectangles = {}
function generate_base()
	-- add the buildings
	add_rectangles(30)
	draw_rectangles()

	-- add the roads
	maze_gen()
	
	-- add doors 
	add_doors()
end

horizontal_segs = {}
function add_doors()
	segment = {}
	for y=0,rows do
		for x=0,cols do
			if(mget(x,y)==71 and (mget(x,y+1)==70 or mget(x,y-1)==70) and (mget(x,y+1)==85 or mget(x,y-1)==85)) then
				seg_piece = {x=x,y=y}
				add(segment, seg_piece)
			elseif(#segment>0) then
				add(horizontal_segs, segment)
				segment = {}
			end
		end
	end
	for segment in all(horizontal_segs) do
		door_loc = segment[flr(rnd(#segment)+1)]
		mset(door_loc.x, door_loc.y,  100)
	end
end

expandable = {x=0, y=0, dirs = {1,2,3,4}}
expandables = {expandable}
function maze_gen()
mset(0,0,70)
	-- generate dense maze
	while #expandables>0 do
		maze_step(expandables[flr(rnd(#expandables)+1)])
	end
	
	-- sparseness step
	sparseness=3
	roads_to_remove = {}
	for i=0,sparseness do
		for x=0,cols do
			for y=0,rows do
				if(mget(x,y)==70 and dead_end(x,y)) then
					add(roads_to_remove, {x=x, y=y})
				end
			end
		end
		for road in all(roads_to_remove) do
			mset(road.x, road.y, 68)
		end
	end
	for x=0,cols do
		for y=0,rows do
			if(not mget(x,y)==70 or (mget(x-1,y)==70 and mget(x+1,y)==70) or (mget(x,y-1)==70 and mget(x,y+1)==70)) then
				mset(x,y,70)
			end
		end
	end
end

function dead_end(x,y)
	sides = 0
	if(mget(x, y-1)==70) then
		sides+=1
	end
	if(mget(x+1, y)==70) then
		sides+=1
	end
	if(mget(x, y+1)==70) then
		sides+=1
	end
	if(mget(x-1, y)==70) then
		sides+=1
	end
	if sides<=1 then
		return true
	end
	return false
end

function maze_step(exp)
	if(#exp.dirs<=0) then
		del(expandables, exp)
		return 
	end
	dir = exp.dirs[flr(rnd(#exp.dirs)+1)]
	del(exp.dirs, dir)
	if(dir==1) then
		if(is_grass(exp.x, exp.y-2)) then
			mset(exp.x, exp.y-1, 70)
			mset(exp.x, exp.y-2, 70)
			new_exp = {x=exp.x, y=exp.y-2, dirs={1,2,4}}
			add(expandables, new_exp)
		end
	elseif(dir==2) then
		if(is_grass(exp.x+2, exp.y)) then
			mset(exp.x+1, exp.y, 70)
			mset(exp.x+2, exp.y, 70)
			new_exp = {x=exp.x+2, y=exp.y, dirs={1,2,3}}
			add(expandables, new_exp)
		end
	elseif(dir==3) then
		if(is_grass(exp.x, exp.y+2)) then
			mset(exp.x, exp.y+1, 70)
			mset(exp.x, exp.y+2, 70)
			new_exp = {x=exp.x, y=exp.y+2, dirs={2,3,4}}
			add(expandables, new_exp)
		end
	else
		if(is_grass(exp.x-2, exp.y)) then
			mset(exp.x-1, exp.y, 70)
			mset(exp.x-2, exp.y, 70)
			new_exp = {x=exp.x-2, y=exp.y, dirs={1,3,4}}
			add(expandables, new_exp)
		end
	end
end

function valid_road_spot(x,y)
	-- no crossovers 
	if(road_placable(x-1,y) and road_placable(x+1,y)) then
		return false
	elseif(road_placable(x,y-1) and road_placable(x,y+1)) then
		return false
	elseif(road_placable(x-1,y-1) and road_placable(x+1,y+1)) then
		return false
	elseif(road_placable(x+1,y-1) and road_placable(x-1,y+1)) then
		return false
	end
	return true
end

function road_placable(x,y) 
	if(mget(x,y)==70 or mget(x,y))==85 then
		return true
	end
	return false
end

road_worker = {x=1, y=1, dirs={1,2,3,4}, dir=flr(rnd(4)+1), prob=0.1}
workers = {road_worker}
function add_roads()
	-- place workers on map
	for x=0,cols do
		for y=0,rows do
			if is_grass(x,y) then
				if(rnd(1)<0.005) then
					add(workers, {x=x, y=y, dirs={1,2,3,4}, dir=flr(rnd(4)+1), prob=0.1})
				end	
			end
		end
	end

	-- while alive workers
	while #workers>0 do
		-- for each worker take 1 step
		for worker in all(workers) do
			worker_step(worker)
		end
	end
end

function worker_step(worker)
	mset(worker.x, worker.y, 70)
	take_step(worker)
	if(rnd(1)<worker.prob) then
		worker.dir = worker.dirs[flr(rnd(#worker.dirs)+1)]
		if(rnd(1)<0.01) then
			new_worker = {x=worker.x, y=worker.y, dir=1, dirs={1,2,3,4}, prob=0.1}
			add(workers, new_worker)
		end
	end	

	if(#worker.dirs<=0) then
		del(workers, worker)
	end	
	
end

function take_step(worker) 
	if(worker.dir==1) then
		if worker.y-1>0 and is_grass(worker.x, worker.y-1)  then
			worker.dirs = {1,2,3,4}
			worker.y -= 1
		else
			del(worker.dirs, 1)
			worker.dir = worker.dirs[flr(rnd(#worker.dirs)+1)]
		end
	elseif(worker.dir==2) then
		if worker.x+1<cols-1 and is_grass(worker.x+1, worker.y)  then
			worker.dirs = {1,2,3,4}
			worker.x+=1
		else
			del(worker.dirs, 2)
			worker.dir = worker.dirs[flr(rnd(#worker.dirs)+1)]
		end
	elseif(worker.dir==3) then
		if worker.y+1<rows-1 and is_grass(worker.x, worker.y+1)  then
			worker.dirs = {1,2,3,4}
			worker.y+=1
		else
			del(worker.dirs, 3)
			worker.dir = worker.dirs[flr(rnd(#worker.dirs)+1)]
		end
	else
		if worker.x-1>0 and is_grass(worker.x-1, worker.y) then
			worker.dirs = {1,2,3,4}
			worker.x-=1
		else
			del(worker.dirs, 4)
			worker.dir = worker.dirs[flr(rnd(#worker.dirs)+1)]
		end
	end

end

function add_rectangles(retries)
	orig_retries = retries
	while(retries>0) do
		rect_w = flr(rnd(6))*2+4
		rect_h = flr(rnd(4))*2+4
		rect_x = flr(rnd((cols - rect_w-4)/2)+4)*2-1
		rect_y = flr(rnd((rows - rect_h)/2))*2-1
		rect_placable = true
		for i=1,#rectangles do 
			rect = rectangles[i]
			if (rect.x <= rect_x+rect_w-2 and rect.x+rect.w-2 >= rect_x )then
				if (rect.y <= rect_y+rect_h and rect.y+rect.h >= rect_y) then
					rect_placable = false
					retries -= 1
					break
				end			
			end
		end
		if(rect_placable) then
			retries = orig_retries
			add(rectangles, {x=rect_x, y=rect_y, w=rect_w, h=rect_h})
		end
	end
end

function draw_rectangles()
	for i=1,#rectangles do 
		rect = rectangles[i]
		for x=rect.x,rect.x+rect.w do
			for y=rect.y,rect.y+rect.h do
				mset(x,y,85)
			end
		end
	end
	for x=0,cols do
		for y=0,rows do
			if mget(x,y)==85 then
				if 	is_grass(x-1,y-1) or
					is_grass(x-1,y) or
					is_grass(x-1,y+1) or
					is_grass(x,y-1) or
					is_grass(x,y+1) or
					is_grass(x+1,y-1) or
					is_grass(x+1,y) or
					is_grass(x+1,y+1) then
					mset(x,y,71)
				end
			end
		end		
	end
end


-- function to lay out grass
function add_grass()
	for x=0,cols do
		for y=0,rows do
			if (flr(rnd(100))<=75) then
				mset(x,y,68)
			else 
				mset(x,y,69)
			end
		end		
	end
end

roads ={}
roads_index = 1


-- function to make buildings
function add_buildings()

	--[[
	for i=0,flr(rnd(8))+8 do
		add_building()
	end
	for x=0,cols do
		for y=0,rows do
			if mget(x,y)==85 then
				if is_grass(x-1,y) or
					is_grass(x+1,y) or
					is_grass(x,y-1) or
					is_grass(x,y+1) then
					mset(x,y,71)
				end
			end
		end		
	end
	]]--
end

-- algorithm for building is drop random rectangles (may overlap)
function add_building()
	pos_x = flr(rnd(cols))
	width = flr(rnd(16))+8
	if(pos_x+width>=cols) then
		pos_x -= width
	end
	
	pos_y = flr(rnd(rows))
	height = flr(rnd(16))+8
	if(pos_y+height>=rows) then
		pos_y -= height
	end
	
	for x=pos_x,pos_x+width do
		for y=pos_y,pos_y+height do
			mset(x,y,85)
		end		
	end
end

function add_decor()
	for y=0,rows do
		for x=0,cols do
			if mget(x,y)==85 then 
				add_random_decor(x*8,y*8)
			elseif is_grass(x,y) then 
				add_bush(x*8,y*8)
			end
		end		
	end
end

function add_random_decor(x,y)
	if (flr(rnd(100))<=10) then
		decor_size += 1
		decor[decor_size] = {}
		decor[decor_size].x = x
		decor[decor_size].y = y
		random_number = flr(rnd(8))+1
		decor[decor_size].sprite = decors[random_number]
	end
end

function add_bush(x,y)
	if (flr(rnd(100))<=25) then
		decor_size += 1
		decor[decor_size] = {}
		decor[decor_size].x = x
		decor[decor_size].y = y
		random_number = flr(rnd(4))+1
		decor[decor_size].sprite = foliage[random_number]
	end
end

function is_grass(x,y)
	if mget(x,y)==68 or mget(x,y)==69 then 
		return true
	end
end


-- draw minimap
-- uses bottom right 4 cells to draw minimap
function draw_minimap()
	-- draw pixels 
	start_x = camera_x/8
	start_y = camera_y/8
	
	if( start_x+16>world_width/8) then
		start_x = world_width/8 -16
	end
	if( start_y+16>world_height/8) then
		start_y = world_height/8 -16
	end
	
	for x=0,16 do
		for y=0,16 do
			tile = mget(start_x+x,start_y+y)
			tile_x = tile%16
			tile_y = tile/16
			color = sget(tile_x*8+1,tile_y*8+1)

			pset(camera_x+48+x,camera_y+48+y,color)
		end
	end
	
	fox_x = flr( ( (foxy.position_x-start_x*8))/8)
	fox_y = flr( ( (foxy.position_y-start_y*8))/8)
	pset(camera_x+fox_x+48, camera_y+fox_y+48,9)
end

function draw_debug_minimap()
	-- draw pixels 
	start_x = camera_x/8
	start_y = 0
	
	if( start_x+64>world_width/8) then
		start_x = world_width/8 - 64
	end
	
	for x=0,64 do
		for y=0,32 do
			tile = mget(start_x+x,start_y+y)
			tile_x = tile%16
			tile_y = tile/16
			color = sget(tile_x*8+1,tile_y*8+1)

			pset(camera_x+x,camera_y+y+32,color)
		end
	end
	
	fox_x = flr( ( (foxy.position_x-start_x*8))/8)
	fox_y = flr( ( (foxy.position_y-start_y*8))/8)
	pset(camera_x+fox_x, camera_y+fox_y+32,9)
end

__gfx__
08800880088008800880088008800880088008800880088008800880088008800000000000000000000888000088800000000000000000000000000000000000
08999980089999800899999008999880088998800889998009999980089999800008880000888000008888000088880000000000000000000000000000000000
09999990099999900999999009999990099999900999999009999990099999900088889999888800008849999994880000000000000000000000000000000000
07199170097199100997199009999990099999900999999009917990019917900088499999948800008899999999880000000000000000000000000000000000
07711770097711700997711009999970079999700799999001177990071177900088999999998800009999999999990000000000000000000000000000000000
00dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd000099999999999900009999999999990000000000000000000000000000000000
09dddd90009ddd90009ddd00088dd90000d88d00009dd88000ddd90000ddd90000779999999977000077c19999c1770000000000000000000000000000000000
00900900000909000009900000909000009009000009090000099000009090000077119999117700007711999911770000000000000000000000000000000000
088008800880088008800880088008800880088008800880088008800880088000777c7117c77700007777711777770000000000000000000000000000000000
08999980089999800889988008899880089999800899998008899880088998800007991111997000000777111177700000000000000000000000000000000000
0999999009999990099999900999999009999990099999900999999009999990000099dddd99000000000dddddd0990000000000000000000000000000000000
07199170071991700999999009999990071991700719917009999990099999900000dddddddd00000099dddddddd990000000000000000000000000000000000
07711770077117700799997007999970077117700771177007999970079999700000dddddddd00000099dddddddd000000000000000000000000000000000000
09dddd0000dddd9000dddd0000dddd0000ddd900009ddd0000dddd0000dddd000000d99dd99d00000000ddddd99d000000000000000000000000000000000000
00dddd9009dddd0000d88d0000d88d00009ddd0000ddd90000dd88000088dd000000099009900000000009900990000000000000000000000000000000000000
00000900009000000000090000900000009009000090090000900900009009000000000000000000000009900000000000000000000000000000000000000000
08800880088008800880088008800880088008800880088008800880088008800000000000000000000000000000000000000000000000000000000000000000
08999990089999900999998009999980089999900899999009999980099999800000000000000000000000000000000000000000000000000000000000000000
09999990099999900999999009999990099999900999999009999990099999900000000000000000000000000000000000000000000000000000000000000000
09971990099719900991799009917990099719900997199009917990099179900000000000000000000000000000000000000000000000000000000000000000
09977110099771100117799001177990099771100997711001177990011779900000000000000000000000000000000000000000000000000000000000000000
00dddd90009ddd0009dddd0000ddd90000d9dd0000dddd9000dd9d0009dddd000000000000000000000000000000000000000000000000000000000000000000
009ddd0000dddd9000ddd90009dddd0000dddd9000d9dd0009dddd0000dd9d000000000000000000000000000000000000000000000000000000000000000000
00000900000900000090000000009000000990000009900000099000000990000000000000000000000000000000000000000000000000000000000000000000
08800880088008800880088008800880080000800800008008800880088008800000000000000000000000000000000000000000000000000000000000000000
08999980089999900999998008999980099999900999999008999980089999800000000000000000000000000000000000000000000000000000000000000000
09999990097199100199179009999990071991700719917009999990099999900000000000000000000000000000000000000000000000000000000000000000
07719910097711700711779001991770077117700771177007199170071991700000000000000000000000000000000000000000000000000000000000000000
07771170099777000777799007117770077777700777777007711770077117700000000000000000000000000000000000000000000000000000000000000000
00dddd0000dddd0000dddd0000dddd0009dddd9000dddd0009dddd0000dddd900000000000000000000000000000000000000000000000000000000000000000
09dddd9009dddd9009dddd9009dddd9000dddd0009dddd9000dddd9009dddd000000000000000000000000000000000000000000000000000000000000000000
00900900009009000090090000900900009009000090090000900000000009000000000000000000000000000000000000000000000000000000000000000000
00008800000088000088000000880000bbbbbbbbbbbbbbbb666666664555455545554555bbbbbbbbbbbbbbbbbbbbbbbb09899800077777700577775000000000
00007770000077700777000007770000bbbbbb3bb3bbbbbb666666664444444449999994bb44d4bbbb4444bbbb44d4bb09888890071111700517775000666600
00007170000071700717000007170000bbb3bbbbbbbbb3bb666666665545554559444495b4444d4bb458854bb884488b98888889071111700517775006555560
00007799000077999977000099770000bbbbbbbbbbbbbbbb666666664444444449444494bd44444bb577775bb899998b9888888957111175057775500d666660
07777770077777700777777007777770bbbbbbbbbbbbbbbb666666664555455549444495b5d4444bb517715bb999999b8888888857777775055555500d666660
00777770007777700777770007777700bbbbb3bbbbb3bbbb666666664444444449444494b5555d5bb579975bb719917b0006600055555555055555500d666660
00077700000777000077700000777000b3bbbbbbbbbbbbbb666666665545554559444495bb5555bbbb6776bbbb6116bb000d6000d00000060d0000600d666660
00009000000009000009000000900000bbbbbbbbbbbbbbb3666666664444444449444494bbbbbbbbbbbbbbbbbbbbbbbb00dd6600d00000060d00006000dd6600
0088880000888800008888000088880000033300444444444555455545554555777777770000000000000000000000000800000000000080000b700000800000
007777000077770000788700007887000033333044444444466666644666666477777777000333000033300000333300080000000000008007bbbb000858b000
0017710000177100007777000077770003838b3344444444561111655671116577777777003333300333330003333330080000000000008000b7bb7000800b30
00799700007997000077770000777700333333334444444446111164461111647777777703838b333838b33003838b33080000000000008007bbbb0000000b00
0777777000777700077777700777777033b3383344444444461111654611116577777777333333333333333333333333088888000088888000bbb7000000b000
00777700077777700077770000777700383333334444444446666664466666647777777733b338333b33833333b33833088888000088888005b7bb5005555550
0077770000777700007777000077770033333330444444445545554555455545777777773333333033333333333333300d000d0000d000d0053bbb5000555500
0000900000090000000090000009000003333330444444444444444444444444777777770333333003333330033333300d000d0000d000d00555555000555500
000ff000000000000000000000000000455545554555455566666666666666660ffffff000888800000000000007700000000000000000000000000000000000
00f77f00000ff00000ff00000000ff0049999994499999946c7cccc66cccc7c60ff88ff000777700008888000008800000077000000000000000000000000000
0f7777f000f77f000f77f000000f77f059666695596666956cc7ccc66cccccc60ff88ff000177100007777000088880000077000000000000000000000000000
0f7777f00f7777f0f7777f0000f7777f49666694496666946cccccc66cccccc60ff88ff000799700001771000077770000777700000000000000000000000000
f777777ff777777ff77777f00f77777f49999995499999956cccccc66cccccc60ffffff000777700007997000017710000777700000000000000000000000000
6777777f6777777f6777777ff777777f4999aa9449aa99946cccccc66cccccc60ff88ff000777700007777000079970000788700000000000000000000000000
067777f0067777f0067777f0067777f0599999955999999566666666666666660ffffff000777700007777000077770000888800000000000000000000000000
0066ff000066ff000066ff000066ff0049999994499999944444444444444444000ff00000099000000990000009900000099000000000000000000000000000
000f1000000f10000070070700000000000000000000000000000000000aa0000200200200000000000000000000000000000000000000000000000000000000
00f71f0000f71f0070000000700aa000000aa00000aa00000000aa0000aaaa00200200200ee0fe00000000000000000000000000000000000000000000000000
0f7177f00f7177f00700007000aaaa0700aaaa000aaaa000000aaaa0001aa10000200200eeee7fe0000000000000000000000000000000000000000000000000
0f7777f00f7717f00f0777f00f1aa100001aa10001aa10000001aa1000a88a0002002002eeeee7f0000000000000000000000000000000000000000000000000
f777777ff717771ff777777ff7a88a7f00a88a000a88a000000a88a00aaaaaa0200200208eeeeef0000000000000000000000000000000000000000000000000
6777777f6777777f6777777f6777777f0aaaaaa000aaaaa00aaaaa0000aaaa000020020008eeee00000000000000000000000000000000000000000000000000
067777f0067777f0067777f0067777f000aaaa000aaaaa0000aaaaa000aaaa0002002002008ee000000000000000000000000000000000000000000000000000
0066ff000066ff000066ff000066ff00009aa900009aa900009aa900009aa9002002002000080000000000000000000000000000000000000000000000000000
00077000000070000007700000077000007007000077770000077000007777000007700000077000000770000077700000077000007770000077770000777700
00700700000770000070070000700700007007000070000000700700000007000070070000700700007007000070070000700700007007000070000000700000
00700700007070000000070000000700007007000070000000700000000007000070070000700700007007000070070000700000007007000070000000700000
00707700000070000000070000077000007007000007700000777000000077000007700000077700007777000077700000700000007007000077700000777000
00770700000070000000700000000700000777000000070000700700000700000070070000000700007007000070070000700000007007000070000000700000
00700700000070000007000000000700000007000000070000700700000700000070070000000700007007000070070000700000007007000070000000700000
00700700000070000070000000700700000007000070070000700700007000000070070000700700007007000070070000700700007007000070000000700000
00077000007777000077770000077000000007000007700000077000007000000007700000077000007007000077700000077000007770000077770000700000
00077000007007000077770000007700007007000070000000700700007007000007700000777000000770000077700000077000007777000070070000700700
00700700007007000007700000000700007007000070000000777700007007000070070000700700007007000070070000700700000770000070070000700700
00700000007007000007700000000700007070000070000000777700007707000070070000700700007007000070070000700000000770000070070000700700
00707700007777000007700000000700007700000070000000700700007077000070070000777000007007000077700000077000000770000070070000700700
00700700007007000007700000000700007070000070000000700700007007000070070000700000007007000070070000000700000770000070070000077000
00700700007007000007700000000700007070000070000000700700007007000070070000700000007007000070070000000700000770000070070000077000
00700700007007000007700000700700007007000070000000700700007007000070070000700000007077000070070000700700000770000070070000077000
00077000007007000077770000077000007007000077770000700700007007000007700000700000000777000070070000077000000770000007770000077000
0070070000700700007007000077770000077000000770000000000011111111111111111111111111111111cccccccccccccccc111111111111111100000000
00700700007007000070070000000700000770000070070007000070177777171177177717711717177717771111111111111111171171717771771100000000
00700700007007000070070000007000000770000000070070700707711171717171717171171717117111711777117117171777717171717111717100000000
00700700000770000007770000007000000770000007700000000000171171777177117171171717117111717111171717771711717171717711771100000000
00700700007007000000070000070000000770000007000000000000117171717171717171771717117111717177177717171771717171717111717100000000
00777700007007000000070000070000000000000007000007000070771171717171717117771177177711717117171717171711171117117771717100000000
00777700007007000070070000700000000770000000000000777700111111111111111111111111111111111777171717171777111111111111111100000000
00700700007007000007700000777700000770000007000000000000cccccccccccccccccccccccccccccccc1111111111111111cccccccccccccccc00000000
0000000000000000008888000000000000066000000000000000000000000000000000000000000000000000cccccccc11111111000000000000000000000000
000770000007700008aaaa8000066000006006000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000
000770000007700008a00a8000600600006006000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000
000000000000000008a00a8000600600006000000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000
00000000000000008aaaaaa800999900009999000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000
00077000000770008aa00aa800999900009999000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000
00077000000070008aaaaaa800999900009999000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000
000000000000000088888888009999000099990000000000000000000000000000000000000000000000000011111111cccccccc000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111177777117777711111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117771111777111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddd11111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111199dddddddd9911111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111199dddddddd9911111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddd1111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111199119911111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111199119911111111111111111111111111111
11111111117117111177771111711711117117111117711111777711111111111111111111777711117117111177771111777711111771111171171111111111
11111111117117111171111111777711117117111171171111177111111111111111111111177111117117111171111111711111117117111171171111111111
11111111117117111171111111777711117117111171111111177111111111111111111111177111117117111171111111711111117117111171171111111111
11111111117117111177711111711711117117111117711111177111111111111111111111177111117777111177711111777111117117111117711111111111
11111111117117111171111111711711117117111111171111177111111111111111111111177111117117111171111111711111117117111171171111111111
11111111117777111171111111711711117117111111171111177111111111111111111111177111117117111171111111711111117117111171171111111111
11111111117777111171111111711711117117111171171111177111111111111111111111177111117117111171111111711111117117111171171111111111
11111111117117111177771111711711111777111117711111177111111111111111111111177111117117111177771111711111111771111171171111111111
11111111111111111177711111711111111771111171171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111171171111711111117117111171171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111171171111711111117117111171171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111177711111711111117777111117771111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111171111111711111117117111111171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111171111111711111117117111111171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111171111111711111117117111171171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111171111111777711117117111117711111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111188811118881111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111888811118888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111884999999488111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111889999999988111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111999999999999111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111999999999999111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111177c19999c177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111771199991177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
__gff__
0202020200020202000000000000000002020202020202020000000000000000020202020202020200000000000000000202020202020202000000000000000002020202010101040603010100000000020202020401040401000000000000000602020200000000000000000000000002020202020202020000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
444444444444444646475555555547464644444445454545454545454545454444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444c0c1c2c3c4c5c6c7
444444444444444646475555605547464644444445454545454545454545454444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d0d1d2d3d4d5d6d7
444444444444454646475555555547404644444445454545454545454545454444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444e0e1e2e3e4e5e6e7
444444444444444646476664566747464644444445454545454545454545454444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444f0f1f2f3f4f5f6f7
464646464646464646464646464646464644444445454545454545454544444444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444c8c9cacbcccdcecf
464646464646464646464646464646466044444445454545454545454545454444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444d8d9dadbdcdddedf
474766474847474646444444444444444444444445454545454545454545454444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444e8e9eaebecedeeef
475555555555474646444444444444444444444445454545454545454545454444444444444444454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444f8f9fafbfcfdfeff
475555555555474646444444444444444444444445454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444bbbbbbabacbbbbbb
474766644747474646454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444bcbcbcadaebcbcbc
464646464646464646454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b6b6bab5b5bab6b6
464646464646464646454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b6b6b60809b6b6b6
454545454545454646454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b640b61819b642b6
454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b6b6b6bebeb6b6b6
454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b6b660b08382b6b6
454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b6b6b6b6b6b6b6b6
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
__sfx__
01140020003700036000350213401f3701f3601f3501f3401a3001a0001a3501a3401c3701c3601c3501c3401d3701d3601d3501d3401f3701f3601f3501f3402430023300183501834024370243602435024340
01140020242701c20021250262401f27024260262502824024270262601f2501d20029270242602625010200262701720021250242401f27028200182501c24024270262502b2400020029240262302423000200
011400200c2701025015230152100c2700c25015230102100c2700e25015230152100c2700c250152300e2100c2700e25013230132100c2700c250132300e2100c2700c25013230132100c2700c250132300e210
011000001c300283001c3001c3001030010301023012b3012f3001c3002b30013300000001f30000000103002830018000343001c30110301233011c300000002f3002d3002b300243001c300000002830000000
01140000263702636026350263402137021360213502134000300003001f3501f340183701836018350183401d3701d3601d3501d3401f3701f3601f3501f3400030000300183501834024370243602435024340
01140020102700e2501323017200172700c200132300e210172700c250132300c200172700c20013230172100c27017250112300c2000e2701120011230172100c2700c200112300c2100e2700c250112300e210
0114002026270002001f250262401f27000200282502824000200262601f250002002927000200262500020026270002001d25024240292700020024250292402327023260282500020029270262602325000200
0114000024370243602435024340233702336023350233401a3001a3001a3501a3401d3701d3601d3501d340213702136021350213401f3701f3601f3501f340003000030018350183401a3701a3601a3501a340
011400001f3701f3701f3701f3702637026370263702637000300003001f3701f3701a3701a3701a3701a3701d3701d3701d3701d3702437024370243702437000300003001a3701a3701f3701f3701f3701f370
011800200c310243002b3002b3001333024300173502430018370243001335024300103301830009320243000c32024300243002430013330243001035024300183002430013350243000e330243000732024300
011800200c3700c3000c370003000030000300183701737018370003001c37010300003000030009370003000c3700c3000c37000300003000030017370003001737000300053701130005370113000737000300
01180020185701c5002350000000000001c5702b57000000000000000000000295702357000000265702857018570245700000023570000001c57000000000000000000000215700000023570000002657000000
011800201857000000000000000000000000001c5701c5601c5501c5401c5301c5202357000000265700000018570245702450023570235001c5701c500000001f5701f54021570000001f570000001d57000000
0130002024375233751f3751c3751f500000001c5000000024375233751f3751c3751a375000000000024305233052437523375213751f3751c375000000000024375233751f3751c37518375000001a37500000
01300020243751f3051f3750000000000233752330500000213750000023305000001f375000002337500000243750000023305000001f3750000023375000001f3751f30500000000001d375000001c3751d375
01300020243751f3051f37500005000052337523305000052f3750000523305000051f375000052337500005243750000523305000051d3750000523375000051f3751f30500005000051d375000051c3751a375
011800002b0042b0740000429074000042807400004240042407424004000042f074000042b074000040000429074000042907400004000042607400004000042607400004260740000400004230740000400004
016000001c075180051d0751d0051f0751f00518075180051a075180051d075180051c075180051a0751800518075180052307518005210751f0051f075180051f0751800521075180051d0751c0051807518005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e0702b070370703f07029000000001e0702b070370703f07000000000001e0702b070370703f07000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c0201c0200f0200102001020010200000000000380303c0703f0703f0703f07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001707027070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 02010043
00 02010443
00 02010044
00 02010444
00 05060744
00 05060744
00 05060844
02 05060844
01 090b0d7f
00 090b0d44
00 0a440e44
02 0a0c0e44
03 0f101144
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

