CREATE TABLE `club_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `club_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT '',
  `address` varchar(255) DEFAULT '',
  `telephone_1` varchar(255) DEFAULT '',
  `telephone_2` varchar(255) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  `num_members` int(11) DEFAULT '0',
  `date_founded` date DEFAULT NULL,
  `motto` varchar(255) DEFAULT '',
  `objective` varchar(255) DEFAULT '',
  `eligibility` varchar(255) DEFAULT '',
  `work_plan` varchar(255) DEFAULT '',
  `form_submitter_position` varchar(255) DEFAULT '',
  `patron` varchar(255) DEFAULT '',
  `intended_duty` text,
  `founding_motivation` varchar(255) DEFAULT '',
  `cooperation_ideas` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;

CREATE TABLE `clubs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL DEFAULT '',
  `telephone_1` varchar(255) NOT NULL DEFAULT '',
  `telephone_2` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `num_members` int(11) NOT NULL DEFAULT '0',
  `date_founded` date DEFAULT NULL,
  `motto` varchar(255) NOT NULL DEFAULT '',
  `objective` varchar(255) NOT NULL DEFAULT '',
  `eligibility` varchar(255) NOT NULL DEFAULT '',
  `work_plan` varchar(255) NOT NULL DEFAULT '',
  `form_submitter_position` varchar(255) NOT NULL DEFAULT '',
  `patron` varchar(255) NOT NULL DEFAULT '',
  `intended_duty` text NOT NULL,
  `founding_motivation` varchar(255) NOT NULL DEFAULT '',
  `cooperation_ideas` text NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;

CREATE TABLE `customer_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `note` mediumtext,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_customer_notes_on_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=242 DEFAULT CHARSET=utf8;

CREATE TABLE `customer_type_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_type_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `description` varchar(255) DEFAULT '',
  `category` varchar(255) DEFAULT 'Unknown',
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;

CREATE TABLE `customer_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `category` varchar(255) NOT NULL DEFAULT 'Unknown',
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

CREATE TABLE `customer_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `customer_type_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `district` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `deliver_via` varchar(255) DEFAULT NULL,
  `delivery_method_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `contact_position` varchar(255) DEFAULT NULL,
  `telephone_1` varchar(255) DEFAULT NULL,
  `telephone_2` varchar(255) DEFAULT NULL,
  `telephone_3` varchar(255) DEFAULT NULL,
  `fax` varchar(255) DEFAULT NULL,
  `email_1` varchar(255) DEFAULT NULL,
  `email_2` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `po_box` varchar(255) DEFAULT NULL,
  `route` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7374 DEFAULT CHARSET=utf8;

CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `customer_type_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `district` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `deliver_via` varchar(255) DEFAULT NULL,
  `delivery_method_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `contact_position` varchar(255) DEFAULT NULL,
  `telephone_1` varchar(255) DEFAULT NULL,
  `telephone_2` varchar(255) DEFAULT NULL,
  `telephone_3` varchar(255) DEFAULT NULL,
  `fax` varchar(255) DEFAULT NULL,
  `email_1` varchar(255) DEFAULT NULL,
  `email_2` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `po_box` varchar(255) DEFAULT NULL,
  `route` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2416 DEFAULT CHARSET=utf8;

CREATE TABLE `delivery_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `abbreviation` varchar(255) NOT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `include_in_distribution_quote_request` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `district_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `district_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT '',
  `color` varchar(255) DEFAULT '',
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT '',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `districts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `region_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `color` varchar(255) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` varchar(255) NOT NULL,
  `version` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `issue_box_size_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_box_size_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `issue_id` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;

CREATE TABLE `issue_box_sizes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8;

CREATE TABLE `issue_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) NOT NULL,
  `note` text NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_issue_notes_on_issue_id` (`issue_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `issue_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `publication_id` int(11) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `issue_number` varchar(255) NOT NULL DEFAULT '',
  `quantity` int(11) NOT NULL DEFAULT '0',
  `num_copies_in_house` int(11) NOT NULL DEFAULT '0',
  `allows_new_special_orders` tinyint(1) NOT NULL DEFAULT '1',
  `inventory_comment` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8;

CREATE TABLE `issues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `publication_id` int(11) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `issue_number` varchar(255) NOT NULL DEFAULT '',
  `quantity` int(11) NOT NULL DEFAULT '0',
  `num_copies_in_house` int(11) NOT NULL DEFAULT '0',
  `allows_new_special_orders` tinyint(1) NOT NULL DEFAULT '1',
  `inventory_comment` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;

CREATE TABLE `order_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `issue_id` int(11) DEFAULT NULL,
  `standing_order_id` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `district` varchar(255) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `deliver_via` varchar(255) DEFAULT NULL,
  `delivery_method_id` int(11) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `contact_details` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19314 DEFAULT CHARSET=utf8;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `issue_id` int(11) DEFAULT NULL,
  `standing_order_id` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `district` varchar(255) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `deliver_via` varchar(255) DEFAULT NULL,
  `delivery_method_id` int(11) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `contact_details` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_orders_on_issue_id` (`issue_id`),
  KEY `index_orders_on_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10995 DEFAULT CHARSET=utf8;

CREATE TABLE `publication_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `publication_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `tracks_standing_orders` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

CREATE TABLE `publications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `tracks_standing_orders` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

