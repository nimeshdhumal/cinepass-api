-- ============================================
-- CinePass Database Schema
-- MySQL 8.0
-- Created: 2026
-- ============================================
CREATE DATABASE IF NOT EXISTS cinepass_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cinepass_db;


CREATE TABLE IF NOT EXISTS roles (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_name (name)
) ENGINE = InnoDB;


INSERT INTO roles (name)
VALUES ('ADMIN'),
  ('THEATER_OWNER'),
  ('CUSTOMER');


CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  email VARCHAR(100) NOT NULL,
  phone VARCHAR(15) NULL,
  password VARCHAR(255) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  is_verified TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_phone (phone),
  KEY idx_users_is_active (is_active)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS user_roles (
  user_id CHAR(36) NOT NULL,
  role_id TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS refresh_tokens (
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  token VARCHAR(500) NOT NULL,
  expires_at DATETIME NOT NULL,
  is_revoked TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_rt_user_id (user_id),
  KEY idx_rt_expires_at (expires_at),
  CONSTRAINT fk_rt_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id CHAR(36) NULL,
  action VARCHAR(100) NOT NULL,
  entity VARCHAR(50) NOT NULL,
  entity_id VARCHAR(36) NULL,
  old_value JSON NULL,
  new_value JSON NULL,
  ip_address VARCHAR(45) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_al_user_id (user_id),
  KEY idx_al_entity (entity, entity_id),
  KEY idx_al_created_at (created_at)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS theaters (
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  name VARCHAR(100) NOT NULL,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(60) NOT NULL,
  state VARCHAR(60) NOT NULL,
  pincode VARCHAR(10) NOT NULL,
  total_screens TINYINT UNSIGNED NOT NULL DEFAULT 0,
  latitude DECIMAL(10, 7) NULL,
  longitude DECIMAL(10, 7) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_theaters_city (city)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS screens (
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  theater_id CHAR(36) NOT NULL,
  name VARCHAR(50) NOT NULL,
  total_seats SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  screen_type ENUM('2D', '3D', 'IMAX', '4DX') NOT NULL DEFAULT '2D',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_screens_theater_id (theater_id),
  CONSTRAINT fk_screens_theater FOREIGN KEY (theater_id) REFERENCES theaters(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS seat_types(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(20) NOT NULL UNIQUE,
  description VARCHAR(100) NULL,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


INSERT INTO seat_types (name, description)
VALUES ('SILVER', 'Standard seating with basic comfort'),
  (
    'GOLD',
    'Premium seating with extra legroom and cushioned seats'
  ),
  (
    'PLATINUM',
    'Luxury seating with wide seats and premium view'
  ),
  (
    'RECLINER',
    'Full electric recliner with personal screen and blanket service'
  );


CREATE TABLE IF NOT EXISTS seats(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  screen_id CHAR(36) NOT NULL,
  seat_type_id TINYINT UNSIGNED NOT NULL,
  row_label CHAR(2) NOT NULL,
  seat_number TINYINT UNSIGNED NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY(id),
  KEY idx_seats_screen (screen_id, row_label, seat_number),
  UNIQUE KEY uq_seats_position (screen_id, row_label, seat_number),
  CONSTRAINT fk_seats_screen FOREIGN KEY (screen_id) REFERENCES screens(id) ON DELETE CASCADE,
  CONSTRAINT fk_seats_seat_type FOREIGN KEY (seat_type_id) REFERENCES seat_types(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS movies(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  title VARCHAR(150) NOT NULL,
  description TEXT NULL,
  duration_mins SMALLINT UNSIGNED NOT NULL,
  release_date DATE NOT NULL,
  poster_url VARCHAR(500) NULL,
  trailer_url VARCHAR(500) NULL,
  certificate ENUM('U', 'UA', 'A', 'S') NOT NULL DEFAULT 'UA',
  avg_rating DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
  status ENUM('UPCOMING', 'RELEASED', 'ARCHIVED') NOT NULL DEFAULT 'UPCOMING',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  FULLTEXT KEY ft_movies_search(title, description),
  KEY idx_movies_status(status),
  KEY idx_movies_release_date(release_date)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS genres(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL UNIQUE,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS movie_genres(
  movie_id CHAR(36) NOT NULL,
  genre_id TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (movie_id, genre_id),
  CONSTRAINT fk_mg_movie FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
  CONSTRAINT fk_mg_genre FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS languages(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  code CHAR(2) NOT NULL UNIQUE,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS formats(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(20) NOT NULL UNIQUE,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS casts(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  name VARCHAR(100) NOT NULL,
  photo_url VARCHAR(500) NULL,
  role_type ENUM('ACTOR', 'DIRECTOR', 'PRODUCER') NOT NULL,
  bio TEXT NULL,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS movie_casts(
  movie_id CHAR(36) NOT NULL,
  cast_id CHAR(36) NOT NULL,
  character_name VARCHAR(100) NULL,
  display_order TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (movie_id, cast_id),
  CONSTRAINT fk_mc_movie FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
  CONSTRAINT fk_mc_cast FOREIGN KEY (cast_id) REFERENCES casts(id) ON DELETE CASCADE
) ENGINE = InnoDB;


INSERT INTO languages (name, code)
VALUES('English', 'EN'),
  ('Hindi', 'HI'),
  ('Tamil', 'TA'),
  ('Telugu', 'TE'),
  ('Malayalam', 'ML'),
  ('Kannada', 'KA'),
  ('Marathi', 'MR');
  
INSERT INTO formats (name)
VALUES('2D'),
  ('3D'),
('IMAX'),
('Dolby Atmos'),
  ('4DX');


CREATE TABLE IF NOT EXISTS shows(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  movie_id CHAR(36) NOT NULL,
  screen_id CHAR(36) NOT NULL,
  language_id TINYINT UNSIGNED NOT NULL,
  format_id TINYINT UNSIGNED NOT NULL,
  show_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status ENUM('SCHEDULED','ACTIVE','CANCELLED','COMPLETED') NOT NULL DEFAULT 'SCHEDULED',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_shows_movie_id (movie_id),
  KEY idx_shows_screen_id (screen_id),
  KEY idx_shows_date (show_date, status),
  UNIQUE KEY uq_shows_screen_time (screen_id, show_date, start_time),
  CONSTRAINT fk_shows_movie FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
  CONSTRAINT fk_shows_screen FOREIGN KEY (screen_id) REFERENCES screens(id) ON DELETE CASCADE,
  CONSTRAINT fk_shows_language FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE RESTRICT,
  CONSTRAINT fk_shows_format FOREIGN KEY (format_id) REFERENCES formats(id) ON DELETE RESTRICT 
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS show_seats(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  show_id CHAR(36) NOT NULL,
  seat_id CHAR(36) NOT NULL,
  status ENUM('AVAILABLE','LOCKED','BOOKED') NOT NULL DEFAULT 'AVAILABLE',
  price DECIMAL(8,2) NOT NULL,
  PRIMARY KEY(id),
  KEY idx_ss_show_status (show_id,status),
  UNIQUE KEY uq_ss_show_seat (show_id, seat_id),
  CONSTRAINT fk_ss_shows FOREIGN KEY (show_id) REFERENCES shows(id) ON DELETE CASCADE,
  CONSTRAINT fk_ss_seats FOREIGN KEY (seat_id) REFERENCES seats(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS pricing_tiers(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  show_id CHAR(36) NOT NULL,
  seat_type_id TINYINT UNSIGNED NOT NULL,
  price DECIMAL(8,2) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  UNIQUE KEY uq_pt_show_seat_type (show_id, seat_type_id),
  KEY idx_pt_show_id (show_id),
  CONSTRAINT fk_pt_show FOREIGN KEY (show_id) REFERENCES shows(id) ON DELETE CASCADE,
  CONSTRAINT fk_pt_seat_type FOREIGN KEY (seat_type_id) REFERENCES seat_types(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS offers(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  code VARCHAR(20) NOT NULL,
  description VARCHAR(255) NULL,
  discount_type ENUM('PERCENTAGE','FLAT') NOT NULL,
  discount_value DECIMAL(8,2) NOT NULL,
  min_amount DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  max_uses INT UNSIGNED NULL,
  used_count INT UNSIGNED NOT NULL DEFAULT 0,
  valid_from DATETIME NOT NULL,
  valid_until DATETIME NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_offers_validity (valid_from, valid_until),
  UNIQUE KEY uq_offers_code (code)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS schedules(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  screen_id CHAR(36) NOT NULL,
  movie_id CHAR(36) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  show_times JSON NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_schedules_screen (screen_id),
  KEY idx_schedules_movie(movie_id),
  CONSTRAINT fk_sch_screen FOREIGN KEY (screen_id) REFERENCES screens(id) ON DELETE CASCADE,
  CONSTRAINT fk_sch_movie FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS bookings(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  show_id CHAR(36) NOT NULL,
  booking_ref VARCHAR(20) NOT NULL UNIQUE,
  status ENUM('PENDING','CONFIRMED','CANCELLED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  total_amount DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  final_amount DECIMAL(10,2) NOT NULL,
  offer_id CHAR(36) NULL,
  expires_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_bookings_user_status (user_id,status),
  KEY idx_bookings_show_id (show_id),
  KEY idx_bookings_expires_at (expires_at),
  CONSTRAINT fk_booking_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_booking_shows FOREIGN KEY (show_id) REFERENCES shows(id) ON DELETE CASCADE,
  CONSTRAINT fk_booking_offers FOREIGN KEY (offer_id) REFERENCES offers(id) ON DELETE SET NULL
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS booking_seats(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  booking_id CHAR(36) NOT NULL,
  show_seat_id CHAR(36) NOT NULL,
  price DECIMAL(8,2) NOT NULL,
  PRIMARY KEY(id),
  KEY idx_bs_booking_id(booking_id),
  UNIQUE KEY uq_bs_show_seat (show_seat_id),
  CONSTRAINT fk_bs_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  CONSTRAINT fk_bs_show_seat FOREIGN KEY (show_seat_id) REFERENCES show_seats(id)  ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS seat_locks(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  show_seat_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  session_token VARCHAR(100) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_sl_show_seat_id (show_seat_id),
  KEY idx_sl_expires_at (expires_at),
  KEY idx_sl_user_id (user_id),
  CONSTRAINT fk_sl_show_seat FOREIGN KEY (show_seat_id) REFERENCES show_seats(id) ON DELETE CASCADE,
  CONSTRAINT fk_sl_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS tickets(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  booking_id CHAR(36) NOT NULL,
  booking_seat_id CHAR(36) NOT NULL,
  ticket_number VARCHAR(20) NOT NULL UNIQUE,
  qr_code TEXT NOT NULL,
  is_used TINYINT(1) NOT NULL DEFAULT 0,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_tickets_booking_id (booking_id),
  CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  CONSTRAINT fk_tickets_booking_seat FOREIGN KEY (booking_seat_id) REFERENCES booking_seats(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS qr_tokens(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  ticket_id CHAR(36) NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  is_used TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_qt_ticket_id (ticket_id),
  CONSTRAINT fk_qt_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS payments(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  booking_id CHAR(36) NOT NULL,
  gateway ENUM('RAZORPAY','STRIPE','CASH') NOT NULL,
  gateway_order_id VARCHAR(100) NULL,
  gateway_payment_id VARCHAR(100) NULL UNIQUE,
  gateway_signature VARCHAR(255) NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  status ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  paid_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_payments_booking_id (booking_id),
  KEY idx_payments_status (status),
  KEY idx_payments_gateway_order (gateway_order_id),
  CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS payment_logs(
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payment_id CHAR(36) NOT NULL,
  event VARCHAR(100) NOT NULL,
  payload JSON NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_pl_payment_id (payment_id),
  CONSTRAINT fk_pl_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS refunds(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  payment_id CHAR(36) NOT NULL,
  booking_id CHAR(36) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  reason VARCHAR(255) NULL,
  status ENUM('PENDING','PROCESSED','FAILED') NOT NULL DEFAULT 'PENDING',
  gateway_refund_id VARCHAR(100) NULL UNIQUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_refunds_booking_id (booking_id),
  CONSTRAINT fk_refunds_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  CONSTRAINT fk_refunds_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS refund_items(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  refund_id CHAR(36) NOT NULL,
  booking_seat_id CHAR(36) NOT NULL,
  amount DECIMAL(8,2) NOT NULL,
  PRIMARY KEY(id),
  KEY idx_ri_refund_id (refund_id),
  CONSTRAINT fk_ri_refund FOREIGN KEY (refund_id) REFERENCES refunds(id) ON DELETE CASCADE,
  CONSTRAINT fk_ri_booking_seat FOREIGN KEY (booking_seat_id) REFERENCES booking_seats(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS payment_methods(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  type ENUM('CARD','UPI','NETBANKING','WALLET') NOT NULL,
  provider VARCHAR(50) NULL,
  last_four CHAR(4) NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_pm_user_id(user_id),
  CONSTRAINT fk_pm_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS reviews(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  movie_id CHAR(36) NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  comment TEXT NULL,
  is_approved TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_reviews_movie_id (movie_id),
  UNIQUE KEY uq_reviews_user_movie (user_id, movie_id),
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_movie FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS notifications(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  type ENUM('EMAIL','SMS','PUSH') NOT NULL,
  title VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_notif_user_id (user_id),
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS loyalty_points(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  booking_id CHAR(36) NULL,
  points INT NOT NULL,
  type ENUM('EARNED','REDEEMED','EXPIRED') NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_lp_user_id (user_id),
  CONSTRAINT fk_loyal_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_loyal_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS configurations(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `key` VARCHAR(50) NOT NULL UNIQUE,
  `value` TEXT NOT NULL,
  description VARCHAR(255) NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS food_items(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  theater_id CHAR(36) NOT NULL,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(8,2) NOT NULL,
  category ENUM('SNACK','BEVERAGE','COMBO','MEAL') NOT NULL,
  is_available TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_fi_theater_id (theater_id),
  CONSTRAINT fk_fi_theater FOREIGN KEY (theater_id) REFERENCES theaters(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS food_orders(
  id           CHAR(36)         NOT NULL DEFAULT (UUID()),
  booking_id   CHAR(36)         NOT NULL,
  food_item_id CHAR(36)         NOT NULL,
  quantity     TINYINT UNSIGNED NOT NULL DEFAULT 1,
  unit_price   DECIMAL(8,2)     NOT NULL,
  total_price  DECIMAL(8,2)     NOT NULL,
  created_at   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id),
  KEY idx_fo_booking_id (booking_id),
  CONSTRAINT fk_fo_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  CONSTRAINT fk_fo_food_item FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE CASCADE
) ENGINE = InnoDB;