{ 
	This program is lexical and parsing error-free.
}

program errorfree;
type
var
	z : string;
	result : string;
	a : integer;
	b : integer;
begin
	a := 1 + (2 + 3) + 4;
	b := a * 100;
end.