{ 
	This program is lexical and parsing error-free.
}

program errorfree;
type
    kid = record
        name : string
    end;
	r = record
		a,b : integer;
		c   : string;
		son : kid
	end;	
	y = array[1..10] of integer;
	s = string;
var
	z : s;
	rec : r;
function foo1(a : integer) : r; 
begin
   z := "hello kitty"
end;
function bar() : string; forward;
function foo2(a : integer; c : string) : y; 
begin
   while a do
       bar()
end;

function foo3(a, b : integer) : s; forward;
begin
    rec.son.name := "hello"
end.