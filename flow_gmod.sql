-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 07, 2023 at 12:21 PM
-- Server version: 5.7.36
-- PHP Version: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flow_gmod`
--
CREATE DATABASE IF NOT EXISTS `flow_gmod` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `flow_gmod`;

-- --------------------------------------------------------

--
-- Table structure for table `game_bots`
--

DROP TABLE IF EXISTS `game_bots`;
CREATE TABLE IF NOT EXISTS `game_bots` (
  `szMap` text NOT NULL,
  `nTime` double NOT NULL,
  `nStyle` int(11) NOT NULL,
  `szSteam` text NOT NULL,
  `szDate` text NOT NULL,
  `szBuffer` longtext NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `game_checkpoints`
--

DROP TABLE IF EXISTS `game_checkpoints`;
CREATE TABLE IF NOT EXISTS `game_checkpoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `szUID` text NOT NULL,
  `nStyle` int(11) DEFAULT NULL,
  `szMap` text NOT NULL,
  `szData` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `game_map`
--

DROP TABLE IF EXISTS `game_map`;
CREATE TABLE IF NOT EXISTS `game_map` (
  `szMap` text NOT NULL,
  `nMultiplier` int(11) NOT NULL DEFAULT '1',
  `nTier` int(11) NOT NULL DEFAULT '0',
  `nType` int(11) DEFAULT NULL,
  `nBonusMultiplier` int(11) DEFAULT NULL,
  `nPlays` int(11) NOT NULL DEFAULT '0',
  `nOptions` int(11) DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `game_playerinfo`
--

DROP TABLE IF EXISTS `game_playerinfo`;
CREATE TABLE IF NOT EXISTS `game_playerinfo` (
  `szUID` varchar(50) DEFAULT NULL,
  `szLastName` text,
  `nPlaytime` int(11) DEFAULT NULL,
  `nLastConnected` text,
  `nConnections` int(11) DEFAULT NULL,
  `szPlayerTitle` text,
  UNIQUE KEY `szUID` (`szUID`),
  KEY `szUID_2` (`szUID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `game_stages`
--

DROP TABLE IF EXISTS `game_stages`;
CREATE TABLE IF NOT EXISTS `game_stages` (
  `szUID` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `szMap` mediumtext CHARACTER SET utf32,
  `nStage` int(11) DEFAULT NULL,
  `nStyle` int(11) DEFAULT NULL,
  `nTime` double DEFAULT NULL,
  `szDate` text CHARACTER SET utf32,
  `vPrestrafe` double DEFAULT NULL,
  KEY `szUID` (`szUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Table structure for table `game_times`
--

DROP TABLE IF EXISTS `game_times`;
CREATE TABLE IF NOT EXISTS `game_times` (
  `szUID` text,
  `szMap` text,
  `nStyle` int(11) DEFAULT NULL,
  `nTime` double DEFAULT NULL,
  `nPoints` double DEFAULT NULL,
  `vData` text,
  `szDate` text,
  `vPrestrafe` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `game_zones`
--

DROP TABLE IF EXISTS `game_zones`;
CREATE TABLE IF NOT EXISTS `game_zones` (
  `szMap` text NOT NULL,
  `nType` int(11) NOT NULL,
  `vPos1` text,
  `vPos2` text
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `gmod_admins`
--

DROP TABLE IF EXISTS `gmod_admins`;
CREATE TABLE IF NOT EXISTS `gmod_admins` (
  `nID` int(11) NOT NULL AUTO_INCREMENT,
  `szSteam` varchar(255) NOT NULL,
  `nLevel` int(11) NOT NULL DEFAULT '0',
  `nType` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`nID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gmod_bans`
--

DROP TABLE IF EXISTS `gmod_bans`;
CREATE TABLE IF NOT EXISTS `gmod_bans` (
  `nID` int(11) NOT NULL AUTO_INCREMENT,
  `szUserSteam` varchar(255) NOT NULL,
  `szUserName` varchar(255) DEFAULT NULL,
  `nStart` bigint(20) NOT NULL,
  `nLength` int(11) NOT NULL,
  `szReason` varchar(255) DEFAULT NULL,
  `szAdminSteam` varchar(255) NOT NULL,
  `szAdminName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`nID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gmod_logging`
--

DROP TABLE IF EXISTS `gmod_logging`;
CREATE TABLE IF NOT EXISTS `gmod_logging` (
  `nID` int(11) NOT NULL AUTO_INCREMENT,
  `nType` int(11) NOT NULL DEFAULT '0',
  `szData` text,
  `szDate` varchar(255) DEFAULT NULL,
  `szAdminSteam` varchar(255) NOT NULL,
  `szAdminName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`nID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gmod_vips`
--

DROP TABLE IF EXISTS `gmod_vips`;
CREATE TABLE IF NOT EXISTS `gmod_vips` (
  `nID` int(11) NOT NULL AUTO_INCREMENT,
  `szSteam` varchar(255) NOT NULL,
  `nType` int(11) NOT NULL,
  `szTag` varchar(255) NOT NULL DEFAULT '',
  `szName` varchar(255) NOT NULL DEFAULT '',
  `szChat` varchar(255) NOT NULL DEFAULT '',
  `nStart` bigint(20) DEFAULT NULL,
  `nLength` int(11) DEFAULT NULL,
  PRIMARY KEY (`nID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
