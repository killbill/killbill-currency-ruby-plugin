CREATE TABLE `currency_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `base_currency` varchar(3) NOT NULL,
  `conversion_date` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_base_currency` (`base_currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `currency_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_currency` varchar(3) NOT NULL,
  `rate` decimal(10,4) NOT NULL,
  `currency_update_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_currency_update_id` (`currency_update_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
