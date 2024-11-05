-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.11.8-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for cfx-hu-v2
CREATE DATABASE IF NOT EXISTS `cfx-hu-v2` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `cfx-hu-v2`;

-- Dumping structure for table cfx-hu-v2.graffitis
CREATE TABLE IF NOT EXISTS `graffitis` (
  `key` varchar(255) NOT NULL,
  `owner` text DEFAULT NULL,
  `model` text DEFAULT NULL,
  `coords` varchar(150) DEFAULT NULL,
  `rotation` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table cfx-hu-v2.graffitis: ~0 rows (approximately)
INSERT INTO `graffitis` (`key`, `owner`, `model`, `coords`, `rotation`) VALUES
	('622-ETH-247', 'santo', '507715297', '{"x":12.22999954223632,"y":-1346.02001953125,"z":30.3799991607666}', '{"x":0.0,"y":-0.0,"z":90.0}');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
