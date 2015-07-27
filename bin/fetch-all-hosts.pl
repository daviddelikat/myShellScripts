#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use Zabbix::API;
use JSON;
use IO::All;

=pod

sample file:  ~/.zabbixrc

----

{ "host" : "http://zabbix.plainblack.com/api_jsonrpc.php", "user" : "your username", "password" : "your password" }

----

=cut

## This script loads all hosts from the server and dumps their data to YAML
## documents.

my $config = JSON->new->decode(io("$ENV{HOME}/.zabbixrc")->slurp);

my $zabber = Zabbix::API->new(server => $config->{host});

eval { $zabber->login(user => $config->{user}, password => $config->{password}) };

if ($@) {

    my $error = $@;
    die "Could not log in: $error";

}

#print JSON->new->pretty->encode($_->data) foreach @{$zabber->fetch('Host')};
print $_->data->{dns}."\n" foreach @{$zabber->fetch('Host')};

eval { $zabber->logout };
if ($@) {

    my $error = $@;

    given ($error) {

        when (/Invalid method parameters/) {

            # business as usual

        }

        default {

            die "Unexpected exception while logging out: $error";

        }

    }

}

