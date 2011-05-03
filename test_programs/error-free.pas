{ 
	This program is lexical and parsing error-free.
}

program errorfree;
type
	r = record
		a,b : integer;
		c   : string
	end;
	y = array[1..10] of integer;
	s = string;
var
	z : s;
	result : s;
begin
	z := "hello";
	result := z + " world";
end.