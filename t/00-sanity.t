use Deb822;
use Test;

plan 22;

is-deeply Deb822::hash-from-string(""), ().Seq, "Empty file";
is-deeply Deb822::hash-from-string("# a comment"), ().Seq, "One comment";
is-deeply Deb822::hash-from-string("# a comment\n# two comment"), ().Seq, "Two comment";
is-deeply Deb822::hash-from-string("# a comment\n\n# another comment"), ().Seq, "Two comment with empty line separator";
dies-ok { Deb822::hash-from-string(" # not a comment") }, "Malformed comment";

is-deeply Deb822::hash-from-string("Test-abc: plm"),
        @({ Test-abc => 'plm' },),
        "simple element";
is-deeply Deb822::hash-from-string("Test-abc: \n plm"),
        @({ Test-abc => 'plm' },),
        "simple element in next line";
is-deeply Deb822::hash-from-string("Test-abc: plm\n# a comment"),
        @({ Test-abc => 'plm' },),
        "simple element preceed comment";
is-deeply Deb822::hash-from-string("# a comment\nTest-abc: plm\n# a comment"),
        @({ Test-abc => 'plm' },),
        "simple element next comment";

is-deeply Deb822::hash-from-string("Test-abc: plm\nToto:tata"),
        @({ Test-abc => 'plm', Toto => 'tata' },),
        "two elements";
is-deeply Deb822::hash-from-string("Test-abc: plm\n# a comment\nToto: tata"),
        @({ Test-abc => 'plm', Toto => 'tata' },),
        "two elements with a comment";
is-deeply Deb822::hash-from-string("# a comment\nToto: tata\nTest-abc: plm\n# a comment"),
        @({ Test-abc => 'plm', Toto => 'tata' },),
        "two elements with three comment";

is-deeply Deb822::hash-from-string("Test-abc: plm\n asd"),
        @({ Test-abc => "plm\nasd" },),
        "one element multi-line";
is-deeply Deb822::hash-from-string("Test-abc: plm\n# a comment\n asd"),
        @({ Test-abc => "plm\nasd" },),
        "one element multi-line, with comment inside";
is-deeply Deb822::hash-from-string("Test-abc: plm\n# a comment\n asd\n# a comment"),
        @({ Test-abc => "plm\nasd" },),
        "one element multi-line, with comment inside and after";

is-deeply Deb822::hash-from-string("Test-abc: plm\n # not a comment"),
        @({ Test-abc => "plm\n# not a comment" },),
        "one element multi-line with #";
is-deeply Deb822::hash-from-string("Test-abc: plm\n# a comment\n # not a comment"),
        @({ Test-abc => "plm\n# not a comment" },),
        "one element multi-line with #";
is-deeply Deb822::hash-from-string("Test-abc: plm\n# a comment\n # not a comment\n# a comment"),
        @({ Test-abc => "plm\n# not a comment" },),
        "one element multi-line with #";

is-deeply Deb822::hash-from-string("Test-abc: plm\n .\n asd"),
        @({ Test-abc => "plm\n\nasd" },),
        "one element multi-line, with paragraph";
is-deeply Deb822::hash-from-string("Test-abc: \n plm\n .\n asd"),
        @({ Test-abc => "plm\n\nasd" },),
        "one element multi-line, with paragraph";

is-deeply Deb822::hash-from-string("Test-abc: plm\n .\n asd\n\nTest-abc: plm\n .\n asd"),
        @({ Test-abc => "plm\n\nasd" }, { Test-abc => "plm\n\nasd" }),
        "two stanzas";
is-deeply Deb822.from-string("Test-abc: plm\n .\n asd\n\nTest-abc: plm\n .\n asd"),
        @(Deb822.new(Test-ABC => "plm\n\nasd"), Deb822.new(TEST-abc => "plm\n\nasd")),
        "two stanzas";

done-testing;
