#!/usr/bin/perl
use Data::Dumper;
use HTML::TableExtract;
use Digest::MD5 qw(md5 md5_hex md5_base64);



my @xrow=();
my @yrow=();

my $te = HTML::TableExtract->new(depth =>0, count =>$ARGV[0]!~/BUY/?1:0);
my $out = `mojo get -r https://www.bitcoin.de/en/market table`;
  $te->parse($out);

  # Examine all matching tables
  foreach my $ts ($te->tables) {
    print "Table (", join(',', $ts->coords), "):\n";
    foreach my $row ($ts->rows) {
       #map{chomp $_}@$row;

       
       my $allow=0;
       @yrow = ();
       foreach(map{$a=$_; $a=~s/( |\t||\n|\r\n)//g; $_=$a;}@$row){
         $_=~ s/€//g;

       push @yrow,$_ unless(length($_)<3 || $_ =~/others/);

       if($_=~/SELL|BUY/){
         
          push @xrow,[@yrow] if($yrow[0] =~ /^[1-9].*/);


          $yrow[0] =~ s/\(.*.$//g;

                     push @yrow,`date +%I`;
          my $id = md5_hex(@yrow);
$x = "INSERT IGNORE INTO  BTCtoEURO (priceInEuro,typex,volume,moreBucket) VALUES ($yrow[1],'$yrow[3]', $yrow[0],'$id');";

`echo "$x" | mysql -uroot -ppass btc`;

`echo 'INSERT IGNORE INTO BTCAlgo(DateTime, priceInEuro, highInEuro, lowInEuro,upvolume,downvolume, algo, moreBucket) VALUES (null,(select avg(priceInEuro) from BTCtoEURO),(select max(priceInEuro) from BTCtoEURO),(select min(priceInEuro) from BTCtoEURO),(select sum(volume) from BTCtoEURO where typex="BUY"),(select sum(volume) from BTCtoEURO where typex="SELL"),"","");' | mysql -uroot -ppass btc`;
          @yrow=();

        }
        
       
       }
      # print join(',',@$row);
    }
  }
