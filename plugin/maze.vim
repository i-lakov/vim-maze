" Global variables
let g:dir = expand('<sfile>:h')
let g:wall_char = "⬛"
let g:empty_char = "  "
let g:player_char = "◾"
let g:player_path = "◽"
let g:win_char = "  "
let g:map_size = 20
let g:map = []
let g:p_pos_x = 0
let g:p_pos_y = 0
let g:is_running = 1
let g:win_pos_x = 0
let g:win_pox_y = 0
let g:file_list = [g:dir . "/maze_files/l1.txt", g:dir . "/maze_files/l2.txt", g:dir . "/maze_files/l3.txt", g:dir . "/maze_files/l4.txt"]
let g:cur_file = 0
let g:moves_made = 0

" Initial setting-up
function! s:Init()
	enew
	set lazyredraw
	set noswapfile
	setlocal buftype=nofile
	set encoding=utf-8

	call s:ReadFile()
endfunction

" Reads the initial map from the files in /maze_files folder
function! s:ReadFile()
	echon " Ниво "
	echon g:cur_file+1
	if g:cur_file >= len(g:file_list)
		echo "Превъртя играта."
		let g:is_running = 0
		return
	endif
	let l:lines = readfile(g:file_list[g:cur_file])
	for i in range(len(l:lines))
		call add(g:map, [])
		for j in range(len(l:lines[i]))
			if l:lines[i][j] == 1
				call add(g:map[i], g:wall_char)
			elseif l:lines[i][j] == 0
				call add(g:map[i], g:empty_char)
			elseif l:lines[i][j] == 5
				call add(g:map[i], g:win_char)
				let g:win_pos_x = j
				let g:win_pos_y = i
			elseif l:lines[i][j] == 8
				call add(g:map[i], g:player_path)
			elseif l:lines[i][j] == 9
				call add(g:map[i], g:player_char)
				let g:p_pos_x = j
				let g:p_pos_y = i
			endif
		endfor
	endfor
endfunction

" Basic function to display the maze to the buffer
function! s:DisplayMaze()
	for i in range(len(g:map))
		let s:cur_line = ""
		for j in range(len(g:map[i]))
			let s:cur_line = s:cur_line . g:map[i][j]
		endfor
		call append(i, s:cur_line)
	endfor
endfunction

" Catches input when necessary and performs commands based on it
function! s:CatchInput()
	let s:input = getchar()
	if s:input == 104 " h - left
		let l:new_x = g:p_pos_x - 1
		if l:new_x >= 0 && g:map[g:p_pos_y][l:new_x] != g:wall_char
			let g:map[g:p_pos_y][l:new_x] = g:player_char
			let g:map[g:p_pos_y][g:p_pos_x] = g:player_path
			let g:p_pos_x = l:new_x
		endif
	elseif s:input == 106 " j - down
		let l:new_y = g:p_pos_y + 1
		if l:new_y < len(g:map) && g:map[l:new_y][g:p_pos_x] != g:wall_char
			let g:map[l:new_y][g:p_pos_x] = g:player_char
			let g:map[g:p_pos_y][g:p_pos_x] = g:player_path
			let g:p_pos_y = l:new_y
		endif
	elseif s:input == 107 " k - up
		let l:new_y = g:p_pos_y - 1
		if l:new_y >= 0 && g:map[l:new_y][g:p_pos_x] != g:wall_char
			let g:map[l:new_y][g:p_pos_x] = g:player_char
			let g:map[g:p_pos_y][g:p_pos_x] = g:player_path
			let g:p_pos_y = l:new_y
		endif
	elseif s:input == 108 " l - right
		let l:new_x = g:p_pos_x + 1
		if l:new_x < len(g:map[g:p_pos_y]) && g:map[g:p_pos_y][l:new_x] != g:wall_char
			let g:map[g:p_pos_y][l:new_x] = g:player_char
			let g:map[g:p_pos_y][g:p_pos_x] = g:player_path
			let g:p_pos_x = l:new_x
		endif
	elseif s:input == 27 " ESC
		echo "Играта свърши."
		let g:is_running = 0
	endif
	
	let g:moves_made = g:moves_made + 1
	
	if g:p_pos_x == g:win_pos_x && g:p_pos_y == g:win_pos_y
		echon "Браво! Натисни К за следващото ниво или ESC за изход. Брой ходове: "
		echon g:moves_made
		let g:moves_made = 0
		let s:input = getchar()
		if s:input == 107 " k - next level
			let g:cur_file = g:cur_file + 1
			let g:map = []
			call s:ReadFile()
		elseif s:input == 27 " ESC
			echo "Играта свърши."
			let g:is_running = 0
		endif
	endif
endfunction

" Main game loop
function! s:GameLoop()
	call s:Init()
	while g:is_running
		execute "%d"
		call s:DisplayMaze()
		redraw
		call s:CatchInput()
	endwhile
	set nolazyredraw
endfunction

command! Maze call s:GameLoop()
