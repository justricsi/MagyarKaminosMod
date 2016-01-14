-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Hoszt: 127.0.0.1
-- Létrehozás ideje: 2016. Jan 14. 14:08
-- Szerver verzió: 5.6.21
-- PHP verzió: 5.5.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Adatbázis: `zone`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `bandata`
--

CREATE TABLE IF NOT EXISTS `bandata` (
`id` int(11) NOT NULL,
  `admin` varchar(255) NOT NULL,
  `jatekos` varchar(255) NOT NULL,
  `ok` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `bannolva` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- A tábla adatainak kiíratása `bandata`
--

INSERT INTO `bandata` (`id`, `admin`, `jatekos`, `ok`, `ip`, `bannolva`) VALUES
(1, 'Justricsi', 'Sari', 'ez_egy_proba_szoveg', '192.168.0.100', 1),
(2, 'devidson', 'Justricsi', 'Csak mert', '100.66.143.6', 1),
(3, 'devidson', 'viviii', 'Mondtam hogy fejezd be.', '192.168.1.103', 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `cars`
--

CREATE TABLE IF NOT EXISTS `cars` (
`id` int(11) NOT NULL,
  `rendszam` varchar(7) COLLATE utf8_hungarian_ci NOT NULL,
  `modelid` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `angle` float NOT NULL,
  `tulaj` int(11) NOT NULL DEFAULT '0',
  `col1` int(11) NOT NULL DEFAULT '1',
  `col2` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- A tábla adatainak kiíratása `cars`
--

INSERT INTO `cars` (`id`, `rendszam`, `modelid`, `x`, `y`, `z`, `angle`, `tulaj`, `col1`, `col2`) VALUES
(1, 'ZW-0001', 470, 1245.75, -2009.06, 59.8211, 270.239, 0, 1, 1),
(2, 'ZW-0002', 470, 1245.75, -2012.57, 59.8232, 270.465, 0, 1, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `jatekosok`
--

CREATE TABLE IF NOT EXISTS `jatekosok` (
`ID` int(11) NOT NULL,
  `NEV` varchar(255) NOT NULL,
  `JELSZO` varchar(255) NOT NULL,
  `PENZ` int(11) NOT NULL,
  `PONT` int(11) NOT NULL,
  `ADMINLVL` int(11) DEFAULT '0'
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- A tábla adatainak kiíratása `jatekosok`
--

INSERT INTO `jatekosok` (`ID`, `NEV`, `JELSZO`, `PENZ`, `PONT`, `ADMINLVL`) VALUES
(1, 'Justricsi', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 30, 5),
(2, 'devidson', '783bafc3c6c8441d4950330a0842469efe14ac60', 0, 77, 5),
(3, 'Justrics', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 0, 0),
(4, 'viviii', '783bafc3c6c8441d4950330a0842469efe14ac60', 0, 5, 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `objects`
--

CREATE TABLE IF NOT EXISTS `objects` (
`id` int(100) NOT NULL,
  `modelID` int(5) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rx` float NOT NULL,
  `ry` float NOT NULL,
  `rz` float NOT NULL,
  `distance` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `zones`
--

CREATE TABLE IF NOT EXISTS `zones` (
`id` int(11) NOT NULL,
  `minX` float NOT NULL,
  `minY` float NOT NULL,
  `maxX` float NOT NULL,
  `maxY` float NOT NULL,
  `team` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- A tábla adatainak kiíratása `zones`
--

INSERT INTO `zones` (`id`, `minX`, `minY`, `maxX`, `maxY`, `team`) VALUES
(1, 1089.01, -2115.57, 1253.68, -1965.17, 1),
(2, 2213.78, -109.388, 2577.69, 196.379, 2),
(3, 78.4756, -205.719, 340.162, 82.6449, 3),
(4, 803.671, -1389.9, 1054.25, -1145.49, 4),
(5, 2374.27, -2696.6, 2809.63, -2330.67, 5),
(6, 154.397, -1967.24, 1011.01, -1818.95, 6);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bandata`
--
ALTER TABLE `bandata`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cars`
--
ALTER TABLE `cars`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jatekosok`
--
ALTER TABLE `jatekosok`
 ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `objects`
--
ALTER TABLE `objects`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `zones`
--
ALTER TABLE `zones`
 ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bandata`
--
ALTER TABLE `bandata`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `jatekosok`
--
ALTER TABLE `jatekosok`
MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `objects`
--
ALTER TABLE `objects`
MODIFY `id` int(100) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `zones`
--
ALTER TABLE `zones`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=7;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
