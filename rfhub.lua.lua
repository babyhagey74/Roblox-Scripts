local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_64501 = 0;
			while true do
				if (FlatIdent_64501 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_7126A = 0;
			local Res;
			while true do
				if (FlatIdent_7126A == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_12703 = 0;
			local Plc;
			while true do
				if (FlatIdent_12703 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_2BD95 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_2BD95 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_2BD95 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_2BD95 = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_60EA1 = 0;
				while true do
					if (FlatIdent_60EA1 == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_31A5A = 0;
			while true do
				if (FlatIdent_31A5A == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_51F42 = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_51F42 == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_51F42 = 1;
				end
				if (FlatIdent_51F42 == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_E652 = 0;
			local Descriptor;
			while true do
				if (0 == FlatIdent_E652) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_2B80F = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_2B80F == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_2B80F = 3;
							end
							if (FlatIdent_2B80F == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_2B80F = 1;
							end
							if (1 == FlatIdent_2B80F) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									local FlatIdent_6AC43 = 0;
									while true do
										if (FlatIdent_6AC43 == 0) then
											Inst[3] = gBits16();
											Inst[4] = gBits16();
											break;
										end
									end
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									local FlatIdent_291EB = 0;
									while true do
										if (FlatIdent_291EB == 0) then
											Inst[3] = gBits32() - (2 ^ 16);
											Inst[4] = gBits16();
											break;
										end
									end
								end
								FlatIdent_2B80F = 2;
							end
							if (FlatIdent_2B80F == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
						end
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 79) then
					if (Enum <= 39) then
						if (Enum <= 19) then
							if (Enum <= 9) then
								if (Enum <= 4) then
									if (Enum <= 1) then
										if (Enum == 0) then
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										else
											local FlatIdent_703C8 = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_703C8 == 2) then
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_703C8 = 3;
												end
												if (FlatIdent_703C8 == 0) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_703C8 = 1;
												end
												if (FlatIdent_703C8 == 6) then
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_699FD = 0;
														while true do
															if (FlatIdent_699FD == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													FlatIdent_703C8 = 7;
												end
												if (FlatIdent_703C8 == 7) then
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_759F1 = 0;
														while true do
															if (0 == FlatIdent_759F1) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_703C8 == 3) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_703C8 = 4;
												end
												if (FlatIdent_703C8 == 5) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													FlatIdent_703C8 = 6;
												end
												if (FlatIdent_703C8 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_703C8 = 2;
												end
												if (FlatIdent_703C8 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_703C8 = 5;
												end
											end
										end
									elseif (Enum <= 2) then
										Stk[Inst[2]] = {};
									elseif (Enum > 3) then
										local FlatIdent_7DA5D = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_7DA5D == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_7DA5D = 6;
											end
											if (FlatIdent_7DA5D == 6) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_7DA5D = 7;
											end
											if (FlatIdent_7DA5D == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_7DA5D = 5;
											end
											if (FlatIdent_7DA5D == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
											if (2 == FlatIdent_7DA5D) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7DA5D = 3;
											end
											if (8 == FlatIdent_7DA5D) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_7DA5D = 9;
											end
											if (FlatIdent_7DA5D == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_7DA5D = 1;
											end
											if (1 == FlatIdent_7DA5D) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_7DA5D = 2;
											end
											if (FlatIdent_7DA5D == 7) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_7DA5D = 8;
											end
											if (FlatIdent_7DA5D == 3) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_7DA5D = 4;
											end
										end
									else
										local FlatIdent_324DE = 0;
										local A;
										while true do
											if (FlatIdent_324DE == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_324DE = 6;
											end
											if (8 == FlatIdent_324DE) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_324DE = 9;
											end
											if (FlatIdent_324DE == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_324DE = 5;
											end
											if (FlatIdent_324DE == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_324DE = 4;
											end
											if (FlatIdent_324DE == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_324DE = 3;
											end
											if (FlatIdent_324DE == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_324DE = 7;
											end
											if (FlatIdent_324DE == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_324DE == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_324DE = 1;
											end
											if (FlatIdent_324DE == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_324DE = 2;
											end
											if (7 == FlatIdent_324DE) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_324DE = 8;
											end
										end
									end
								elseif (Enum <= 6) then
									if (Enum > 5) then
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_586FF = 0;
											while true do
												if (FlatIdent_586FF == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 7) then
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								elseif (Enum == 8) then
									local FlatIdent_8BBE3 = 0;
									local A;
									local B;
									while true do
										if (0 == FlatIdent_8BBE3) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_8BBE3 = 1;
										end
										if (FlatIdent_8BBE3 == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
									end
								else
									local FlatIdent_7B0E = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_7B0E == 1) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_7B0E = 2;
										end
										if (FlatIdent_7B0E == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_7B0E == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7B0E = 3;
										end
										if (FlatIdent_7B0E == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_7B0E = 4;
										end
										if (FlatIdent_7B0E == 4) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7B0E = 5;
										end
										if (6 == FlatIdent_7B0E) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_7B0E = 7;
										end
										if (FlatIdent_7B0E == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_7B0E = 6;
										end
										if (FlatIdent_7B0E == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7B0E = 1;
										end
									end
								end
							elseif (Enum <= 14) then
								if (Enum <= 11) then
									if (Enum == 10) then
										local A = Inst[2];
										local C = Inst[4];
										local CB = A + 2;
										local Result = {Stk[A](Stk[A + 1], Stk[CB])};
										for Idx = 1, C do
											Stk[CB + Idx] = Result[Idx];
										end
										local R = Result[1];
										if R then
											Stk[CB] = R;
											VIP = Inst[3];
										else
											VIP = VIP + 1;
										end
									else
										local B;
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									end
								elseif (Enum <= 12) then
									local FlatIdent_28F3E = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_28F3E == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F3E = 2;
										end
										if (FlatIdent_28F3E == 3) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28F3E = 4;
										end
										if (0 == FlatIdent_28F3E) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_28F3E = 1;
										end
										if (FlatIdent_28F3E == 4) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_28F3E = 5;
										end
										if (FlatIdent_28F3E == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F3E = 6;
										end
										if (FlatIdent_28F3E == 2) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28F3E = 3;
										end
										if (FlatIdent_28F3E == 6) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
									end
								elseif (Enum == 13) then
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								else
									local FlatIdent_92F79 = 0;
									local A;
									local Cls;
									while true do
										if (FlatIdent_92F79 == 0) then
											A = Inst[2];
											Cls = {};
											FlatIdent_92F79 = 1;
										end
										if (FlatIdent_92F79 == 1) then
											for Idx = 1, #Lupvals do
												local List = Lupvals[Idx];
												for Idz = 0, #List do
													local FlatIdent_36762 = 0;
													local Upv;
													local NStk;
													local DIP;
													while true do
														if (1 == FlatIdent_36762) then
															DIP = Upv[2];
															if ((NStk == Stk) and (DIP >= A)) then
																Cls[DIP] = NStk[DIP];
																Upv[1] = Cls;
															end
															break;
														end
														if (0 == FlatIdent_36762) then
															Upv = List[Idz];
															NStk = Upv[1];
															FlatIdent_36762 = 1;
														end
													end
												end
											end
											break;
										end
									end
								end
							elseif (Enum <= 16) then
								if (Enum == 15) then
									local FlatIdent_6AE96 = 0;
									local A;
									while true do
										if (FlatIdent_6AE96 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (5 == FlatIdent_6AE96) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6AE96 = 6;
										end
										if (FlatIdent_6AE96 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_6AE96 = 5;
										end
										if (6 == FlatIdent_6AE96) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6AE96 = 7;
										end
										if (FlatIdent_6AE96 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6AE96 = 2;
										end
										if (FlatIdent_6AE96 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6AE96 = 1;
										end
										if (FlatIdent_6AE96 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_6AE96 = 9;
										end
										if (FlatIdent_6AE96 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_6AE96 = 4;
										end
										if (FlatIdent_6AE96 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6AE96 = 8;
										end
										if (FlatIdent_6AE96 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_6AE96 = 3;
										end
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
								end
							elseif (Enum <= 17) then
								local FlatIdent_8B336 = 0;
								local A;
								while true do
									if (FlatIdent_8B336 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8B336 = 7;
									end
									if (FlatIdent_8B336 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8B336 = 5;
									end
									if (FlatIdent_8B336 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_8B336 = 4;
									end
									if (FlatIdent_8B336 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8B336 = 1;
									end
									if (FlatIdent_8B336 == 5) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_8B336 = 6;
									end
									if (FlatIdent_8B336 == 7) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (2 == FlatIdent_8B336) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_8B336 = 3;
									end
									if (FlatIdent_8B336 == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_8B336 = 2;
									end
								end
							elseif (Enum > 18) then
								Upvalues[Inst[3]] = Stk[Inst[2]];
							else
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 29) then
							if (Enum <= 24) then
								if (Enum <= 21) then
									if (Enum > 20) then
										local FlatIdent_580CB = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_580CB == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_580CB = 1;
											end
											if (4 == FlatIdent_580CB) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_580CB = 5;
											end
											if (FlatIdent_580CB == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_580CB = 3;
											end
											if (FlatIdent_580CB == 6) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_580CB == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_580CB = 2;
											end
											if (FlatIdent_580CB == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_580CB = 4;
											end
											if (FlatIdent_580CB == 5) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_580CB = 6;
											end
										end
									else
										local B;
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
									end
								elseif (Enum <= 22) then
									local FlatIdent_81225 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_81225 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_81225 = 1;
										end
										if (FlatIdent_81225 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_81225 = 2;
										end
										if (FlatIdent_81225 == 7) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_81225 = 8;
										end
										if (FlatIdent_81225 == 5) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_81225 = 6;
										end
										if (FlatIdent_81225 == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											break;
										end
										if (FlatIdent_81225 == 8) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_81225 = 9;
										end
										if (FlatIdent_81225 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_81225 = 5;
										end
										if (FlatIdent_81225 == 3) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_81225 = 4;
										end
										if (6 == FlatIdent_81225) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_81225 = 7;
										end
										if (FlatIdent_81225 == 2) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_81225 = 3;
										end
									end
								elseif (Enum == 23) then
									local FlatIdent_7D08D = 0;
									local B;
									local A;
									while true do
										if (5 == FlatIdent_7D08D) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7D08D = 6;
										end
										if (FlatIdent_7D08D == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_7D08D = 5;
										end
										if (3 == FlatIdent_7D08D) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7D08D = 4;
										end
										if (0 == FlatIdent_7D08D) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_7D08D = 1;
										end
										if (FlatIdent_7D08D == 6) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (1 == FlatIdent_7D08D) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_7D08D = 2;
										end
										if (FlatIdent_7D08D == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_7D08D = 3;
										end
									end
								else
									local FlatIdent_7D161 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_7D161 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_7D161 = 2;
										end
										if (3 == FlatIdent_7D161) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_7D161 = 4;
										end
										if (FlatIdent_7D161 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_7D161 = 1;
										end
										if (8 == FlatIdent_7D161) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_7D161 = 9;
										end
										if (FlatIdent_7D161 == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (2 == FlatIdent_7D161) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7D161 = 3;
										end
										if (7 == FlatIdent_7D161) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7D161 = 8;
										end
										if (FlatIdent_7D161 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7D161 = 5;
										end
										if (FlatIdent_7D161 == 6) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_7D161 = 7;
										end
										if (5 == FlatIdent_7D161) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_7D161 = 6;
										end
									end
								end
							elseif (Enum <= 26) then
								if (Enum == 25) then
									local FlatIdent_3E634 = 0;
									local B;
									local A;
									while true do
										if (3 == FlatIdent_3E634) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3E634 = 4;
										end
										if (4 == FlatIdent_3E634) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_3E634 = 5;
										end
										if (FlatIdent_3E634 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_3E634 = 2;
										end
										if (FlatIdent_3E634 == 6) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_3E634 == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3E634 = 6;
										end
										if (FlatIdent_3E634 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_3E634 = 3;
										end
										if (FlatIdent_3E634 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3E634 = 1;
										end
									end
								else
									local FlatIdent_8E5B4 = 0;
									local A;
									while true do
										if (FlatIdent_8E5B4 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8E5B4 = 7;
										end
										if (2 == FlatIdent_8E5B4) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_8E5B4 = 3;
										end
										if (FlatIdent_8E5B4 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_8E5B4 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8E5B4 = 2;
										end
										if (FlatIdent_8E5B4 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_8E5B4 = 5;
										end
										if (FlatIdent_8E5B4 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_8E5B4 = 4;
										end
										if (FlatIdent_8E5B4 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8E5B4 = 6;
										end
										if (0 == FlatIdent_8E5B4) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8E5B4 = 1;
										end
										if (FlatIdent_8E5B4 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_8E5B4 = 9;
										end
										if (FlatIdent_8E5B4 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8E5B4 = 8;
										end
									end
								end
							elseif (Enum <= 27) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							elseif (Enum > 28) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							else
								local FlatIdent_D14D = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_D14D == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_D14D = 2;
									end
									if (FlatIdent_D14D == 4) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_D14D = 5;
									end
									if (FlatIdent_D14D == 6) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_D14D == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_D14D = 4;
									end
									if (0 == FlatIdent_D14D) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_D14D = 1;
									end
									if (FlatIdent_D14D == 5) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_D14D = 6;
									end
									if (2 == FlatIdent_D14D) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_D14D = 3;
									end
								end
							end
						elseif (Enum <= 34) then
							if (Enum <= 31) then
								if (Enum == 30) then
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 32) then
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							elseif (Enum > 33) then
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 36) then
							if (Enum > 35) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							else
								local B;
								local A;
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 37) then
							local FlatIdent_527C6 = 0;
							local A;
							while true do
								if (FlatIdent_527C6 == 1) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_527C6 = 2;
								end
								if (FlatIdent_527C6 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_527C6 = 3;
								end
								if (FlatIdent_527C6 == 5) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_527C6 = 6;
								end
								if (4 == FlatIdent_527C6) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_527C6 = 5;
								end
								if (FlatIdent_527C6 == 6) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_527C6 == 3) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_527C6 = 4;
								end
								if (FlatIdent_527C6 == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_527C6 = 1;
								end
							end
						elseif (Enum == 38) then
							local DIP;
							local NStk;
							local Upv;
							local List;
							local Cls;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Cls = {};
							for Idx = 1, #Lupvals do
								local FlatIdent_1B2C8 = 0;
								while true do
									if (FlatIdent_1B2C8 == 0) then
										List = Lupvals[Idx];
										for Idz = 0, #List do
											Upv = List[Idz];
											NStk = Upv[1];
											DIP = Upv[2];
											if ((NStk == Stk) and (DIP >= A)) then
												local FlatIdent_1DFAF = 0;
												while true do
													if (FlatIdent_1DFAF == 0) then
														Cls[DIP] = NStk[DIP];
														Upv[1] = Cls;
														break;
													end
												end
											end
										end
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							do
								return;
							end
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 59) then
						if (Enum <= 49) then
							if (Enum <= 44) then
								if (Enum <= 41) then
									if (Enum == 40) then
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									else
										Stk[Inst[2]] = Env[Inst[3]];
									end
								elseif (Enum <= 42) then
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
								elseif (Enum == 43) then
									local FlatIdent_699E4 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_699E4 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_699E4 = 1;
										end
										if (FlatIdent_699E4 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_699E4 = 2;
										end
										if (FlatIdent_699E4 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_699E4 = 4;
										end
										if (4 == FlatIdent_699E4) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_699E4 = 5;
										end
										if (FlatIdent_699E4 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_699E4 = 3;
										end
										if (FlatIdent_699E4 == 6) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_699E4 == 5) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_699E4 = 6;
										end
									end
								else
									local FlatIdent_6C34 = 0;
									local A;
									while true do
										if (FlatIdent_6C34 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_6C34 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_6C34 = 3;
										end
										if (FlatIdent_6C34 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_6C34 = 4;
										end
										if (FlatIdent_6C34 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_6C34 = 9;
										end
										if (FlatIdent_6C34 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6C34 = 7;
										end
										if (FlatIdent_6C34 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6C34 = 8;
										end
										if (4 == FlatIdent_6C34) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_6C34 = 5;
										end
										if (FlatIdent_6C34 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6C34 = 2;
										end
										if (FlatIdent_6C34 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6C34 = 1;
										end
										if (FlatIdent_6C34 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6C34 = 6;
										end
									end
								end
							elseif (Enum <= 46) then
								if (Enum > 45) then
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
								end
							elseif (Enum <= 47) then
								local FlatIdent_8BE54 = 0;
								local B;
								local A;
								while true do
									if (1 == FlatIdent_8BE54) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_8BE54 = 2;
									end
									if (0 == FlatIdent_8BE54) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8BE54 = 1;
									end
									if (FlatIdent_8BE54 == 6) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_8BE54 == 3) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_8BE54 = 4;
									end
									if (FlatIdent_8BE54 == 2) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_8BE54 = 3;
									end
									if (5 == FlatIdent_8BE54) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8BE54 = 6;
									end
									if (4 == FlatIdent_8BE54) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_8BE54 = 5;
									end
								end
							elseif (Enum == 48) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 54) then
							if (Enum <= 51) then
								if (Enum > 50) then
									VIP = Inst[3];
								else
									local FlatIdent_679D2 = 0;
									local A;
									while true do
										if (FlatIdent_679D2 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_679D2 = 7;
										end
										if (FlatIdent_679D2 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_679D2 = 1;
										end
										if (FlatIdent_679D2 == 7) then
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_679D2 == 5) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_679D2 = 6;
										end
										if (FlatIdent_679D2 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_679D2 = 4;
										end
										if (FlatIdent_679D2 == 2) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_679D2 = 3;
										end
										if (FlatIdent_679D2 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_679D2 = 2;
										end
										if (FlatIdent_679D2 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_679D2 = 5;
										end
									end
								end
							elseif (Enum <= 52) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							elseif (Enum > 53) then
								local FlatIdent_E841 = 0;
								local A;
								while true do
									if (FlatIdent_E841 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_E841 = 5;
									end
									if (FlatIdent_E841 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_E841 = 1;
									end
									if (FlatIdent_E841 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_E841 = 2;
									end
									if (FlatIdent_E841 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_E841 == 3) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_E841 = 4;
									end
									if (FlatIdent_E841 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_E841 = 3;
									end
								end
							else
								local FlatIdent_974E = 0;
								local A;
								while true do
									if (FlatIdent_974E == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_974E = 3;
									end
									if (FlatIdent_974E == 1) then
										Inst = Instr[VIP];
										Upvalues[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										FlatIdent_974E = 2;
									end
									if (FlatIdent_974E == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_974E = 5;
									end
									if (FlatIdent_974E == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Inst[2] <= Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (3 == FlatIdent_974E) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										FlatIdent_974E = 4;
									end
									if (FlatIdent_974E == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
										VIP = VIP + 1;
										FlatIdent_974E = 1;
									end
									if (FlatIdent_974E == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										FlatIdent_974E = 6;
									end
								end
							end
						elseif (Enum <= 56) then
							if (Enum > 55) then
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								local FlatIdent_28724 = 0;
								local A;
								while true do
									if (FlatIdent_28724 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_28724 = 3;
									end
									if (4 == FlatIdent_28724) then
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_28724 == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_28724 = 2;
									end
									if (FlatIdent_28724 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_28724 = 1;
									end
									if (FlatIdent_28724 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_28724 = 4;
									end
								end
							end
						elseif (Enum <= 57) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						elseif (Enum > 58) then
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 69) then
						if (Enum <= 64) then
							if (Enum <= 61) then
								if (Enum > 60) then
									local A = Inst[2];
									local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									local Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_5960E = 0;
										while true do
											if (FlatIdent_5960E == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
								else
									local FlatIdent_47ADC = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_47ADC == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_47ADC = 1;
										end
										if (FlatIdent_47ADC == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_47ADC = 2;
										end
										if (FlatIdent_47ADC == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											break;
										end
										if (FlatIdent_47ADC == 2) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_47ADC = 3;
										end
										if (FlatIdent_47ADC == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_47ADC = 6;
										end
										if (FlatIdent_47ADC == 3) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_47ADC = 4;
										end
										if (FlatIdent_47ADC == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_47ADC = 5;
										end
									end
								end
							elseif (Enum <= 62) then
								local FlatIdent_47A85 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_47A85 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_47A85 = 2;
									end
									if (FlatIdent_47A85 == 2) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_47A85 = 3;
									end
									if (FlatIdent_47A85 == 4) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_47A85 = 5;
									end
									if (FlatIdent_47A85 == 6) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_47A85 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_47A85 = 1;
									end
									if (FlatIdent_47A85 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_47A85 = 4;
									end
									if (FlatIdent_47A85 == 5) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_47A85 = 6;
									end
								end
							elseif (Enum == 63) then
								local FlatIdent_6D35B = 0;
								local A;
								while true do
									if (FlatIdent_6D35B == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6D35B = 5;
									end
									if (3 == FlatIdent_6D35B) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_6D35B = 4;
									end
									if (FlatIdent_6D35B == 7) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_6D35B == 2) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_6D35B = 3;
									end
									if (FlatIdent_6D35B == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_6D35B = 7;
									end
									if (FlatIdent_6D35B == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6D35B = 1;
									end
									if (1 == FlatIdent_6D35B) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_6D35B = 2;
									end
									if (FlatIdent_6D35B == 5) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_6D35B = 6;
									end
								end
							else
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 66) then
							if (Enum > 65) then
								local FlatIdent_6F3E4 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_6F3E4 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_6F3E4 = 1;
									end
									if (4 == FlatIdent_6F3E4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_6F3E4 = 5;
									end
									if (FlatIdent_6F3E4 == 7) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6F3E4 = 8;
									end
									if (FlatIdent_6F3E4 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_6F3E4 = 4;
									end
									if (FlatIdent_6F3E4 == 8) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_6F3E4 == 5) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_6F3E4 = 6;
									end
									if (FlatIdent_6F3E4 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_6F3E4 = 2;
									end
									if (2 == FlatIdent_6F3E4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_6F3E4 = 3;
									end
									if (FlatIdent_6F3E4 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_6F3E4 = 7;
									end
								end
							else
								local FlatIdent_97E60 = 0;
								local A;
								while true do
									if (FlatIdent_97E60 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_97E60 = 9;
									end
									if (0 == FlatIdent_97E60) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_97E60 = 1;
									end
									if (FlatIdent_97E60 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_97E60 = 6;
									end
									if (FlatIdent_97E60 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_97E60 = 2;
									end
									if (FlatIdent_97E60 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_97E60 = 5;
									end
									if (FlatIdent_97E60 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_97E60 = 8;
									end
									if (6 == FlatIdent_97E60) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_97E60 = 7;
									end
									if (FlatIdent_97E60 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (3 == FlatIdent_97E60) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_97E60 = 4;
									end
									if (FlatIdent_97E60 == 2) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										FlatIdent_97E60 = 3;
									end
								end
							end
						elseif (Enum <= 67) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						elseif (Enum == 68) then
							local FlatIdent_1BD19 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_1BD19 == 2) then
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BD19 = 3;
								end
								if (1 == FlatIdent_1BD19) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_1BD19 = 2;
								end
								if (FlatIdent_1BD19 == 9) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_1BD19 == 7) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BD19 = 8;
								end
								if (FlatIdent_1BD19 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_1BD19 = 1;
								end
								if (FlatIdent_1BD19 == 6) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BD19 = 7;
								end
								if (FlatIdent_1BD19 == 4) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BD19 = 5;
								end
								if (8 == FlatIdent_1BD19) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BD19 = 9;
								end
								if (FlatIdent_1BD19 == 5) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BD19 = 6;
								end
								if (FlatIdent_1BD19 == 3) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_1BD19 = 4;
								end
							end
						else
							local FlatIdent_79884 = 0;
							local B;
							local A;
							while true do
								if (6 == FlatIdent_79884) then
									VIP = Inst[3];
									break;
								end
								if (0 == FlatIdent_79884) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_79884 = 1;
								end
								if (FlatIdent_79884 == 4) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_79884 = 5;
								end
								if (1 == FlatIdent_79884) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_79884 = 2;
								end
								if (FlatIdent_79884 == 2) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_79884 = 3;
								end
								if (FlatIdent_79884 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_79884 = 4;
								end
								if (FlatIdent_79884 == 5) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_79884 = 6;
								end
							end
						end
					elseif (Enum <= 74) then
						if (Enum <= 71) then
							if (Enum > 70) then
								local FlatIdent_6245F = 0;
								local A;
								local Results;
								local Limit;
								local Edx;
								while true do
									if (FlatIdent_6245F == 1) then
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_6245F = 2;
									end
									if (FlatIdent_6245F == 2) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										break;
									end
									if (FlatIdent_6245F == 0) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
										FlatIdent_6245F = 1;
									end
								end
							else
								local FlatIdent_8B29C = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_8B29C == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_8B29C = 1;
									end
									if (FlatIdent_8B29C == 1) then
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8B29C = 2;
									end
									if (FlatIdent_8B29C == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_8B29C = 6;
									end
									if (FlatIdent_8B29C == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8B29C = 5;
									end
									if (FlatIdent_8B29C == 3) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_8B29C = 4;
									end
									if (FlatIdent_8B29C == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_8B29C == 2) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8B29C = 3;
									end
								end
							end
						elseif (Enum <= 72) then
							local FlatIdent_2B368 = 0;
							local Results;
							local Edx;
							local Limit;
							local B;
							local A;
							while true do
								if (FlatIdent_2B368 == 0) then
									Results = nil;
									Edx = nil;
									Results, Limit = nil;
									B = nil;
									A = nil;
									FlatIdent_2B368 = 1;
								end
								if (FlatIdent_2B368 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_2B368 = 3;
								end
								if (FlatIdent_2B368 == 1) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_2B368 = 2;
								end
								if (FlatIdent_2B368 == 3) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2B368 = 4;
								end
								if (FlatIdent_2B368 == 6) then
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_2B368 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									Edx = 0;
									FlatIdent_2B368 = 6;
								end
								if (FlatIdent_2B368 == 4) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_7B998 = 0;
										while true do
											if (FlatIdent_7B998 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									FlatIdent_2B368 = 5;
								end
							end
						elseif (Enum > 73) then
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local FlatIdent_3B2E6 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_3B2E6 == 6) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_3B2E6 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3B2E6 = 6;
								end
								if (FlatIdent_3B2E6 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_3B2E6 = 1;
								end
								if (FlatIdent_3B2E6 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_3B2E6 = 3;
								end
								if (FlatIdent_3B2E6 == 3) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_3B2E6 = 4;
								end
								if (FlatIdent_3B2E6 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_3B2E6 = 2;
								end
								if (FlatIdent_3B2E6 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_3B2E6 = 5;
								end
							end
						end
					elseif (Enum <= 76) then
						if (Enum > 75) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						else
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 77) then
						local FlatIdent_370FF = 0;
						local A;
						while true do
							if (FlatIdent_370FF == 2) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								FlatIdent_370FF = 3;
							end
							if (FlatIdent_370FF == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_370FF = 4;
							end
							if (FlatIdent_370FF == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_370FF = 6;
							end
							if (1 == FlatIdent_370FF) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_370FF = 2;
							end
							if (FlatIdent_370FF == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_370FF = 5;
							end
							if (FlatIdent_370FF == 8) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_370FF = 9;
							end
							if (FlatIdent_370FF == 9) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_370FF == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_370FF = 8;
							end
							if (FlatIdent_370FF == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_370FF = 1;
							end
							if (FlatIdent_370FF == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_370FF = 7;
							end
						end
					elseif (Enum > 78) then
						local FlatIdent_96598 = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_96598 == 0) then
								B = nil;
								A = nil;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_96598 = 1;
							end
							if (FlatIdent_96598 == 6) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_96598 == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_96598 = 6;
							end
							if (FlatIdent_96598 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								FlatIdent_96598 = 5;
							end
							if (FlatIdent_96598 == 3) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_96598 = 4;
							end
							if (FlatIdent_96598 == 1) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								FlatIdent_96598 = 2;
							end
							if (FlatIdent_96598 == 2) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_96598 = 3;
							end
						end
					else
						local FlatIdent_5A134 = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_5A134 == 3) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_5A134 = 4;
							end
							if (FlatIdent_5A134 == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_5A134 == 0) then
								B = nil;
								A = nil;
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								FlatIdent_5A134 = 1;
							end
							if (FlatIdent_5A134 == 6) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_5A134 = 7;
							end
							if (FlatIdent_5A134 == 2) then
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5A134 = 3;
							end
							if (FlatIdent_5A134 == 5) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_5A134 = 6;
							end
							if (FlatIdent_5A134 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_5A134 = 5;
							end
							if (1 == FlatIdent_5A134) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_5A134 = 2;
							end
						end
					end
				elseif (Enum <= 119) then
					if (Enum <= 99) then
						if (Enum <= 89) then
							if (Enum <= 84) then
								if (Enum <= 81) then
									if (Enum == 80) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
									else
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 82) then
									local FlatIdent_167F8 = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_167F8 == 8) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_74EA4 = 0;
												while true do
													if (FlatIdent_74EA4 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											FlatIdent_167F8 = 9;
										end
										if (FlatIdent_167F8 == 6) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											FlatIdent_167F8 = 7;
										end
										if (FlatIdent_167F8 == 7) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_167F8 = 8;
										end
										if (FlatIdent_167F8 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_167F8 = 2;
										end
										if (FlatIdent_167F8 == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_167F8 = 1;
										end
										if (FlatIdent_167F8 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_167F8 = 3;
										end
										if (FlatIdent_167F8 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_167F8 = 4;
										end
										if (FlatIdent_167F8 == 9) then
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (5 == FlatIdent_167F8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_167F8 = 6;
										end
										if (FlatIdent_167F8 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_167F8 = 5;
										end
									end
								elseif (Enum == 83) then
									local FlatIdent_84C31 = 0;
									local A;
									local K;
									local B;
									while true do
										if (FlatIdent_84C31 == 5) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_84C31 = 6;
										end
										if (FlatIdent_84C31 == 4) then
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84C31 = 5;
										end
										if (FlatIdent_84C31 == 6) then
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_84C31 == 0) then
											A = nil;
											K = nil;
											B = nil;
											FlatIdent_84C31 = 1;
										end
										if (FlatIdent_84C31 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84C31 = 3;
										end
										if (FlatIdent_84C31 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84C31 = 2;
										end
										if (FlatIdent_84C31 == 3) then
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											FlatIdent_84C31 = 4;
										end
									end
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 86) then
								if (Enum > 85) then
									local FlatIdent_6E70 = 0;
									local A;
									while true do
										if (FlatIdent_6E70 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
									end
								else
									local FlatIdent_2D05E = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_2D05E == 3) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_2D05E = 4;
										end
										if (8 == FlatIdent_2D05E) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2D05E = 9;
										end
										if (1 == FlatIdent_2D05E) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2D05E = 2;
										end
										if (FlatIdent_2D05E == 2) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2D05E = 3;
										end
										if (4 == FlatIdent_2D05E) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2D05E = 5;
										end
										if (6 == FlatIdent_2D05E) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2D05E = 7;
										end
										if (FlatIdent_2D05E == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2D05E = 6;
										end
										if (FlatIdent_2D05E == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_2D05E = 1;
										end
										if (FlatIdent_2D05E == 7) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2D05E = 8;
										end
										if (9 == FlatIdent_2D05E) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
									end
								end
							elseif (Enum <= 87) then
								local FlatIdent_8387D = 0;
								local A;
								while true do
									if (FlatIdent_8387D == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_8387D = 4;
									end
									if (FlatIdent_8387D == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8387D = 1;
									end
									if (FlatIdent_8387D == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8387D = 7;
									end
									if (FlatIdent_8387D == 2) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_8387D = 3;
									end
									if (FlatIdent_8387D == 7) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_8387D == 5) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_8387D = 6;
									end
									if (FlatIdent_8387D == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_8387D = 2;
									end
									if (FlatIdent_8387D == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8387D = 5;
									end
								end
							elseif (Enum > 88) then
								if (Inst[2] <= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 94) then
							if (Enum <= 91) then
								if (Enum > 90) then
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								else
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum <= 92) then
								local FlatIdent_4EBF2 = 0;
								local A;
								while true do
									if (FlatIdent_4EBF2 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4EBF2 = 7;
									end
									if (FlatIdent_4EBF2 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_4EBF2 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_4EBF2 = 2;
									end
									if (FlatIdent_4EBF2 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_4EBF2 = 4;
									end
									if (FlatIdent_4EBF2 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_4EBF2 = 1;
									end
									if (4 == FlatIdent_4EBF2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_4EBF2 = 5;
									end
									if (FlatIdent_4EBF2 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4EBF2 = 6;
									end
									if (FlatIdent_4EBF2 == 2) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										FlatIdent_4EBF2 = 3;
									end
									if (FlatIdent_4EBF2 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_4EBF2 = 9;
									end
									if (FlatIdent_4EBF2 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4EBF2 = 8;
									end
								end
							elseif (Enum == 93) then
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
							else
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 96) then
							if (Enum == 95) then
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
							else
								local FlatIdent_5FCA9 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_5FCA9 == 7) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5FCA9 = 8;
									end
									if (FlatIdent_5FCA9 == 5) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5FCA9 = 6;
									end
									if (3 == FlatIdent_5FCA9) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_5FCA9 = 4;
									end
									if (FlatIdent_5FCA9 == 6) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5FCA9 = 7;
									end
									if (FlatIdent_5FCA9 == 8) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5FCA9 = 9;
									end
									if (FlatIdent_5FCA9 == 9) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_5FCA9 == 2) then
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5FCA9 = 3;
									end
									if (FlatIdent_5FCA9 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_5FCA9 = 2;
									end
									if (4 == FlatIdent_5FCA9) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5FCA9 = 5;
									end
									if (FlatIdent_5FCA9 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_5FCA9 = 1;
									end
								end
							end
						elseif (Enum <= 97) then
							local FlatIdent_70FF0 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_70FF0 == 3) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_70FF0 = 4;
								end
								if (FlatIdent_70FF0 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_70FF0 = 6;
								end
								if (FlatIdent_70FF0 == 4) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_70FF0 = 5;
								end
								if (FlatIdent_70FF0 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_70FF0 = 1;
								end
								if (6 == FlatIdent_70FF0) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_70FF0 == 1) then
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_70FF0 = 2;
								end
								if (FlatIdent_70FF0 == 2) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_70FF0 = 3;
								end
							end
						elseif (Enum == 98) then
							local FlatIdent_1F538 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_1F538 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_1F538 = 5;
								end
								if (FlatIdent_1F538 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1F538 = 2;
								end
								if (FlatIdent_1F538 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1F538 = 1;
								end
								if (8 == FlatIdent_1F538) then
									VIP = Inst[3];
									break;
								end
								if (5 == FlatIdent_1F538) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_1F538 = 6;
								end
								if (FlatIdent_1F538 == 7) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1F538 = 8;
								end
								if (FlatIdent_1F538 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1F538 = 3;
								end
								if (FlatIdent_1F538 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_1F538 = 7;
								end
								if (FlatIdent_1F538 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1F538 = 4;
								end
							end
						else
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 109) then
						if (Enum <= 104) then
							if (Enum <= 101) then
								if (Enum > 100) then
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_44005 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_44005 == 5) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44005 = 6;
										end
										if (FlatIdent_44005 == 3) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_44005 = 4;
										end
										if (FlatIdent_44005 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44005 = 2;
										end
										if (0 == FlatIdent_44005) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_44005 = 1;
										end
										if (FlatIdent_44005 == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											break;
										end
										if (FlatIdent_44005 == 2) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_44005 = 3;
										end
										if (FlatIdent_44005 == 7) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_44005 = 8;
										end
										if (FlatIdent_44005 == 8) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_44005 = 9;
										end
										if (6 == FlatIdent_44005) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_44005 = 7;
										end
										if (FlatIdent_44005 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_44005 = 5;
										end
									end
								end
							elseif (Enum <= 102) then
								local FlatIdent_64015 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_64015 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_64015 = 7;
									end
									if (FlatIdent_64015 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_64015 = 2;
									end
									if (FlatIdent_64015 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_64015 = 1;
									end
									if (FlatIdent_64015 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_64015 = 5;
									end
									if (FlatIdent_64015 == 7) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_64015 = 8;
									end
									if (FlatIdent_64015 == 5) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_64015 = 6;
									end
									if (FlatIdent_64015 == 8) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_64015 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_64015 = 4;
									end
									if (FlatIdent_64015 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_64015 = 3;
									end
								end
							elseif (Enum > 103) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local B = Inst[3];
								local K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
							end
						elseif (Enum <= 106) then
							if (Enum == 105) then
								local FlatIdent_4A784 = 0;
								local B;
								local A;
								while true do
									if (2 == FlatIdent_4A784) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4A784 = 3;
									end
									if (FlatIdent_4A784 == 5) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_4A784 = 6;
									end
									if (FlatIdent_4A784 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4A784 = 7;
									end
									if (FlatIdent_4A784 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4A784 = 1;
									end
									if (FlatIdent_4A784 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4A784 = 4;
									end
									if (FlatIdent_4A784 == 8) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_4A784 == 7) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4A784 = 8;
									end
									if (4 == FlatIdent_4A784) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4A784 = 5;
									end
									if (FlatIdent_4A784 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4A784 = 2;
									end
								end
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum <= 107) then
							local A;
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						elseif (Enum == 108) then
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						else
							local Results;
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_91215 = 0;
								while true do
									if (FlatIdent_91215 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results = {Stk[A](Unpack(Stk, A + 1, Top))};
							Edx = 0;
							for Idx = A, Inst[4] do
								local FlatIdent_4FB47 = 0;
								while true do
									if (FlatIdent_4FB47 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 114) then
						if (Enum <= 111) then
							if (Enum == 110) then
								local FlatIdent_65E70 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_65E70 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_65E70 = 4;
									end
									if (FlatIdent_65E70 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_65E70 = 3;
									end
									if (8 == FlatIdent_65E70) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_65E70 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_65E70 = 2;
									end
									if (FlatIdent_65E70 == 5) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_65E70 = 6;
									end
									if (FlatIdent_65E70 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_65E70 = 5;
									end
									if (FlatIdent_65E70 == 7) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_65E70 = 8;
									end
									if (FlatIdent_65E70 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_65E70 = 7;
									end
									if (FlatIdent_65E70 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_65E70 = 1;
									end
								end
							else
								local Edx;
								local Results, Limit;
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_8566 = 0;
									while true do
										if (FlatIdent_8566 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_8F941 = 0;
									while true do
										if (0 == FlatIdent_8F941) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 112) then
							if (Stk[Inst[2]] ~= Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum == 113) then
							local FlatIdent_E326 = 0;
							local B;
							local A;
							while true do
								if (0 == FlatIdent_E326) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_E326 = 1;
								end
								if (FlatIdent_E326 == 1) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_E326 = 2;
								end
								if (FlatIdent_E326 == 6) then
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_E326 == 3) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_E326 = 4;
								end
								if (FlatIdent_E326 == 4) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_E326 = 5;
								end
								if (FlatIdent_E326 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E326 = 6;
								end
								if (FlatIdent_E326 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E326 = 3;
								end
							end
						else
							local B;
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
						end
					elseif (Enum <= 116) then
						if (Enum > 115) then
							local FlatIdent_1435C = 0;
							local A;
							while true do
								if (3 == FlatIdent_1435C) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_1435C = 4;
								end
								if (FlatIdent_1435C == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_1435C = 6;
								end
								if (FlatIdent_1435C == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_1435C == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_1435C = 2;
								end
								if (FlatIdent_1435C == 4) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_1435C = 5;
								end
								if (FlatIdent_1435C == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_1435C = 7;
								end
								if (FlatIdent_1435C == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_1435C = 3;
								end
								if (FlatIdent_1435C == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_1435C = 1;
								end
							end
						else
							local FlatIdent_374C5 = 0;
							local A;
							local Results;
							local Limit;
							local Edx;
							while true do
								if (0 == FlatIdent_374C5) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									FlatIdent_374C5 = 1;
								end
								if (FlatIdent_374C5 == 1) then
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_374C5 = 2;
								end
								if (FlatIdent_374C5 == 2) then
									for Idx = A, Top do
										local FlatIdent_274AE = 0;
										while true do
											if (FlatIdent_274AE == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									break;
								end
							end
						end
					elseif (Enum <= 117) then
						Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
					elseif (Enum > 118) then
						local A;
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					else
						local A;
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					end
				elseif (Enum <= 139) then
					if (Enum <= 129) then
						if (Enum <= 124) then
							if (Enum <= 121) then
								if (Enum == 120) then
									local FlatIdent_85D6F = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_85D6F == 9) then
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_85D6F == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_85D6F = 2;
										end
										if (0 == FlatIdent_85D6F) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_85D6F = 1;
										end
										if (FlatIdent_85D6F == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_85D6F = 6;
										end
										if (FlatIdent_85D6F == 6) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											FlatIdent_85D6F = 7;
										end
										if (FlatIdent_85D6F == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_85D6F = 4;
										end
										if (FlatIdent_85D6F == 7) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_85D6F = 8;
										end
										if (FlatIdent_85D6F == 8) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_7FE02 = 0;
												while true do
													if (FlatIdent_7FE02 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											FlatIdent_85D6F = 9;
										end
										if (FlatIdent_85D6F == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_85D6F = 3;
										end
										if (FlatIdent_85D6F == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_85D6F = 5;
										end
									end
								else
									local FlatIdent_2130E = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_2130E == 6) then
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											FlatIdent_2130E = 7;
										end
										if (FlatIdent_2130E == 5) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											FlatIdent_2130E = 6;
										end
										if (FlatIdent_2130E == 3) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2130E = 4;
										end
										if (FlatIdent_2130E == 7) then
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_7BF98 = 0;
												while true do
													if (FlatIdent_7BF98 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_2130E == 2) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2130E = 3;
										end
										if (0 == FlatIdent_2130E) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_2130E = 1;
										end
										if (FlatIdent_2130E == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_2130E = 5;
										end
										if (FlatIdent_2130E == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2130E = 2;
										end
									end
								end
							elseif (Enum <= 122) then
								local FlatIdent_76C4A = 0;
								local A;
								while true do
									if (FlatIdent_76C4A == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_76C4A = 2;
									end
									if (4 == FlatIdent_76C4A) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_76C4A = 5;
									end
									if (FlatIdent_76C4A == 2) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										FlatIdent_76C4A = 3;
									end
									if (FlatIdent_76C4A == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Upvalues[Inst[3]] = Stk[Inst[2]];
										FlatIdent_76C4A = 4;
									end
									if (FlatIdent_76C4A == 0) then
										A = nil;
										Upvalues[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										FlatIdent_76C4A = 1;
									end
									if (FlatIdent_76C4A == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
								end
							elseif (Enum > 123) then
								do
									return;
								end
							else
								local Results;
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_26492 = 0;
									while true do
										if (FlatIdent_26492 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 126) then
							if (Enum > 125) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local FlatIdent_14BE1 = 0;
								local B;
								local A;
								while true do
									if (3 == FlatIdent_14BE1) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_14BE1 = 4;
									end
									if (FlatIdent_14BE1 == 1) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_14BE1 = 2;
									end
									if (FlatIdent_14BE1 == 5) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_14BE1 = 6;
									end
									if (FlatIdent_14BE1 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_14BE1 = 3;
									end
									if (FlatIdent_14BE1 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_14BE1 = 1;
									end
									if (FlatIdent_14BE1 == 8) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_14BE1 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_14BE1 = 5;
									end
									if (6 == FlatIdent_14BE1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_14BE1 = 7;
									end
									if (FlatIdent_14BE1 == 7) then
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_14BE1 = 8;
									end
								end
							end
						elseif (Enum <= 127) then
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						elseif (Enum > 128) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						else
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 134) then
						if (Enum <= 131) then
							if (Enum > 130) then
								local FlatIdent_75E0E = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_75E0E == 4) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_75E0E = 5;
									end
									if (FlatIdent_75E0E == 5) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_75E0E = 6;
									end
									if (FlatIdent_75E0E == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_75E0E = 2;
									end
									if (FlatIdent_75E0E == 6) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_75E0E == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_75E0E = 4;
									end
									if (FlatIdent_75E0E == 2) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_75E0E = 3;
									end
									if (FlatIdent_75E0E == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_75E0E = 1;
									end
								end
							else
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
							end
						elseif (Enum <= 132) then
							local Edx;
							local Results, Limit;
							local K;
							local B;
							local A;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							B = Inst[3];
							K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_627BE = 0;
								while true do
									if (FlatIdent_627BE == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							B = Inst[3];
							K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_11039 = 0;
								while true do
									if (FlatIdent_11039 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							B = Inst[3];
							K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						elseif (Enum == 133) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local FlatIdent_5E594 = 0;
							local B;
							local A;
							while true do
								if (6 == FlatIdent_5E594) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_5E594 = 7;
								end
								if (FlatIdent_5E594 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_5E594 = 5;
								end
								if (FlatIdent_5E594 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_5E594 = 3;
								end
								if (FlatIdent_5E594 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_5E594 = 4;
								end
								if (FlatIdent_5E594 == 5) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_5E594 = 6;
								end
								if (FlatIdent_5E594 == 8) then
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_5E594 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_5E594 = 1;
								end
								if (FlatIdent_5E594 == 7) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5E594 = 8;
								end
								if (1 == FlatIdent_5E594) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_5E594 = 2;
								end
							end
						end
					elseif (Enum <= 136) then
						if (Enum > 135) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						else
							local A;
							local K;
							local B;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							B = Inst[3];
							K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 137) then
						local FlatIdent_51A3C = 0;
						local A;
						while true do
							if (FlatIdent_51A3C == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_51A3C = 3;
							end
							if (FlatIdent_51A3C == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_51A3C = 5;
							end
							if (FlatIdent_51A3C == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_51A3C = 1;
							end
							if (FlatIdent_51A3C == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_51A3C = 2;
							end
							if (FlatIdent_51A3C == 3) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_51A3C = 4;
							end
							if (FlatIdent_51A3C == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
								break;
							end
						end
					elseif (Enum == 138) then
						local FlatIdent_48DDA = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_48DDA == 6) then
								VIP = Inst[3];
								break;
							end
							if (0 == FlatIdent_48DDA) then
								B = nil;
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_48DDA = 1;
							end
							if (FlatIdent_48DDA == 2) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_48DDA = 3;
							end
							if (FlatIdent_48DDA == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_48DDA = 4;
							end
							if (FlatIdent_48DDA == 4) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_48DDA = 5;
							end
							if (1 == FlatIdent_48DDA) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_48DDA = 2;
							end
							if (FlatIdent_48DDA == 5) then
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_48DDA = 6;
							end
						end
					else
						Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
					end
				elseif (Enum <= 149) then
					if (Enum <= 144) then
						if (Enum <= 141) then
							if (Enum > 140) then
								if (Stk[Inst[2]] <= Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								Stk[A] = Stk[A]();
							end
						elseif (Enum <= 142) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						elseif (Enum == 143) then
							local FlatIdent_8B208 = 0;
							local A;
							while true do
								if (FlatIdent_8B208 == 5) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_8B208 = 6;
								end
								if (FlatIdent_8B208 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8B208 = 5;
								end
								if (FlatIdent_8B208 == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8B208 = 1;
								end
								if (2 == FlatIdent_8B208) then
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_8B208 = 3;
								end
								if (FlatIdent_8B208 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_8B208 = 4;
								end
								if (FlatIdent_8B208 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8B208 = 7;
								end
								if (FlatIdent_8B208 == 1) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_8B208 = 2;
								end
								if (FlatIdent_8B208 == 7) then
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
							end
						else
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 146) then
						if (Enum == 145) then
							local FlatIdent_D35D = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_D35D == 5) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_D35D = 6;
								end
								if (FlatIdent_D35D == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_D35D = 2;
								end
								if (FlatIdent_D35D == 4) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_D35D = 5;
								end
								if (FlatIdent_D35D == 8) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_D35D == 7) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_D35D = 8;
								end
								if (3 == FlatIdent_D35D) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_D35D = 4;
								end
								if (FlatIdent_D35D == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_D35D = 1;
								end
								if (FlatIdent_D35D == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_D35D = 3;
								end
								if (FlatIdent_D35D == 6) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_D35D = 7;
								end
							end
						else
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 147) then
						local FlatIdent_382D5 = 0;
						local Results;
						local Edx;
						local Limit;
						local B;
						local A;
						while true do
							if (FlatIdent_382D5 == 6) then
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_2DFF7 = 0;
									while true do
										if (0 == FlatIdent_2DFF7) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								FlatIdent_382D5 = 7;
							end
							if (FlatIdent_382D5 == 5) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								FlatIdent_382D5 = 6;
							end
							if (FlatIdent_382D5 == 4) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_382D5 = 5;
							end
							if (7 == FlatIdent_382D5) then
								Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_382D5 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_382D5 = 2;
							end
							if (FlatIdent_382D5 == 2) then
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_382D5 = 3;
							end
							if (FlatIdent_382D5 == 3) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_382D5 = 4;
							end
							if (FlatIdent_382D5 == 0) then
								Results = nil;
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_382D5 = 1;
							end
						end
					elseif (Enum == 148) then
						local FlatIdent_2A917 = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_2A917 == 3) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_2A917 = 4;
							end
							if (FlatIdent_2A917 == 6) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_2A917 == 1) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								FlatIdent_2A917 = 2;
							end
							if (FlatIdent_2A917 == 0) then
								B = nil;
								A = nil;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_2A917 = 1;
							end
							if (FlatIdent_2A917 == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_2A917 = 6;
							end
							if (FlatIdent_2A917 == 2) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_2A917 = 3;
							end
							if (FlatIdent_2A917 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								FlatIdent_2A917 = 5;
							end
						end
					else
						local FlatIdent_75429 = 0;
						local Results;
						local Edx;
						local Limit;
						local B;
						local A;
						while true do
							if (8 == FlatIdent_75429) then
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								FlatIdent_75429 = 9;
							end
							if (FlatIdent_75429 == 1) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75429 = 2;
							end
							if (6 == FlatIdent_75429) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_75429 = 7;
							end
							if (FlatIdent_75429 == 2) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_75429 = 3;
							end
							if (FlatIdent_75429 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_75429 = 5;
							end
							if (FlatIdent_75429 == 11) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_75429 == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75429 = 6;
							end
							if (FlatIdent_75429 == 9) then
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75429 = 10;
							end
							if (FlatIdent_75429 == 0) then
								Results = nil;
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								FlatIdent_75429 = 1;
							end
							if (FlatIdent_75429 == 7) then
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_75429 = 8;
							end
							if (3 == FlatIdent_75429) then
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_75429 = 4;
							end
							if (FlatIdent_75429 == 10) then
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_2B812 = 0;
									while true do
										if (FlatIdent_2B812 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								FlatIdent_75429 = 11;
							end
						end
					end
				elseif (Enum <= 154) then
					if (Enum <= 151) then
						if (Enum == 150) then
							if (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local FlatIdent_3EEB1 = 0;
							local A;
							while true do
								if (FlatIdent_3EEB1 == 0) then
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Top));
									break;
								end
							end
						end
					elseif (Enum <= 152) then
						local NewProto = Proto[Inst[3]];
						local NewUvals;
						local Indexes = {};
						NewUvals = Setmetatable({}, {__index=function(_, Key)
							local Val = Indexes[Key];
							return Val[1][Val[2]];
						end,__newindex=function(_, Key, Value)
							local FlatIdent_3F2AC = 0;
							local Val;
							while true do
								if (0 == FlatIdent_3F2AC) then
									Val = Indexes[Key];
									Val[1][Val[2]] = Value;
									break;
								end
							end
						end});
						for Idx = 1, Inst[4] do
							local FlatIdent_89142 = 0;
							local Mvm;
							while true do
								if (FlatIdent_89142 == 1) then
									if (Mvm[1] == 155) then
										Indexes[Idx - 1] = {Stk,Mvm[3]};
									else
										Indexes[Idx - 1] = {Upvalues,Mvm[3]};
									end
									Lupvals[#Lupvals + 1] = Indexes;
									break;
								end
								if (FlatIdent_89142 == 0) then
									VIP = VIP + 1;
									Mvm = Instr[VIP];
									FlatIdent_89142 = 1;
								end
							end
						end
						Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
					elseif (Enum == 153) then
						local B;
						local A;
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					else
						local FlatIdent_46A1E = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_46A1E == 2) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_46A1E = 3;
							end
							if (FlatIdent_46A1E == 6) then
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_46A1E == 0) then
								B = nil;
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_46A1E = 1;
							end
							if (FlatIdent_46A1E == 4) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_46A1E = 5;
							end
							if (FlatIdent_46A1E == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_46A1E = 4;
							end
							if (FlatIdent_46A1E == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_46A1E = 2;
							end
							if (5 == FlatIdent_46A1E) then
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_46A1E = 6;
							end
						end
					end
				elseif (Enum <= 157) then
					if (Enum <= 155) then
						Stk[Inst[2]] = Stk[Inst[3]];
					elseif (Enum == 156) then
						local FlatIdent_59338 = 0;
						local B;
						local A;
						while true do
							if (0 == FlatIdent_59338) then
								B = nil;
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_59338 = 1;
							end
							if (FlatIdent_59338 == 7) then
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_59338 = 8;
							end
							if (3 == FlatIdent_59338) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_59338 = 4;
							end
							if (FlatIdent_59338 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_59338 = 3;
							end
							if (FlatIdent_59338 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_59338 = 2;
							end
							if (FlatIdent_59338 == 8) then
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_59338 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_59338 = 7;
							end
							if (FlatIdent_59338 == 5) then
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_59338 = 6;
							end
							if (FlatIdent_59338 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_59338 = 5;
							end
						end
					else
						local Results;
						local Edx;
						local Results, Limit;
						local B;
						local A;
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Results, Limit = _R(Stk[A](Stk[A + 1]));
						Top = (Limit + A) - 1;
						Edx = 0;
						for Idx = A, Top do
							local FlatIdent_16C12 = 0;
							while true do
								if (0 == FlatIdent_16C12) then
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
									break;
								end
							end
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Results = {Stk[A](Unpack(Stk, A + 1, Top))};
						Edx = 0;
						for Idx = A, Inst[4] do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					end
				elseif (Enum <= 158) then
					local FlatIdent_42B98 = 0;
					local A;
					while true do
						if (FlatIdent_42B98 == 5) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							break;
						end
						if (2 == FlatIdent_42B98) then
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							FlatIdent_42B98 = 3;
						end
						if (FlatIdent_42B98 == 3) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							FlatIdent_42B98 = 4;
						end
						if (FlatIdent_42B98 == 0) then
							A = nil;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_42B98 = 1;
						end
						if (FlatIdent_42B98 == 1) then
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							FlatIdent_42B98 = 2;
						end
						if (4 == FlatIdent_42B98) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_42B98 = 5;
						end
					end
				elseif (Enum == 159) then
					local B;
					local A;
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = {};
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
				else
					local FlatIdent_8F7C2 = 0;
					local Results;
					local Edx;
					local Limit;
					local B;
					local A;
					while true do
						if (FlatIdent_8F7C2 == 1) then
							A = nil;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_8F7C2 = 2;
						end
						if (FlatIdent_8F7C2 == 2) then
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							FlatIdent_8F7C2 = 3;
						end
						if (11 == FlatIdent_8F7C2) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
							break;
						end
						if (FlatIdent_8F7C2 == 0) then
							Results = nil;
							Edx = nil;
							Results, Limit = nil;
							B = nil;
							FlatIdent_8F7C2 = 1;
						end
						if (FlatIdent_8F7C2 == 7) then
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							FlatIdent_8F7C2 = 8;
						end
						if (FlatIdent_8F7C2 == 10) then
							A = Inst[2];
							Results = {Stk[A](Unpack(Stk, A + 1, Top))};
							Edx = 0;
							for Idx = A, Inst[4] do
								local FlatIdent_161F1 = 0;
								while true do
									if (FlatIdent_161F1 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							FlatIdent_8F7C2 = 11;
						end
						if (FlatIdent_8F7C2 == 3) then
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							FlatIdent_8F7C2 = 4;
						end
						if (FlatIdent_8F7C2 == 6) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							FlatIdent_8F7C2 = 7;
						end
						if (FlatIdent_8F7C2 == 8) then
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							FlatIdent_8F7C2 = 9;
						end
						if (5 == FlatIdent_8F7C2) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_8F7C2 = 6;
						end
						if (FlatIdent_8F7C2 == 9) then
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_3FB17 = 0;
								while true do
									if (FlatIdent_3FB17 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_8F7C2 = 10;
						end
						if (FlatIdent_8F7C2 == 4) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							FlatIdent_8F7C2 = 5;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!6E3O0003433O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F76696F6C696E2D73757A757473756B692F4C696E6F7269614C69622F6D61696E2F030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574030B3O004C6962726172792E6C756103173O00612O646F6E732F5468656D654D616E616765722E6C756103163O00612O646F6E732F536176654D616E616765722E6C7561030C3O0043726561746557696E646F7703053O005469746C6503183O005261696E626F7720467269656E6473204875622056322E3203063O0043656E7465722O0103083O004175746F53686F77030A3O0054616250612O64696E67026O002040030C3O004D656E754661646554696D65029A5O99C93F03083O00436861707465723103063O00412O6454616203023O00433103083O00436861707465723203023O004332030D3O00546F756368496E74657265737403143O00546F75636820496E74657265737420285749502903083O0053652O74696E677303023O00554903073O004372656469747303043O0048656C70030F3O00412O644C65667447726F7570626F78030B3O0055492053652O74696E677303093O00412O6442752O746F6E03043O0054657874030A3O00556E6C6F61642047554903043O0046756E63030B3O00446F75626C65436C69636B010003073O00542O6F6C74697003153O00556E6C6F616473207468652077686F6C652047554903083O00412O644C6162656C03183O0049676E6F726520746869732C20757365207468656D65732E030E3O00412O64436F6C6F725069636B6572030B3O00436F6C6F725069636B657203073O0044656661756C7403063O00436F6C6F72332O033O006E6577028O00026O00F03F030A3O00536F6D6520636F6C6F72030C3O005472616E73706172656E637903083O0043612O6C6261636B031E3O006D6F6E6B65795F6B69643033202D205461627320262053656374696F6E7303183O004A6F696E206F757220646973636F7264207365727665722103153O00646973636F72642E2O672F435A6D4B7A6139664D4403163O0053657457617465726D61726B5669736962696C69747903043O007469636B026O004E40030A3O0047657453657276696365030A3O0052756E53657276696365030D3O0052656E6465725374652O70656403073O00436F2O6E65637403183O00455350207C204E696768742031202D204D6F6E737465727303093O00412O64546F2O676C65030E3O00486967686C6967687420426C7565032B3O005468697320686967686C6967687420697320736F207468617420796F752063616E20732O6520626C75652E030F3O00486967686C696768742047722O656E032C3O005468697320686967686C6967687420697320736F207468617420796F752063616E20732O652067722O656E2E03103O00486967686C6967687420507572706C65032D3O005468697320686967686C6967687420697320736F207468617420796F752063616E20732O6520707572706C652E03183O00455350207C204E696768742032202D204D6F6E737465727303103O00486967686C696768742059652O6C6F77032D3O005468697320686967686C6967687420697320736F207468617420796F752063616E20732O652079652O6C6F772E03183O00455350207C204E696768742033202D204D6F6E737465727303183O00455350207C204E696768742034202D204D6F6E7374657273030E3O00486967686C69676874204379616E032B3O005468697320686967686C6967687420697320736F207468617420796F752063616E20732O65206379616E2E03103O00412O64526967687447726F7570626F7803153O00455350207C204E696768742031202D204974656D7303153O00486967686C69676874204C696768742042756C627303163O00486967686C6967687473206C6967687462756C62732E03153O00455350207C204E696768742032202D204974656D7303173O00486967686C69676874204761732043616E69737465727303193O00486967686C6967687473206761732063616E6973746572732E03153O00455350207C204E696768742033202D204974656D7303113O00486967686C69676874204C2O6F6B69657303133O00486967686C6967687473206C2O6F6B6965732E03153O00455350207C204E696768742034202D204974656D7303123O00486967686C696768742043616B65204D697803143O00486967686C69676874732063616B65206D69782E03043O004E4F5445031B3O00507572706C6520697320696D706F2O7369626C652064756520746F03163O006974206265696E6720696E207468652076656E74732E03103O00486967686C69676874204F72616E6765032D3O005468697320686967686C6967687420697320736F207468617420796F752063616E20732O65206F72616E67652E03103O00486967686C6967687420426C6F636B7303123O00486967686C696768747320626C6F636B732E03133O00486967686C6967687420462O6F64204261677303153O00486967686C696768747320662O6F6420626167732E030F3O00486967686C6967687420467573657303113O00486967686C69676874732066757365732E03133O00486967686C696768742042612O74657269657303153O00486967686C69676874732062612O7465726965732E03093O00436861707465722031030A3O0047657420426C6F636B7303283O004765747320612O6C2074686520626C6F636B732066726F6D20746F75636820696E7465726573742E030D3O0047657420462O6F642042616773032B3O004765747320612O6C2074686520662O6F6420626167732066726F6D20746F75636820696E7465726573742E03093O0047657420467573657303273O004765747320612O6C207468652066757365732066726F6D20746F75636820696E7465726573742E030D3O004765742042612O746572696573032B3O004765747320612O6C207468652062612O7465726965732066726F6D20746F75636820696E7465726573742E000C022O0012843O00013O00122O000100023O00122O000200033O00202O0002000200044O00045O00122O000500056O0004000400054O000200046O00013O00024O00010001000200122O000200023O00122O000300033O00202O0003000300044O00055O00122O000600066O0005000500064O000300056O00023O00024O00020001000200122O000300023O00122O000400033O00202O0004000400044O00065O00122O000700076O0006000600074O000400066O00033O00024O00030001000200202O0004000100084O00063O000500302O00060009000A00302O0006000B000C00302O0006000D000C00302O0006000E000F00302O0006001000114O0004000600024O00053O000500202O00060004001300122O000800146O00060008000200102O00050012000600202O00060004001300122O000800166O00060008000200102O00050015000600202O00060004001300122O000800186O00060008000200102O00050017000600202O00060004001300122O0008001A6O00060008000200102O00050019000600202O00060004001300122O0008001C6O00060008000200102O0005001B000600202O00060005001900202O00060006001D00122O0008001E6O00060008000200202O00070006001F4O00093O000400302O000900200021000698000A3O000100012O009B3O00013O00101400090022000A00302O00090023002400302O0009002500264O00070009000200202O00080006002700122O000A00286O0008000A000200202O00080008002900122O000A002A6O000B3O0004001229000C002C3O002074000C000C002D00122O000D002E3O00122O000E002F3O00122O000F002E6O000C000F000200102O000B002B000C00302O000B0009003000302O000B0031002E000698000C0001000100032O009B3O00024O009B3O00014O009B3O00053O00107D000B0032000C4O0008000B000100202O00080005001B00202O00080008001D00122O000A001B6O0008000A000200202O00090008002700122O000B00336O0009000B000100202O000900080027001292000B00344O00230009000B000100202O00090008002700122O000B00356O0009000B000100202O0009000100364O000B00016O0009000B000100122O000900376O00090001000200122O000A002E3O001292000B00383O001228000C00033O00202O000C000C003900122O000E003A6O000C000E000200202O000C000C003B00202O000C000C003C000698000E0002000100042O009B3O00014O009B3O000B4O009B3O000A4O009B3O00094O004E000C000E000200202O000D0005001500202O000D000D001D00122O000F003D6O000D000F000200202O000E000D003E00122O0010003F6O00113O000400302O00110020003F00302O0011002B002400301B00110025004000028B001200033O00107F0011003200124O000E0011000100202O000E000D003E00122O001000416O00113O000400302O00110020004100302O0011002B002400302O00110025004200028B001200043O00107F0011003200124O000E0011000100202O000E000D003E00122O001000436O00113O000400302O00110020004300302O0011002B002400302O00110025004400028B001200053O0010040011003200124O000E0011000100202O000E0005001500202O000E000E001D00122O001000456O000E0010000200202O000F000E003E00122O0011003F6O00123O000400302O00120020003F00301B0012002B002400301B00120025004000028B001300063O00107F0012003200134O000F0012000100202O000F000E003E00122O001100416O00123O000400302O00120020004100302O0012002B002400302O00120025004200028B001300073O00107F0012003200134O000F0012000100202O000F000E003E00122O001100466O00123O000400302O00120020004600302O0012002B002400302O00120025004700028B001300083O00107F0012003200134O000F0012000100202O000F000E003E00122O001100436O00123O000400302O00120020004300302O0012002B002400302O00120025004400028B001300093O0010040012003200134O000F0012000100202O000F0005001500202O000F000F001D00122O001100486O000F0011000200202O0010000F003E00122O0012003F6O00133O000400302O00130020003F00301B0013002B002400301B00130025004000028B0014000A3O00107F0013003200144O00100013000100202O0010000F003E00122O001200416O00133O000400302O00130020004100302O0013002B002400302O00130025004200028B0014000B3O00107F0013003200144O00100013000100202O0010000F003E00122O001200466O00133O000400302O00130020004600302O0013002B002400302O00130025004700028B0014000C3O00107F0013003200144O00100013000100202O0010000F003E00122O001200436O00133O000400302O00130020004300302O0013002B002400302O00130025004400028B0014000D3O0010040013003200144O00100013000100202O00100005001500202O00100010001D00122O001200496O00100012000200202O00110010003E00122O0013003F6O00143O000400302O00140020003F00301B0014002B002400301B00140025004000028B0015000E3O00107F0014003200154O00110014000100202O00110010003E00122O001300416O00143O000400302O00140020004100302O0014002B002400302O00140025004200028B0015000F3O00107F0014003200154O00110014000100202O00110010003E00122O001300466O00143O000400302O00140020004600302O0014002B002400302O00140025004700028B001500103O00107F0014003200154O00110014000100202O00110010003E00122O0013004A6O00143O000400302O00140020004A00302O0014002B002400302O00140025004B00028B001500113O00107F0014003200154O00110014000100202O00110010003E00122O001300436O00143O000400302O00140020004300302O0014002B002400302O00140025004400028B001500123O00100D0014003200154O00110014000100202O00110005001500202O00110011004C00122O0013004D6O00110013000200202O00120011001F4O00143O000400302O00140020004E00028B001500133O00108200140022001500302O00140023002400302O00140025004F4O00120014000200202O00130005001500202O00130013004C00122O001500506O00130015000200202O00140013001F4O00163O000400301B00160020005100028B001700143O00108200160022001700302O00160023002400302O0016002500524O00140016000200202O00150005001500202O00150015004C00122O001700536O00150017000200202O00160015001F4O00183O000400301B00180020005400028B001900153O00108200180022001900302O00180023002400302O0018002500554O00160018000200202O00170005001500202O00170017004C00122O001900566O00170019000200202O00180017001F4O001A3O000400301B001A0020005700028B001B00163O001009001A0022001B00302O001A0023002400302O001A002500584O0018001A000200202O00190005001200202O00190019001D00122O001B00596O0019001B000200202O001A0019002700122O001C005A4O005A001A001C000100205D001A0019002700122O001C005B6O001A001C000100202O001A0005001200202O001A001A001D00122O001C003D6O001A001C000200202O001B001A003E00122O001D003F6O001E3O000400301B001E0020003F00301B001E002B002400301B001E0025004000028B001F00173O001004001E0032001F4O001B001E000100202O001B0005001200202O001B001B001D00122O001D00456O001B001D000200202O001C001B003E00122O001E003F6O001F3O000400302O001F0020003F00301B001F002B002400301B001F0025004000028B002000183O00107F001F003200204O001C001F000100202O001C001B003E00122O001E00416O001F3O000400302O001F0020004100302O001F002B002400302O001F0025004200028B002000193O001004001F003200204O001C001F000100202O001C0005001200202O001C001C001D00122O001E00486O001C001E000200202O001D001C003E00122O001F003F6O00203O000400302O00200020003F00301B0020002B002400301B00200025004000028B0021001A3O00107F0020003200214O001D0020000100202O001D001C003E00122O001F00416O00203O000400302O00200020004100302O0020002B002400302O00200025004200028B0021001B3O00107F0020003200214O001D0020000100202O001D001C003E00122O001F005C6O00203O000400302O00200020005C00302O0020002B002400302O00200025005D00028B0021001C3O0010040020003200214O001D0020000100202O001D0005001200202O001D001D001D00122O001F00496O001D001F000200202O001E001D003E00122O0020003F6O00213O000400302O00210020003F00301B0021002B002400301B00210025004000028B0022001D3O00107F0021003200224O001E0021000100202O001E001D003E00122O002000416O00213O000400302O00210020004100302O0021002B002400302O00210025004200028B0022001E3O00107F0021003200224O001E0021000100202O001E001D003E00122O0020005C6O00213O000400302O00210020005C00302O0021002B002400302O00210025005D00028B0022001F3O00100D0021003200224O001E0021000100202O001E0005001200202O001E001E004C00122O0020004D6O001E0020000200202O001F001E001F4O00213O000400302O00210020005E00028B002200203O00108200210022002200302O00210023002400302O00210025005F4O001F0021000200202O00200005001200202O00200020004C00122O002200506O00200022000200202O00210020001F4O00233O000400301B00230020006000028B002400213O00108200230022002400302O00230023002400302O0023002500614O00210023000200202O00220005001200202O00220022004C00122O002400536O00220024000200202O00230022001F4O00253O000400301B00250020006200028B002600223O00108200250022002600302O00250023002400302O0025002500634O00230025000200202O00240005001200202O00240024004C00122O002600566O00240026000200202O00250024001F4O00273O000400301B00270020006400028B002800233O00108200270022002800302O00270023002400302O0027002500654O00250027000200202O00260005001700202O00260026004C00122O002800666O00260028000200202O00270026001F4O00293O000400301B00290020006700028B002A00243O00109100290022002A00302O00290023002400302O0029002500684O00270029000200202O00280026001F4O002A3O000400302O002A0020006900028B002B00253O001091002A0022002B00302O002A0023002400302O002A0025006A4O0028002A000200202O00290026001F4O002B3O000400302O002B0020006B00028B002C00263O001091002B0022002C00302O002B0023002400302O002B0025006C4O0029002B000200202O002A0026001F4O002C3O000400302O002C0020006D00028B002D00273O001026002C0022002D00302O002C0023002400302O002C0025006E4O002A002C00029O006O00013O00283O00013O0003063O00556E6C6F616400044O00507O0020085O00012O006C3O000200012O007C3O00017O00043O00028O00030A3O005365744C696272617279030A3O00412O706C79546F54616203083O0053652O74696E6773010F3O001292000100013O00262700010001000100010004333O000100012O005000025O0020710002000200024O000400016O0002000400014O00025O00202O0002000200034O000400023O00202O0004000400044O00020004000100044O000E00010004333O000100012O007C3O00017O000F3O00028O00026O00F03F030C3O0053657457617465726D61726B031B3O0046505320262050696E67207C20257320667073207C202573206D7303063O00666F726D617403043O006D61746803053O00666C2O6F7203043O0067616D65030A3O004765745365727669636503053O00537461747303073O004E6574776F726B030F3O0053657276657253746174734974656D03093O00446174612050696E6703083O0047657456616C756503043O007469636B003D3O0012923O00013O0026273O001A000100020004333O001A00012O005000015O00206F00010001000300122O000300043O00202O00030003000500122O000500063O00202O0005000500074O000600016O00050002000200122O000600063O00202O00060006000700122O000700083O00202O00070007000900122O0009000A6O00070009000200202O00070007000B00202O00070007000C00202O00070007000D00202O00070007000E4O000700086O00068O00038O00013O000100044O003C00010026273O0001000100010004333O000100012O0050000100023O0020350001000100024O000100023O00122O0001000F6O0001000100024O000200036O000100010002000E2O0002003A000100010004333O003A0001001292000100014O0020000200023O000E9600010027000100010004333O00270001001292000200013O0026270002002F000100020004333O002F0001001292000300014O0013000300023O0004333O003A00010026270002002A000100010004333O002A00012O0050000300024O007A000300013O00122O0003000F6O0003000100024O000300033O00122O000200023O00044O002A00010004333O003A00010004333O002700010012923O00023O0004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303053O0047722O656E010003073O0044657374726F7901213O001292000100013O00262700010001000100010004333O000100010026273O0015000100020004333O00150001001292000200014O0020000300033O00262700020007000100010004333O00070001001229000400033O00205C00040004000400122O000500056O0004000200024O000300043O00122O000400073O00202O00040004000800202O00040004000900202O00040004000A00102O00030006000400044O001500010004333O000700010026273O00200001000B0004333O00200001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O002000010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303063O00507572706C65010003073O0044657374726F7901213O001292000100013O00262700010001000100010004333O000100010026273O0015000100020004333O00150001001292000200014O0020000300033O00262700020007000100010004333O00070001001229000400033O00205C00040004000400122O000500056O0004000200024O000300043O00122O000400073O00202O00040004000800202O00040004000900202O00040004000A00102O00030006000400044O001500010004333O000700010026273O00200001000B0004333O00200001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O002000010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303053O0047722O656E010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O0042697264010003073O0044657374726F7901273O001292000100014O0020000200023O000E9600010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303063O00507572706C65010003073O0044657374726F7901213O001292000100013O00262700010001000100010004333O000100010026273O0015000100020004333O00150001001292000200014O0020000300033O00262700020007000100010004333O00070001001229000400033O00205C00040004000400122O000500056O0004000200024O000300043O00122O000400073O00202O00040004000800202O00040004000900202O00040004000A00102O00030006000400044O001500010004333O000700010026273O00200001000B0004333O00200001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O002000010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F7901213O001292000100013O00262700010001000100010004333O000100010026273O0015000100020004333O00150001001292000200014O0020000300033O00262700020007000100010004333O00070001001229000400033O00205C00040004000400122O000500056O0004000200024O000300043O00122O000400073O00202O00040004000800202O00040004000900202O00040004000A00102O00030006000400044O001500010004333O000700010026273O00200001000B0004333O00200001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O002000010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303053O0047722O656E010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O0042697264010003073O0044657374726F7901213O001292000100013O00262700010001000100010004333O000100010026273O0015000100020004333O00150001001292000200014O0020000300033O00262700020007000100010004333O00070001001229000400033O00205C00040004000400122O000500056O0004000200024O000300043O00122O000400073O00202O00040004000800202O00040004000900202O00040004000A00102O00030006000400044O001500010004333O000700010026273O00200001000B0004333O00200001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O002000010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303063O00507572706C65010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O002O01028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F79011C3O0026273O0012000100010004333O00120001001292000100024O0020000200023O000E9600020004000100010004333O00040001001229000300033O00205C00030003000400122O000400056O0003000200024O000200033O00122O000300073O00202O00030003000800202O00030003000900202O00030003000A00102O00020006000300044O001200010004333O000400010026273O001B0001000B0004333O001B0001001229000100073O00207200010001000800202O00010001000900202O00010001000A00202O00010001000500202O00010001000C4O0001000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303053O0047722O656E010003073O0044657374726F79011A3O001292000100013O00262700010001000100010004333O000100010026273O000E000100020004333O000E0001001229000200033O00204300020002000400122O000300056O00020002000200122O000300073O00202O00030003000800202O00030003000900202O00030003000A00102O0002000600030026273O00190001000B0004333O00190001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O001900010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O0042697264010003073O0044657374726F79011A3O001292000100013O000E9600010001000100010004333O000100010026273O000E000100020004333O000E0001001229000200033O00204300020002000400122O000300056O00020002000200122O000300073O00202O00030003000800202O00030003000900202O00030003000A00102O0002000600030026273O00190001000B0004333O00190001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O001900010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O004379616E010003073O0044657374726F7901213O001292000100013O00262700010001000100010004333O000100010026273O0015000100020004333O00150001001292000200014O0020000300033O00262700020007000100010004333O00070001001229000400033O00205C00040004000400122O000500056O0004000200024O000300043O00122O000400073O00202O00040004000800202O00040004000900202O00040004000A00102O00030006000400044O001500010004333O000700010026273O00200001000B0004333O00200001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O002000010004333O000100012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303063O00507572706C65010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503093O004C6967687442756C6203053O00436C6F6E6503063O00506172656E74001B3O0012923O00014O0020000100013O0026273O0002000100010004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00160001002034000700060009002627000700160001000A0004333O0016000100200800070001000B2O005600070002000200104C0007000C000600060A00020010000100020004333O001000010004333O001A00010004333O000200012O007C3O00017O000C3O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D65030B3O0047617343616E697374657203053O00436C6F6E6503063O00506172656E74001B3O0012923O00014O0020000100013O000E960001000200013O0004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00160001002034000700060009002627000700160001000A0004333O0016000100200800070001000B2O005600070002000200104C0007000C000600060A00020010000100020004333O001000010004333O001A00010004333O000200012O007C3O00017O000C3O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503053O004C2O6F6B7903053O00436C6F6E6503063O00506172656E74001B3O0012923O00014O0020000100013O0026273O0002000100010004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00160001002034000700060009002627000700160001000A0004333O0016000100200800070001000B2O005600070002000200104C0007000C000600060A00020010000100020004333O001000010004333O001A00010004333O000200012O007C3O00017O000C3O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503073O0043616B654D697803053O00436C6F6E6503063O00506172656E74001B3O0012923O00014O0020000100013O0026273O0002000100010004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00160001002034000700060009002627000700160001000A0004333O0016000100200800070001000B2O005600070002000200104C0007000C000600060A00020010000100020004333O001000010004333O001A00010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303053O0047722O656E010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303053O0047722O656E010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000B3O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303063O004F72616E6765010003073O0044657374726F7901153O0026273O000B000100010004333O000B0001001229000100023O00204300010001000300122O000200046O00010002000200122O000200063O00202O00020002000700202O00020002000800202O00020002000900102O0001000500020026273O00140001000A0004333O00140001001229000100063O00207200010001000700202O00010001000800202O00010001000900202O00010001000400202O00010001000B4O0001000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303043O00426C7565010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O000E9600010005000100020004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303053O0047722O656E010003073O0044657374726F7901273O001292000100014O0020000200023O00262700010002000100010004333O00020001001292000200013O00262700020005000100010004333O000500010026273O0019000100020004333O00190001001292000300014O0020000400043O0026270003000B000100010004333O000B0001001229000500033O00205C00050005000400122O000600056O0005000200024O000400053O00122O000500073O00202O00050005000800202O00050005000900202O00050005000A00102O00040006000500044O001900010004333O000B00010026273O00260001000B0004333O00260001001229000300073O00202E00030003000800202O00030003000900202O00030003000A00202O00030003000500202O00030003000C4O00030002000100044O002600010004333O000500010004333O002600010004333O000200012O007C3O00017O000C3O00028O002O0103083O00496E7374616E63652O033O006E657703093O00486967686C6967687403063O00506172656E7403043O0067616D6503093O00576F726B737061636503083O004D6F6E737465727303063O004F72616E6765010003073O0044657374726F7901213O001292000100013O00262700010001000100010004333O000100010026273O0015000100020004333O00150001001292000200014O0020000300033O00262700020007000100010004333O00070001001229000400033O00205C00040004000400122O000500056O0004000200024O000300043O00122O000400073O00202O00040004000800202O00040004000900202O00040004000A00102O00030006000400044O001500010004333O000700010026273O00200001000B0004333O00200001001229000200073O00202E00020002000800202O00020002000900202O00020002000A00202O00020002000500202O00020002000C4O00020002000100044O002000010004333O000100012O007C3O00017O00133O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03063O00737472696E6703053O006D6174636803043O004E616D65030C3O005E426C6F636B2825642B292403083O00746F6E756D626572026O00F03F026O00384003053O007072696E74030D3O00486967686C6967687465643A2003053O00436C6F6E6503063O00506172656E7400453O0012923O00014O0020000100013O0026273O0002000100010004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00400001001292000700014O0020000800083O00262700070012000100010004333O00120001001229000900093O00208900090009000A00202O000A0006000B00122O000B000C6O0009000B00024O000800093O00062O0008004000013O0004333O00400001001292000900014O0020000A000A3O0026270009001E000100010004333O001E0001001229000B000D4O009B000C00084O0056000B000200022O009B000A000B3O000665000A004000013O0004333O00400001000E59000E00400001000A0004333O0040000100268D000A00400001000F0004333O00400001001292000B00014O0020000C000C3O002627000B00340001000E0004333O00340001001229000D00103O001287000E00113O00202O000F0006000B4O000E000E000F4O000D0002000100044O00400001002627000B002C000100010004333O002C0001002008000D000100122O006B000D000200024O000C000D3O00102O000C0013000600122O000B000E3O00044O002C00010004333O004000010004333O001E00010004333O004000010004333O0012000100060A00020010000100020004333O001000010004333O004400010004333O000200012O007C3O00017O000E3O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503093O00462O6F6447722O656E030A3O00462O6F644F72616E676503083O00462O6F6450696E6B03053O00436C6F6E6503063O00506172656E7400283O0012923O00014O0020000100013O0026273O0002000100010004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00230001002034000700060009002670000700190001000A0004333O00190001002034000700060009002670000700190001000B0004333O00190001002034000700060009002627000700230001000C0004333O00230001001292000700014O0020000800083O000E960001001B000100070004333O001B000100200800090001000D2O00560009000200022O009B000800093O00104C0008000E00060004333O002300010004333O001B000100060A00020010000100020004333O001000010004333O002700010004333O000200012O007C3O00017O00133O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03063O00737472696E6703053O006D6174636803043O004E616D65030B3O005E467573652825642B292403083O00746F6E756D626572026O00F03F026O002C4003053O007072696E74030D3O00486967686C6967687465643A2003053O00436C6F6E6503063O00506172656E7400453O0012923O00014O0020000100013O000E960001000200013O0004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00400001001292000700014O0020000800083O00262700070012000100010004333O00120001001229000900093O00208900090009000A00202O000A0006000B00122O000B000C6O0009000B00024O000800093O00062O0008004000013O0004333O00400001001292000900014O0020000A000A3O0026270009001E000100010004333O001E0001001229000B000D4O009B000C00084O0056000B000200022O009B000A000B3O000665000A004000013O0004333O00400001000E59000E00400001000A0004333O0040000100268D000A00400001000F0004333O00400001001292000B00014O0020000C000C3O002627000B00340001000E0004333O00340001001229000D00103O001287000E00113O00202O000F0006000B4O000E000E000F4O000D0002000100044O00400001002627000B002C000100010004333O002C0001002008000D000100122O006B000D000200024O000C000D3O00102O000C0013000600122O000B000E3O00044O002C00010004333O004000010004333O001E00010004333O004000010004333O0012000100060A00020010000100020004333O001000010004333O004400010004333O000200012O007C3O00017O000C3O00028O0003083O00496E7374616E63652O033O006E657703093O00486967686C6967687403053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503073O0042612O7465727903053O00436C6F6E6503063O00506172656E74001B3O0012923O00014O0020000100013O0026273O0002000100010004333O00020001001229000200023O00207800020002000300122O000300046O0002000200024O000100023O00122O000200053O00122O000300063O00202O00030003000700202O0003000300084O000300046O00023O000400044O00160001002034000700060009002627000700160001000A0004333O0016000100200800070001000B2O005600070002000200104C0007000C000600060A00020010000100020004333O001000010004333O001A00010004333O000200012O007C3O00017O00113O0003053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E028O0003063O00737472696E6703053O006D6174636803043O004E616D65030C3O005E426C6F636B2825642B292403083O00746F6E756D626572026O00F03F026O00384003113O0066697265746F756368696E746572657374030C3O00546F7563685472692O676572030D3O00546F756368496E74657265737403043O0077616974026O00E03F00363O00129D3O00013O00122O000100023O00202O00010001000300202O0001000100044O000100029O00000200044O00330001001292000500054O0020000600063O00262700050009000100050004333O00090001001229000700063O00208900070007000700202O00080004000800122O000900096O0007000900024O000600073O00062O0006003300013O0004333O00330001001292000700054O0020000800083O000E9600050015000100070004333O001500010012290009000A4O009B000A00064O00560009000200022O009B000800093O0006650008003300013O0004333O00330001000E59000B0033000100080004333O0033000100268D000800330001000C0004333O00330001001292000900053O00262700090022000100050004333O00220001001229000A000D4O0054000B00043O00202O000C0004000E00202O000C000C000F00122O000D000B6O000A000D000100122O000A00103O00122O000B00116O000A0002000100044O003300010004333O002200010004333O003300010004333O001500010004333O003300010004333O0009000100060A3O0007000100020004333O000700012O007C3O00017O000F3O0003053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503093O00462O6F6447722O656E030A3O00462O6F644F72616E676503083O00462O6F6450696E6B028O0003113O0066697265746F756368696E746572657374030C3O00546F7563685472692O676572030D3O00546F756368496E746572657374026O00F03F03043O0077616974026O00E03F00213O00129D3O00013O00122O000100023O00202O00010001000300202O0001000100044O000100029O00000200044O001E000100203400050004000500267000050010000100060004333O0010000100203400050004000500267000050010000100070004333O001000010020340005000400050026270005001E000100080004333O001E0001001292000500093O00262700050011000100090004333O001100010012290006000A4O0054000700043O00202O00080004000B00202O00080008000C00122O0009000D6O00060009000100122O0006000E3O00122O0007000F6O00060002000100044O001E00010004333O0011000100060A3O0007000100020004333O000700012O007C3O00017O00113O0003053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E028O0003063O00737472696E6703053O006D6174636803043O004E616D65030B3O005E467573652825642B292403083O00746F6E756D626572026O00F03F026O002C4003113O0066697265746F756368696E746572657374030C3O00546F7563685472692O676572030D3O00546F756368496E74657265737403043O0077616974026O00E03F00363O00129D3O00013O00122O000100023O00202O00010001000300202O0001000100044O000100029O00000200044O00330001001292000500054O0020000600063O00262700050009000100050004333O00090001001229000700063O00208900070007000700202O00080004000800122O000900096O0007000900024O000600073O00062O0006003300013O0004333O00330001001292000700054O0020000800083O00262700070015000100050004333O001500010012290009000A4O009B000A00064O00560009000200022O009B000800093O0006650008003300013O0004333O00330001000E59000B0033000100080004333O0033000100268D000800330001000C0004333O00330001001292000900053O00262700090022000100050004333O00220001001229000A000D4O0054000B00043O00202O000C0004000E00202O000C000C000F00122O000D000B6O000A000D000100122O000A00103O00122O000B00116O000A0002000100044O003300010004333O002200010004333O003300010004333O001500010004333O003300010004333O0009000100060A3O0007000100020004333O000700012O007C3O00017O000D3O0003053O00706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503073O0042612O74657279028O0003113O0066697265746F756368696E746572657374030C3O00546F7563685472692O676572030D3O00546F756368496E746572657374026O00F03F03043O0077616974026O00E03F001B3O00129D3O00013O00122O000100023O00202O00010001000300202O0001000100044O000100029O00000200044O0018000100203400050004000500262700050018000100060004333O00180001001292000500073O000E960007000B000100050004333O000B0001001229000600084O0054000700043O00202O00080004000900202O00080008000A00122O0009000B6O00060009000100122O0006000C3O00122O0007000D6O00060002000100044O001800010004333O000B000100060A3O0007000100020004333O000700012O007C3O00017O00", GetFEnv(), ...);