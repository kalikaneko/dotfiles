#!/usr/bin/perl

# Author: Trizen
# License: GPLv3
# Date: 12 February 2013
# http://trizen.googlecode.com

# Get the lyrics for the current playing song in mocp.

use 5.010;
use strict;
use warnings;

use WWW::Mechanize qw();
use File::Basename qw(basename);
use HTML::Entities qw(decode_entities);

my $DEBUG = 0;

my $old_title = '';

{
    my $info = `mocp --info &>/dev/stdout` // die "[!] moc player is not installed!\n";
    my ($title) = $info =~ m{^Title:\h+(.+)}m;

    if (not defined $title) {
        if ($info =~ m{^File:\h+(.+)}m) {
            my $basename = basename($1);
            $basename =~ s{\.\w+\z}{};
            $title = $basename;
        }
    }

    $title // do{sleep 3; redo};
    $title =~ s{\s*-\s*(\d+\s+)?}{ };
    $title =~ s{^\d+(?>\.\s*|\s+)}{};
    $title =~ s{\(.*?\)\s*$}{};
    $title =~ s{\s+$}{};
    $title =~ s{^VA }{};

    if ($old_title ne $title) {
        system 'reset';

        #print "\e[H\e[J\e[H";
        print STDERR "** Title: <$title>\n" if $DEBUG;

        my $lyrics = get_lyrics($title);

        if (defined $lyrics) {
            say $lyrics;
        }
        else {
            print STDERR "** Can't find lyrics for song <$title>\n";
        }
    }

    $old_title = $title;
    sleep 3;
    redo;
}

sub get_lyrics {
    my ($song_name) = @_;

    my $mech = WWW::Mechanize->new();
    $mech->get('https://google.com/');

    $mech->submit_form(
                       form_name => 'f',
                       fields    => {
                                  q => "$song_name lyrics",
                                 },
                       button => 'btnG',
                      );

    my @regexes = (
        {
         regex => qr{\beLyrics\.net$},
         code  => sub {
             my $content = shift;
             print STDERR "** Using eLyrics.net\n" if $DEBUG;
             if ($content =~ m{id='lyr'><div id='loading'></div>(.*?)</div>}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<br>}{\n}gi;
                 $lyrics =~ s{<em>.*?</em>}{}s;
                 $lyrics =~ s{<p>.*}{}s;
                 return $lyrics;
             }
             return;
           }
        },
        {
         regex => qr{\bMetroLyrics$},
         code  => sub {
             my $content = shift;
             print STDERR "** Using MetroLyrics.com\n" if $DEBUG;
             if ($content =~ m{<p class='verse'>(.*?</div>)}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<p class='verse'>}{\n\n}g;
                 $lyrics =~ s{<.*?>}{}sg;
                 return decode_entities($lyrics);
             }
             return;
           }
        },
        {
         regex => qr{\bLyrics Time$},
         code  => sub {
             my $content = shift;
             print STDERR "** Using LyricsTime.com\n" if $DEBUG;
             if ($content =~ m{<div\b.*? id="songlyrics".*?>.*?<p>\s*(.*?)</p>}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<br\s*/>}{}g;
                 return $lyrics;
             }
             return;
           }
        },
        {
         regex => qr{\buuLyrics$},
         code  => sub {
             my $content = shift;
             print STDERR "** Using uuLyrics.com\n" if $DEBUG;
             if ($content =~ m{<br/>\s+<br/>\s+</div>\s+(.*?)\s+<div align="left">}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<br />}{\n}g;
                 return $lyrics;
             }
             return;
           }
        },
        {
         regex => qr{^Lyrics »},
         code  => sub {
             my $content = shift;
             print STDERR "** Using w3lyrics.com\n" if $DEBUG;
             if ($content =~ m{<u>Original language lyrics:</u></div>\s*<p>(.*?)</p>}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<br/>}{\n}g;
                 return $lyrics;
             }
             return;
           }
        },
        {
         regex => qr{\bLyrics Mania$},
         code  => sub {
             my $content = shift;
             print STDERR "** Using LyricsMania.com\n" if $DEBUG;
             if ($content =~ m{<div id='songlyrics_h' class='dn'>\s*(.*?)</div>}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<br />}{}g;
                 return $lyrics;
             }
             return;
           }
        },
        {
         regex => qr{^Versuri },
         code  => sub {
             my $content = shift;
             print STDERR "** Using versuri.ro\n" if $DEBUG;
             if ($content =~ m{</p><br />(.*?)<p\b}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<br />}{}g;
                 return decode_entities($lyrics);
             }
             return;
           }
        },
        {
         regex => qr{\bRap Genius$},
         code  => sub {
             my $content = shift;
             print STDERR "** Using rapgenius.com\n" if $DEBUG;
             if ($content =~ m{<div class="lyrics".*?>\s*(.*?)</div>}s) {
                 my $lyrics = $1;
                 $lyrics =~ s{<.*?>}{}gs;
                 return $lyrics;
             }
             return;
           }
        },
    );

    foreach my $hash_ref (@regexes) {
        if (defined(my $link = $mech->find_link(text_regex => $hash_ref->{regex}))) {
            $mech->get($link->url());
            my $text = $hash_ref->{code}($mech->content);

            if (defined($text)) {
                return unpack "A*", $text;
            }
            else {
                $mech->back();
            }
        }
    }

    return;
}
