pico-8 cartridge // http://www.pico-8.com
version 5
__lua__
-- change resolution to 64x64
poke(0x5f2c,3)

tile_size = 8
world_tile_width = 8
world_tile_height = 8

-- used for the scroll
map_position_x = 0
map_position_y = 0

max_map_x = 16
max_map_y = 8

-- we'll use this one to limit the animation to certain frames. otherwise it's too fast.
animation_frames = 0

foxy = {}
foxy.position_x = 2
foxy.position_y = 2
foxy.speed = 1
-- indexes start in 1 in lua. wtf!
foxy.animation_index = 1
-- this is to avoid calling table.getn(foxy.animation) every time. 
-- i just read that if it can't return the size, it will traverse the array.
foxy.animation_size = 2
-- array containing the animation sprites
foxy.animation = { 0, 1 }


-- game functions

function _init() 
	cls()		
end

function _update()
  -- handle buttons
  has_moved = handle_buttons()	
  --if has_moved then
    animate_foxy()
  --end
  animation_frames += 1
end

function _draw() 
    map(map_position_x,map_position_y,0,0,tile_to_pixels(world_tile_width),tile_to_pixels(world_tile_height))
	spr(foxy.animation[foxy.animation_index], foxy.position_x, foxy.position_y)
end

-- input

function handle_buttons()
    has_moved = false
    -- left
    if btn(0) then
        if foxy.position_x - foxy.speed >= 0 then
            foxy.position_x -= foxy.speed
            has_moved = true
            if map_position_x - 1 >= 0 then
                map_position_x -= 1
            end
        end

    -- right
    elseif btn(1) then
        if pixels_to_tile(foxy.position_x + foxy.speed) < world_tile_width then
            foxy.position_x += foxy.speed
            has_moved = true
            -- scroll map
            if pixels_to_tile(foxy.position_x) > map_position_x + world_tile_width/2+1 and pixels_to_tile(map_position_x + 1) <= max_map_x-world_tile_width+1 then
                map_position_x += 1
            end
        end

    -- up
    elseif btn(2) then
        if foxy.position_y - foxy.speed >= 0 then
            foxy.position_y -= foxy.speed
            has_moved = true
        end

    -- down
    elseif btn(3) then
        if pixels_to_tile(foxy.position_y + foxy.speed) < world_tile_height then
            foxy.position_y += foxy.speed
            has_moved = true
        end
    end

    return has_moved
end

-- animation

function animate_foxy()
    if (animation_frames % 6 == 0) then
        foxy.animation_index += 1
        animation_frames = 0
    end
    if foxy.animation_index > foxy.animation_size then
        foxy.animation_index = 0
    end
end

-- scroll

function scroll_map() 

end

-- util

function tile_to_pixels(tile)
    return tile * tile_size
end

function pixels_to_tile(pixel)
    return pixel / tile_size
end

