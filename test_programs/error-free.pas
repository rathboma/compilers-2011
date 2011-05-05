{ 
	This program is lexical and parsing error-free.
}

program errorfree;
type
    y = array[1..10] of integer;
    person = record
        name : string;
        age : integer;
        zips : y
    end;
var
    john : person;
    frank : person;
	a : integer;
	b : integer;
	val : string;
	ary : y;
procedure bar(x : integer; y: integer); forward;
begin
	a := 1 + (2 + 3) + 4;
	b := a * 100;
	john.name := "john";
	frank.name := john.name;
	ary[1] := 1;
	frank.zips[1] := 2;
	john := frank;
	john.name := "frank";
	bar(1, 2);
{	john.age := b;
	val := john.name;
	john.name := "not john";}
end.