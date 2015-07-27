source ~/perl5/perl/bin/citrusvars.sh

perl <<'EOP'

use Wx;

my $app = Wx::SimpleApp->new;
my $frame = Wx::Frame->new( undef, -1, 'Hello, world!' );

$frame->Show;
$app->MainLoop;

EOP

