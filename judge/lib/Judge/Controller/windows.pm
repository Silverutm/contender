package Judge::Controller::windows;
use Moose;
use namespace::autoclean;

use strict;
use warnings;
use feature 'state';

use Database;
use Judge::Model::User;

BEGIN { extends 'Catalyst::Controller'; }

sub windows
  :Chained("/contest/index")
  :PathPart("windows")
  :Args() {

  my ($self, $c, %args) = @_;
  my $contest = $c->stash->{contest};

  return if not Judge::Model::User::force($c)->administrator;
  return if not $contest->windowed;

  my $results = db->resultset('windows')->search({contest_id => $contest->id}, {
    order_by => {
      '-desc' => [qw(start_time+duration start_time)],
    },
  });

  my $ipp = 200;
  my $pagecount = int(($ipp - 1 + $results->count) / $ipp) || 1;
  $args{page} = int($args{page} || 1);
  $args{page} = 1          if $args{page} < 1;
  $args{page} = $pagecount if $args{page} > $pagecount;

  my @windows = $results->search({}, {rows => $ipp})->page($args{page})->all;

  my @pages = ($args{page});
  $pages[0]-- while 1 < $pages[0] and ($args{page} - $pages[0] < 2 or $pages[0] + 4 > $pagecount);
  push @pages, $pages[$#pages] + 1 while @pages < 5 and $pages[$#pages] < $pagecount;

  $c->stash(
    template => 'windows.tx',
    title => 'Windows',
    tab => 'Windows',
    user => Judge::Model::User::force($c),
    windows => {
      Running  => [grep {not ($_->end_time->epoch <= $c->stash->{now}->epoch)} @windows],
      Finished => [grep {    ($_->end_time->epoch <= $c->stash->{now}->epoch)} @windows],
    },
    pagecount => $pagecount,
    page => $args{page},
    pages => \@pages,
  );
}

__PACKAGE__->meta->make_immutable;

1;
