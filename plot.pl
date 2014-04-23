use strict;

use Data::Dumper;
use DBI;
use Math::Business::LaguerreFilter;
use Math::Business::WMA;
use Math::Business::EMA;
use Math::Business::HMA;
use Math::Business::SMA;
use Math::Business::ParabolicSAR;
use Math::Business::BollingerBands;

use GD::Graph::mixed;
use List::Util qw(min max);


my $algos = {LaguerreFilter => new Math::Business::LaguerreFilter,
             LaguerreFilter0 => new Math::Business::LaguerreFilter,
             LaguerreFilter1 => new Math::Business::LaguerreFilter,
              
             BollingerBands => Math::Business::BollingerBands->recommended,
             SMA            => new Math::Business::SMA,
             EMA            => new Math::Business::EMA,
             WMA            => new Math::Business::WMA,
             HMA            => new Math::Business::HMA};

$_=~/LaguerreFilter/ ? $algos->{$_}->set_alpha(0.3) : $algos->{$_}->set_days(21) for keys %$algos;



my $avg = new Math::Business::SMA;
    $avg->set_days(21);
my $avg2 = new Math::Business::SMA;
    $avg2->set_days(21);
my $avg3 = new Math::Business::SMA;
    $avg3->set_days(21);

sub DB{
  my $DB = 0;
  my $pass = shift;
  eval{
  use DBI;
  my $dsn = "DBI:mysql:btc:localhost";
   $DB = DBI->connect($dsn,"monty","some_pass") or
  die('db connection could not be initialiesed!');
  };

  return $DB;
}

my $dbo = DB();

my @ohlc = reverse @{$dbo->selectall_arrayref(qq/
   SELECT  `DateTime`,`priceInEuro`,max( `priceInEuro`),min(`priceInEuro`),avg(`priceInEuro`) FROM  BTCtoEURO group by typex,DAY(DateTime),HOUR(DateTime),MINUTE(DateTime) order by DateTime desc

/, {})};

my $sar = Math::Business::ParabolicSAR->recommended;

           my @data;
           for my $p (@ohlc) {
               my $d = shift @$p;
               $d =~ s/://g;
           #    my $v = pop @$p;

               #push @{$data[4]}, $v;

             #  $sar->insert($p);

          



         $algos->{LaguerreFilter}->insert( $p->[0]);

        if(defined(my $q =$algos->{LaguerreFilter}->query))     {
               $p->[0] =  $q;
               
               $algos->{BollingerBands}->insert( $p->[0]);

        }if(defined(my $q =$algos->{LaguerreFilter0}->query))     {
               $p->[1] =  $q;
        }if(defined(my $q =$algos->{LaguerreFilter1}->query))     {
               $p->[2] =  $q;
        }

         # choose one:
         $avg->insert( $p->[0]);
         # choose one:
         $avg2->insert( $p->[2]+$p->[1]-$p->[2]);
         # choose one:
         $avg3->insert( $p->[2]+$p->[1]-$p->[2]);

         if($#data>20){
         $sar->insert($p);
         }
         if( defined(my $q = $avg->query) ) {
             push @{$data[1]}, $q;
         } else {
#             push @{$data[1]}, $p->[0]; # close
         }
         if( defined(my $q = $avg3->query) ) {
             push @{$data[2]}, $q;
         } else {
#             push @{$data[2]}, $p->[0]; # close
         }
         if( defined(my $q = $avg2->query) ) {
             push @{$data[3]}, $q;
         } else {
 #            push @{$data[3]}, $p->[2]; # close
         }

               push @{$data[0]}, $d;      # date
               
               my ($L,$M,$U) = $algos->{BollingerBands}->query();

                push @{$data[4]},$L;
                push @{$data[5]},$M;
                push @{$data[6]},$U;
                push @{$data[7]}, $sar->query;

           }
           

           my @all_points = grep {defined $_} map {@$_} @data[1 .. $#data];
           my $min_point  = min(@all_points);
           my $max_point  = max(@all_points);

           my $graph = GD::Graph::mixed->new(6000, 550);
              $graph->set(
                  y_label           => 'dollars',
                  transparent       => 0,
                #  markers           => [qw(7 3 9 9 9 9)],
                #  dclrs             => [qw(black lgreen red lred blue lgreen yellow)],
                  y_min_value       => $min_point-0.2,
                  y_max_value       => $max_point+0.2,
                #  x_labels_vertical => 1,
                 types             => [qw(lines area area lines lines lines points points)],

              ) or die $graph->error;

           
           my $gd = $graph->plot(\@data) or die $graph->error;
           open my $img, '>', "sar.png" or die $!;
           binmode $img;
print $img $gd->png;
close $img;