__gfx__
08800880088008800880088008800880088008800880088008800880088008800008880000888000000888000088800000000000000000000000000000000000
08999980089999800899999008999880088998800889998009999980089999800088880000888800008888000088880000000000000000000000000000000000
09999990099999900999999009999990099999900999999009999990099999900088499999948800008849999994880000000000000000000000000000000000
07199170097199100997199009999990099999900999999009917990019917900088999999998800008899999999880000000000000000000000000000000000
07711770097711700997711009999970079999700799999001177990071177900099999999999900009999999999990000000000000000000000000000000000
00dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd000099999999999900009999999999990000000000000000000000000000000000
09dddd90009ddd90009ddd00088dd90000d88d00009dd88000ddd90000ddd9000077c19999c177000077c19999c1770000000000000000000000000000000000
00900900000909000009900000909000009009000009090000099000009090000077119999117700007711999911770000000000000000000000000000000000
08800880088008800880088008800880088008800880088008800880088008800077777117777700007777711777770000000000000000000000000000000000
08999980089999800889988008899880089999800899998008899880088998800007771111777000000777111177700000000000000000000000000000000000
099999900999999009999990099999900999999009999990099999900999999000990dddddd0000000000dddddd0990000000000000000000000000000000000
07199170071991700999999009999990071991700719917009999990099999900099dddddddd99000099dddddddd990000000000000000000000000000000000
07711770077117700799997007999970077117700771177007999970079999700000dddddddd99000099dddddddd000000000000000000000000000000000000
09dddd0000dddd9000dddd0000dddd0000ddd900009ddd0000dddd0000dddd000000d99ddddd00000000ddddd99d000000000000000000000000000000000000
00dddd9009dddd0000d88d0000d88d00009ddd0000ddd90000dd88000088dd000000099009900000000009900990000000000000000000000000000000000000
00000900009000000000090000900000009009000090090000900900009009000000000009900000000009900000000000000000000000000000000000000000
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
00008800000088000088000000880000bbbbbbbbbbbbbbbb66666666455545554555455500000000000000000000000000000000000000000000000000000000
00007770000077700777000007770000bbbbbb3bb3bbbbbb66666666444444444999999400000000000000000000000000000000000000000000000000000000
00007170000071700717000007170000bbb3bbbbbbbbb3bb66666666554555455944449500000000000000000000000000000000000000000000000000000000
00007799000077999977000099770000bbbbbbbbbbbbbbbb66666666444444444944449400000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770bbbbbbbbbbbbbbbb66666666455545554944449500000000000000000000000000000000000000000000000000000000
00777770007777700777770007777700bbbbb3bbbbb3bbbb66666666444444444944449400000000000000000000000000000000000000000000000000000000
00077700000777000077700000777000b3bbbbbbbbbbbbbb66666666554555455944449500000000000000000000000000000000000000000000000000000000
00009000000009000009000000900000bbbbbbbbbbbbbbb366666666444444444944449400000000000000000000000000000000000000000000000000000000
00888800008888000088880000888800bbb333bb4444444445554555455545557777777700000000000000000000000000000000000000000000000000000000
00777700007777000078870000788700bb33333b4444444446666664466666647777777700000000000000000000000000000000000000000000000000000000
00177100001771000077770000777700b3838b334444444456111165567111657777777700000000000000000000000000000000000000000000000000000000
00799700007997000077770000777700333333334444444446111164461111647777777700000000000000000000000000000000000000000000000000000000
0777777000777700077777700777777033b338334444444446111165461111657777777700000000000000000000000000000000000000000000000000000000
007777000777777000777700007777003833333b4444444446666664466666647777777700000000000000000000000000000000000000000000000000000000
00777700007777000077770000777700b333333b4444444455455545554555457777777700000000000000000000000000000000000000000000000000000000
00009000000900000000900000090000bbbbbbbb4444444444444444444444447777777700000000000000000000000000000000000000000000000000000000
000ff000000000000000000000000000455545554555455566666666666666660000000000000000000000000000000000000000000000000000000000000000
00f77f00000ff00000ff00000000ff0049999994499999946c7cccc66cccc7c60000000000000000000000000000000000000000000000000000000000000000
0f7777f000f77f000f77f000000f77f059666695596666956cc7ccc66cccccc60000000000000000000000000000000000000000000000000000000000000000
0f7777f00f7777f0f7777f0000f7777f49666694496666946cccccc66cccccc60000000000000000000000000000000000000000000000000000000000000000
f777777ff777777ff77777f00f77777f49999995499999956cccccc66cccccc60000000000000000000000000000000000000000000000000000000000000000
6777777f6777777f6777777ff777777f4999aa9449aa99946cccccc66cccccc60000000000000000000000000000000000000000000000000000000000000000
067777f0067777f0067777f0067777f0599999955999999566666666666666660000000000000000000000000000000000000000000000000000000000000000
0066ff000066ff000066ff000066ff00499999944999999444444444444444440000000000000000000000000000000000000000000000000000000000000000
000f1000000f10000070070700000000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000
00f71f0000f71f0070000000700aa000000aa00000aa00000000aa0000aaaa000000000000000000000000000000000000000000000000000000000000000000
0f7177f00f7177f00700007000aaaa0700aaaa000aaaa000000aaaa0001aa1000000000000000000000000000000000000000000000000000000000000000000
0f7777f00f7717f00f0777f00f1aa100001aa10001aa10000001aa1000a88a000000000000000000000000000000000000000000000000000000000000000000
f777777ff717771ff777777ff7a88a7f00a88a000a88a000000a88a00aaaaaa00000000000000000000000000000000000000000000000000000000000000000
6777777f6777777f6777777f6777777f0aaaaaa000aaaaa00aaaaa0000aaaa000000000000000000000000000000000000000000000000000000000000000000
067777f0067777f0067777f0067777f000aaaa000aaaaa0000aaaaa000aaaa000000000000000000000000000000000000000000000000000000000000000000
0066ff000066ff000066ff000066ff00009aa900009aa900009aa900009aa9000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000088880000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000007700008aaaa8000066000006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000007700008a00a8000600600006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000008a00a8000600600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008aaaaaa800999900009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000770008aa00aa800999900009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000070008aaaaaa800999900009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008888888800999900009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
111111111111111111711111117777111171171111177111111111111111111111111111111111111111cccccccccccccccccccccccc11111111111111111111
111111111111111111111111111888111188811111111111111111111111111111111111111111111111c1111111111111111111111c11111111111111111111
111111111111111111111111118888111188881111111111111111111111111111111111111111111111c1111777771711771777111c11111111111111111111
111111111111111111111111118849999994881111111111111111111111111111111111111111111111c1117111717171717171111c11111111111111111111
111111111111111111111111118899999999881111111111111111111111111111111111111111111111c1111711717771771171111c11111111111111111111
111111111111111111111111119999999999991111111111111111111111111111111111111111111111c1111171717171717171111c11111111111111111111
111111111111111111111111119999999999991111111111111111111111111111111111111111111111c1117711717171717171111c11111111111111111111
1111111111111111111111111177c19999c1771111111111111111111111111111111111111111111111c1111111111111111111111c11111111111111111111
111111111111111111111111117711999911771111111111111111111111111111111111111111111111cccccccccccccccccccccccc11111111111111111111
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4444444444444446464755555555474646444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444446464755556055474646444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444546464755555555474046444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444544444445446464766645667474646444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4646464646464646464646464646464646444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4646464646464646464646464646464660444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444544544445444444454444454444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__music__
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

