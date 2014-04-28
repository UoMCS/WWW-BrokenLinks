package WWW::BrokenLinks;

use 5.014;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__

# ABSTRACT: Finds broken links on a website.
