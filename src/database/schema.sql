-- ============================================
-- CinePass Database Schema
-- MySQL 8.0
-- Created: 2026
-- ============================================
CREATE DATABASE IF NOT EXISTS cinepass_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cinepass_db;


CREATE TABLE roles (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_name (name)
) ENGINE = InnoDB;


INSERT INTO roles (name)
VALUES ('ADMIN'),
  ('THEATER_OWNER'),
  ('CUSTOMER');


CREATE TABLE users (
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


CREATE TABLE user_roles (
  user_id CHAR(36) NOT NULL,
  role_id TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE refresh_tokens (
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


CREATE TABLE audit_logs (
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


CREATE TABLE theaters (
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


CREATE TABLE screens (
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


CREATE TABLE seat_types(
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


CREATE TABLE seats(
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


CREATE TABLE movies(
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


CREATE TABLE genres(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL UNIQUE,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE movie_genres(
  movie_id CHAR(36) NOT NULL,
  genre_id TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (movie_id, genre_id),
  CONSTRAINT fk_mg_movie FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
  CONSTRAINT fk_mg_genre FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
) ENGINE = InnoDB;


CREATE TABLE languages(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  code CHAR(2) NOT NULL UNIQUE,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE formats(
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(20) NOT NULL UNIQUE,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE casts(
  id CHAR(36) NOT NULL DEFAULT (UUID()),
  name VARCHAR(100) NOT NULL,
  photo_url VARCHAR(500) NULL,
  role_type ENUM('ACTOR', 'DIRECTOR', 'PRODUCER') NOT NULL,
  bio TEXT NULL,
  PRIMARY KEY(id)
) ENGINE = InnoDB;


CREATE TABLE movie_casts(
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