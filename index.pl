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
use Mojo::Upload;
use feature 'say';

# Make signed cookies secure
app->secrets(['Mojolicious rocks']);

my $cur = 'mojo get -r "http://www.google.co.uk/finance?q=CURRENCY%3AEUR&ei=aBsqU7CKIeaswAOrsQE" ".currencies"';

   $cur = `$cur`;

my $config = plugin 'Config';
any '/' => 'base';
any 'form-dropzone' => 'form-dropzone';
any 'widgets' => 'widgets';
any '/text' => 'base2';

helper users => sub { state $users = MyUsers->new };

get '/login' => sub {
  my $self = shift;
  my $name = $self->param('name') || 'anonymous';
  $self->session(name => $name);
  $self->render(text => "Welcome $name!");
};

get '/again' => sub {
  my $self = shift;
  my $name = $self->session('name') || 'anonymous';
  $self->render(text => "Welcome back $name!");
};

get '/logout' => sub {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('login');
};
# Main login action
any '/login' => sub {
 my $self = shift;
  my $name = $self->param('name') || 'anonymous';
  $self->session(name => $name);
  $self->render(text => "Welcome $name!");

  
  # Store username in session
  $self->session(user => $name);

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


post '/upload' => sub {
  my $self = shift;
    

my $upload = Mojo::Upload->new;
$upload->move_to('/tmp/');

#$self->redirect_to();

}=>'/';

# Logout action
get '/logout' => sub {
  my $self = shift;

  # Expire and in turn clear session automatically
  $self->session(expires => 1);

  # Redirect to main page with a 302 response
  $self->redirect_to('index');
};


app->start();
