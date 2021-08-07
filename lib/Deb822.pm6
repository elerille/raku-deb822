unit class Deb822;

has %.data is required;

method new(::?CLASS:U: *%kvargs --> Deb822:D) {
    self.bless: data => %kvargs.map({ $_.key.fc => $_.value });
}

method from-string(::?CLASS:U: Str:D $data --> Seq:D) {
    Deb822::hash-from-string($data).map({ Deb822.new: |$_ });
}

our sub hash-from-string(Str:D $data --> Seq:D) {
    my $line = 0;
    my %stanza;
    my $last-key;
    gather {
        for $data.lines {
            ++$line;
            when .starts-with('#') { next }
            when ' .' { %stanza{$last-key // die "Malformed file at line $line (\$last-key not inizialized"} ~= "\n" }
            when .starts-with(' ') {
                if %stanza{$last-key // die "Malformed file at line $line (\$last-key not inizialized"} eq '' {
                    %stanza{$last-key // die "Malformed file at line $line (\$last-key not inizialized"} = .substr(1)
                } else {
                    %stanza{$last-key // die "Malformed file at line $line (\$last-key not inizialized"} ~= "\n" ~
                            .substr(1)
                }
            }
            when /":"/ {
                my ($k, $v) = .split(":", 2);
                $last-key = $k;
                %stanza{$last-key} = $v.trim;
            }
            when "" {
                if %stanza {
                    take %stanza;
                    %stanza = %;
                    $last-key = Str;
                }
            }
            default { die "Can't parse line $line" }
        }
        if %stanza {
            take %stanza;
        }
    }
}