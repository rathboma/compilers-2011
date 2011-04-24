{
	Use this program to test your lexer
}
	
program lexer_test;

type
    s = string;
    p = record
        a: integer;
        b: string
    end;
var
        foo: string;
    	moo : p;
begin
    foo := "hello";
    moo.a := foo;
end.
