##################
# Author: Angelo Gonzalez
#
# Perl Mini-Pascal Parser
#
# takes in a mini pascal program as input
# and then parses it for syntax errors
#
##################

open (INFILE, "<", $ARGV[0]) or die ("didn't find file to open.");

{
	local $/;
	$input = <INFILE>;
}
   
sub lex
{
	#initialize all booleans to false every time lex is called
	$variable = 0;
	$constant = 0;
	$progname = 0;
	
	#print "$input";
	if ($input =~ m/^\s*(program|begin|\;|end|:=|read|write|if|then|else|while|do|\+|\-|\*|\/|\(|\)|,|\=|<=|>=|<>|<|>)/)
	{
		$nextToken = $1;
		$input = $'; # reset input to be everything after the token
	}
	#match for progname
	elsif($input =~ m/^\s*[A-Z]([a-zA-Z]|\d)*/)
	{
		$progname = true;
		$nextToken = $&;
		$input = $';
	}
	#match for variable
	elsif($input =~ m/^\s*[a-zA-Z]([a-zA-Z]|\d)*/)
	{
		$variable = true;
		$nextToken = $&;
		$input = $';
	}
	
	#match for constant
	elsif($input =~ m/^\s*\d\d*/)
	{
		$constant = true;
		$nextToken = $&;
		$input = $';
	}
	
	elsif ($input =~ m/^\s*$/)
	{
		$nextToken = "";
	}
	else
	{
		error("didn't find a valid token, saw >$input<");
	}
	#print "Found token >$nextToken<\n";
}

lex();
program();

# examine if $nextToken has anything in it, if so, error (extra stuff)
if ($nextToken ne "")
{
	error("Extra stuff at the end: $nextToken");
}
else
{
	print "Valid sentence.\n";
}

sub program 
{
	if ($nextToken eq "program")
	{
		lex();
		if ($progname)
		{
			lex();
		}
		else
		{
			error("expected progname, but saw $nextToken\n");
		}
	}
	else
	{
		error("expected program, but saw $nextToken\n");
	}
	compoundStmt();
	
}

sub compoundStmt 
{	
	if ($nextToken eq "begin")
	{
		lex();
		stmt();
		while ($nextToken eq ";")
		{
			lex();
			stmt();
		}
		
		if ($nextToken eq "end")
		{
			lex();
			
		}
		else
		{
			error("expected end, but saw >$nextToken<\n");
		}
	}
	else
	{
		error("expected begin, but saw >$nextToken<\n");
	}
	
}

#This subroutine combines all of the statement productions into one
sub stmt
{
	#assignment statment
	if ($variable || $progname)
	{
		lex();
		
		
		if ($nextToken eq ":=")
		{
			lex();
			expression();
		}
		else
		{
			error("expeceted :=, but saw >$nextToken<\n");
		}
	}
	
	#read statement
	elsif ($nextToken eq "read")
	{
		lex();
		if($nextToken eq "(")
		{
			lex();
			if($variable || $progname)
			{
				lex();
				while ($nextToken eq ",")
				{
					lex();
					if($variable || $progname)
					{
						lex();
					}
					else
					{
						error("expected <variable>, but saw >$nextToken<\n");
					}
				}
				if ($nextToken eq ")")
				{
					lex();
				}
				else
				{
					error("expected ), but saw >$nextToken<\n");
				}
				
			}
			else
			{
				error("expected <variable>, but saw >$nextToken<\n");
			}
		}
	}
	
	#write statement
	elsif ($nextToken eq "write")
	{
		lex();
		if($nextToken eq "(")
		{
			lex();
			expression();
			
			while($nextToken eq ",")
			{
				lex();
				expression();
			}
			if($nextToken eq ")")
			{
				lex();
			}
			else
			{
				error("expected ), but saw >$nextToken<\n");
			}
		}
		else 
		{
			error("expected (, but saw >$nextToken<\n");
		}
	}
	
	#another compund statement
	elsif($nextToken eq "begin")
	{
		compoundStmt();
	}
	
	#if statement
	elsif($nextToken eq "if")
	{
		lex();
		expression();
		if($nextToken eq "then")
		{
			lex();
			stmt();
			if($nextToken eq "else")
			{
				lex();
				stmt();
			}
		}
		else
		{
			error("expected then, but saw >$nextToken\n");
		}
	}
	
	#while statement
	elsif ($nextToken eq "while")
	{
		lex();
		expression();
		if($nextToken eq "do")
		{
			lex();
			stmt();
		}
		else 
		{
			error("expected do, but saw >$nextToken\n");
		}
	}
	else
	{
		error("expected <variable>, read, write, begin or while but saw >$nextToken<");
	}
}

sub expression()
{
	
	simpleExpr();
	if ($nextToken eq "=" || $nextToken eq "<>" || $nextToken eq "<" || $nextToken eq "<=" || $nextToken eq ">=" || $nextToken eq ">")
	{
		lex();
		simpleExpr();
	}
}

sub simpleExpr
{
	if ($nextToken eq "+" || $nextToken eq "-")
	{
		lex();
	}
	
	term();
	
	while ($nextToken eq "+" || $nextToken eq "-")
	{
		lex();
		term();
	}
	
}

sub term 
{
	factor();
	
	while ($nextToken eq "*" || $nextToken eq "/")
	{
		lex();
		factor();
	}
}

sub factor
{
	if ($variable || $progname)
	{
		lex();
	}
	elsif ($constant)
	{
		lex();
	}
	elsif ($nextToken eq "(")
	{
		lex();
		expression();
		if ($nextToken eq ")")
		{
			lex();
		}
		else
		{
			error("expected ), but saw >$nextToken<\n");
		}
	}
	else
	{
		error("expected <variable>, <constant> or (, but saw >$nextToken<\n");
	}
}

sub error
{
	die "SYNTAX ERROR: $_[0]\n";
}