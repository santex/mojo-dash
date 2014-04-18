#!/usr/bin/env perl



BEGIN {
  $ENV{MOJO_NO_IPV6} = 1;
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
}


use Mojolicious::Controller ;
use Mojo::Base -strict;
use Mojo::IOLoop::Server;
use Mojo::IOLoop;
use Mojo::UserAgent;
use Mojolicious::Lite;
use Data::Printer;
# Make signed cookies secure
app->secrets(['Mojolicious rocks']);

my $cur = 'mojo get -r "http://www.google.co.uk/finance?q=CURRENCY%3AEUR&ei=aBsqU7CKIeaswAOrsQE" ".currencies"';

   $cur = `$cur`;

my $config = plugin 'Config';


any 'protected' => 'charts-xcharts';
any '/' => 'widgets'; 
any 'index' => 'widgets';
any 'dash' => 'page-dash',
any 'signin' => 'signin',
any 'page-inbox' => 'page-inbox';
any 'page-infrastructure' => 'page-infrastructure';
any 'page-todo' => 'page-todo';
any 'widgets' => 'widgets';
any 'file-manager' => 'file-manager';
any 'form-dropzone' => 'form-dropzone';

helper users => sub { state $users = MyUsers->new };

# Main login action
any '/login' => sub {
  my $self = shift;

  # Query or POST parameters
  my $user = $self->param('user') || '';
  my $pass = $self->param('pass') || '';


  if(!$user || !$pass){
#    return $self->redirect_to('/');
  }
  # Check password and render "index.html.ep" if necessary
  #$self->users;
#  return $self->render unless $self->users->check($user, $pass);

  # Store username in session
  $self->session(user => $user);

  # Store a friendly message for the next page in flash
  $self->flash(message => 'Thanks for logging in.');

  # Redirect to protected page with a 302 response
  $self->redirect_to('protected');
} => 'index';

# Make sure user is logged in for actions in this group
group {
  under sub {
    my $self = shift;

    # Redirect to main page with a 302 response if user is not logged in
    return 1 if $self->session('user');
    $self->redirect_to('index');
    return undef;
  };

  # A protected page auto rendering "protected.html.ep"
  get '/protected';
};

# Logout action
get '/logout' => sub {
  my $self = shift;

  # Expire and in turn clear session automatically
  $self->session(expires => 1);

  # Redirect to main page with a 302 response
  $self->redirect_to('index');
};


app->start();
