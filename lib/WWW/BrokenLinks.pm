package WWW::BrokenLinks;

use 5.014;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use WWW::Mechanize;
use URI;

our $VERSION = '0.01';

has 'base_url' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'debug' => (
  is => 'ro',
  isa => 'Bool',
  required => 0,
  default => 0,
);

sub crawl
{
  my $self = shift;
  my @crawl_queue = ();
  my @broken_links = ();
  my %scanned_urls = ();
  
  my $mech = WWW::Mechanize->new();
  my $current_url = $self->base_url;
  $scanned_urls{$current_url} = 1;
  
  while ($current_url)
  {
    my $response = $mech->get($current_url);
    my @links = $mech->links();
    
    for my $link (@links)
    {
      my $abs_url = URI->new_abs($link->url, $current_url)->canonical;
      
      $response = $mech->get($abs_url);
      
      if ($response->is_success)
      {
        if ($abs_url =~ m/$self->base_url/ && !exists($scanned_urls{$abs_url}))
        {
          # Local link which we haven't checked, so add to the crawl queue
          push(@crawl_queue, $abs_url);
        }
        
        # Always mark a successful URL as scanned, even if it is not local
        $scanned_urls{$abs_url} = 1;
      }
      else
      {
        push(@broken_links, {'source' => $current_url, 'dest' => $abs_url});
        print $current_url . ',' . $abs_url . "\n";
      }
    }
    
    sleep 1;
    
    $current_url = pop(@crawl_queue);
  }
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__

# ABSTRACT: Finds broken links on a website.