CREATE TABLE `region_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `region_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `population` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8;

CREATE TABLE `regions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `population` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `roles_users` (
  `role_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  KEY `index_roles_users_on_role_id` (`role_id`),
  KEY `index_roles_users_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `special_order_line_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `special_order_line_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `special_order_id` int(11) DEFAULT NULL,
  `issue_id` int(11) DEFAULT NULL,
  `num_copies_requested` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8;

CREATE TABLE `special_order_lines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `special_order_id` int(11) NOT NULL,
  `issue_id` int(11) NOT NULL,
  `num_copies_requested` int(11) NOT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_special_order_lines_on_issue_id` (`issue_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;

CREATE TABLE `special_order_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `special_order_id` int(11) NOT NULL,
  `note` text NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_special_order_notes_on_special_order_id` (`special_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `special_order_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `special_order_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT '0',
  `customer_name` varchar(255) DEFAULT '',
  `reason` varchar(255) DEFAULT '',
  `requested_at` datetime DEFAULT NULL,
  `requested_for_date` date DEFAULT NULL,
  `received_by` varchar(255) DEFAULT '',
  `authorized_by` int(11) DEFAULT NULL,
  `authorized_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `requested_by` int(11) NOT NULL DEFAULT '0',
  `authorize_comments` varchar(255) NOT NULL DEFAULT '',
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `completed_by` int(11) DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

CREATE TABLE `special_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `customer_name` varchar(255) NOT NULL DEFAULT '',
  `reason` varchar(255) NOT NULL DEFAULT '',
  `requested_at` datetime NOT NULL,
  `requested_for_date` date NOT NULL,
  `received_by` varchar(255) NOT NULL DEFAULT '',
  `authorized_by` int(11) DEFAULT NULL,
  `authorized_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `requested_by` int(11) NOT NULL DEFAULT '0',
  `authorize_comments` varchar(255) NOT NULL DEFAULT '',
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `completed_by` int(11) DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_special_orders_on_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

CREATE TABLE `standing_order_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `standing_order_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `publication_id` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4442 DEFAULT CHARSET=utf8;

CREATE TABLE `standing_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `publication_id` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_standing_orders_on_customer_id_and_publication_id` (`customer_id`,`publication_id`),
  KEY `index_standing_orders_on_publication_id` (`publication_id`),
  KEY `index_standing_orders_on_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2196 DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `num_customers` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `crypted_password` varchar(40) DEFAULT NULL,
  `salt` varchar(40) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `remember_token` varchar(255) DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `versioned_id` int(11) DEFAULT NULL,
  `versioned_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `changes` text,
  `number` int(11) DEFAULT NULL,
  `tag` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_versioned_id_and_versioned_type` (`versioned_id`,`versioned_type`),
  KEY `index_versions_on_user_id_and_user_type` (`user_id`,`user_type`),
  KEY `index_versions_on_user_name` (`user_name`),
  KEY `index_versions_on_number` (`number`),
  KEY `index_versions_on_tag` (`tag`),
  KEY `index_versions_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `waiting_order_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `waiting_order_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `publication_id` int(11) DEFAULT NULL,
  `num_copies` int(11) DEFAULT NULL,
  `comments` varchar(255) DEFAULT '',
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `request_date` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `waiting_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `publication_id` int(11) NOT NULL,
  `num_copies` int(11) NOT NULL,
  `comments` varchar(255) NOT NULL DEFAULT '',
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `request_date` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `warehouse_issue_box_size_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `warehouse_issue_box_size_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `warehouse_id` int(11) DEFAULT NULL,
  `issue_box_size_id` int(11) DEFAULT NULL,
  `num_boxes` int(11) NOT NULL DEFAULT '0',
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=273 DEFAULT CHARSET=utf8;

CREATE TABLE `warehouse_issue_box_sizes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `warehouse_id` int(11) DEFAULT NULL,
  `issue_box_size_id` int(11) DEFAULT NULL,
  `num_boxes` int(11) NOT NULL DEFAULT '0',
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8;

CREATE TABLE `warehouses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `tracks_inventory` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20100226031231');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('62');

INSERT INTO schema_migrations (version) VALUES ('63');

INSERT INTO schema_migrations (version) VALUES ('64');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('66');

INSERT INTO schema_migrations (version) VALUES ('67');

INSERT INTO schema_migrations (version) VALUES ('68');

INSERT INTO schema_migrations (version) VALUES ('69');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('70');

INSERT INTO schema_migrations (version) VALUES ('71');

INSERT INTO schema_migrations (version) VALUES ('72');

INSERT INTO schema_migrations (version) VALUES ('73');

INSERT INTO schema_migrations (version) VALUES ('74');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');