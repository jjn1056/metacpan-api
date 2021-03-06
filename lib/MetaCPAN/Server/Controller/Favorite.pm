package MetaCPAN::Server::Controller::Favorite;

use strict;
use warnings;

use Moose;
use MetaCPAN::Util qw( single_valued_arrayref_to_scalar );

BEGIN { extends 'MetaCPAN::Server::Controller' }

with 'MetaCPAN::Server::Role::JSONP';

sub find : Path('') : Args(2) {
    my ( $self, $c, $user, $distribution ) = @_;

    # Do this for now and we don't have to worry about purging it
    $c->cdn_never_cache(1);

    eval {
        my $favorite = $self->model($c)->raw->get(
            {
                user         => $user,
                distribution => $distribution
            }
        );
        $c->stash( $favorite->{_source}
                || single_valued_arrayref_to_scalar( $favorite->{fields} ) );
    } or $c->detach( '/not_found', [$@] );
}

sub by_user : Path('by_user') : Args(1) {
    my ( $self, $c, $user ) = @_;
    my $size = $c->req->param('size') || 250;

    my $data = $self->model($c)->by_user( $user, $size );

    $data
        ? $c->stash($data)
        : $c->detach( '/not_found',
        ['The requested info could not be found'] );
}

sub users_by_distribution : Path('users_by_distribution') : Args(1) {
    my ( $self, $c, $distribution ) = @_;

    my $data = $self->model($c)->users_by_distribution($distribution);

    $data
        ? $c->stash($data)
        : $c->detach( '/not_found',
        ['The requested info could not be found'] );
}

sub recent : Path('recent') : Args(0) {
    my ( $self, $c ) = @_;
    my $page = $c->req->param('page') || 1;
    my $size = $c->req->param('size') || 100;

    my $data = $self->model($c)->recent( $page, $size );

    $data
        ? $c->stash($data)
        : $c->detach( '/not_found',
        ['The requested info could not be found'] );
}

sub leaderboard : Path('leaderboard') : Args(0) {
    my ( $self, $c ) = @_;

    my $data = $self->model($c)->leaderboard();

    $data
        ? $c->stash($data)
        : $c->detach( '/not_found',
        ['The requested info could not be found'] );
}

sub agg_by_distributions : Path('agg_by_distributions') : Args(0) {
    my ( $self, $c ) = @_;

    my $distributions = $c->read_param('distribution');
    my $user          = $c->req->param('user');           # optional
    my $data
        = $self->model($c)->agg_by_distributions( $distributions, $user );

    $data
        ? $c->stash($data)
        : $c->detach( '/not_found',
        ['The requested info could not be found'] );
}

__PACKAGE__->meta->make_immutable;
1;
