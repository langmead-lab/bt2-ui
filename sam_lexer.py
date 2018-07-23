from pygments.lexer import RegexLexer, bygroups
from pygments.token import *

class SamLexer(RegexLexer):
    name = "SAM"
    filenames = ["*.sam"]

    tokens = {
        'root': [
            (r'^@.*\n', Generic.Subheading),
            (r'([!-?A-~]{1,254})(\t)(\d+)(\t)(\*|[!-()+-<>-~][!-~]*)(\t)(\d+)(\t)(\d+)(\t)(\*|(?:[0-9]+[MIDNSHPX=])+)(\t)(\*|=|[!-()+-<>-~][!-~]*)(\t)(\d+)(\t)(-?\d+)(\t)(\*|[A-Za-z=.]+)(\t)([!-~]+)(\t)(.*?)$',
                    bygroups(Name.Attribute,
                        Whitespace,
                        Number,
                        Whitespace,
                        Name.Constant,
                        Whitespace,
                        Number,
                        Whitespace,
                        Number,
                        Whitespace,
                        String,
                        Whitespace,
                        Text,
                        Whitespace,
                        Number,
                        Whitespace,
                        Number,
                        Whitespace,
                        String,
                        Whitespace,
                        Text,
                        Whitespace,
                        Generic.Inserted))
        ]
    }
