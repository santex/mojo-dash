create DATABASE IF NOT EXISTS `btc`;
use btc;

CREATE TABLE IF NOT EXISTS `BTCtoEURO` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `priceInEuro` double unsigned NOT NULL DEFAULT '0',
  `typex` enum('BUY','SELL','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
  `volume` int(5) NOT NULL DEFAULT '0',
  `moreBucket` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `moreBucket` (`moreBucket`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=65491 ;



CREATE TABLE IF NOT EXISTS `BTCAlgo` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `DateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `priceInEuro` double unsigned NOT NULL DEFAULT '0',
  `highInEuro` double unsigned NOT NULL DEFAULT '0',
  `lowInEuro` double unsigned NOT NULL DEFAULT '0',
  `upvolume` int(5) NOT NULL DEFAULT '0',
  `downvolume` int(5) NOT NULL DEFAULT '0',
  `algo` tinytext NOT NULL,
  `moreBucket` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `DateTime` (`DateTime`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=45176 ;

--
-- Dumping data for table `BTCAlgo`
--

