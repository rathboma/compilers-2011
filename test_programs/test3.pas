{ 
	This program is lexical and parsing error-free. 
	It has multi-declaration error.
}

program errorfree;
type
	s = string;
	in = integer;
var
	z : in;
	m : in;

begin
	z := 5;
	m := 7;
    p := m; {error: undeclared variable}	
end.