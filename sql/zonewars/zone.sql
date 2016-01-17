-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Hoszt: 127.0.0.1
-- Létrehozás ideje: 2016. Jan 17. 10:46
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
(2, 'devidson', 'Justricsi', 'Csak mert', '100.66.143.6', 0),
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- A tábla adatainak kiíratása `cars`
--

INSERT INTO `cars` (`id`, `rendszam`, `modelid`, `x`, `y`, `z`, `angle`, `tulaj`, `col1`, `col2`) VALUES
(1, 'ZW-0001', 470, 1245.75, -2009.06, 59.8211, 270.239, 0, 1, 1),
(2, 'ZW-0002', 470, 1245.75, -2012.57, 59.8232, 270.465, 0, 1, 1),
(3, 'ZW-0003', 412, 2256.07, -83.8725, 26.3573, 176.677, 0, 228, 228),
(4, 'ZW-0004', 412, 2252.45, -83.9015, 26.3414, 177.812, 0, 228, 228),
(5, 'ZW-0005', 426, 199.575, -155.626, 1.32076, 179.903, 0, 215, 215),
(6, 'ZW-0006', 426, 196.505, -155.718, 1.32137, 180.438, 0, 215, 215),
(7, 'ZW-0007', 439, 902.437, -1205.74, 16.8775, 177.382, 0, 218, 218),
(8, 'ZW-0008', 439, 898.898, -1205.74, 16.8728, 176.078, 0, 218, 218),
(9, 'ZW-0009', 500, 560.279, -1874.66, 4.01415, 356.63, 0, 250, 250),
(10, 'ZW-0010', 500, 548.325, -1873.35, 3.99679, 358.552, 0, 250, 250),
(11, 'ZW-0011', 540, 2500.28, -2577.55, 13.5089, 90.6477, 0, 0, 0),
(12, 'ZW-0012', 540, 2500.26, -2581.18, 13.5107, 89.9039, 0, 0, 0),
(13, 'ZW-0013', 470, -2178.79, -2369.16, 30.615, 53.1454, 0, 1, 1),
(14, 'ZW-0014', 470, -2176.64, -2366.25, 30.6183, 53.719, 0, 1, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `dobjects`
--

CREATE TABLE IF NOT EXISTS `dobjects` (
`id` int(11) NOT NULL,
  `modelid` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `r` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
(1, 'Justricsi', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 68065, 4, 5),
(2, 'devidson', '783bafc3c6c8441d4950330a0842469efe14ac60', 83812, 120, 5),
(3, 'Justrics', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 0, 0),
(4, 'viviii', '783bafc3c6c8441d4950330a0842469efe14ac60', 123450, 5, 5);

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
-- Tábla szerkezet ehhez a táblához `shops`
--

CREATE TABLE IF NOT EXISTS `shops` (
`id` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `pickupid` int(11) NOT NULL,
  `mapiconid` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- A tábla adatainak kiíratása `shops`
--

INSERT INTO `shops` (`id`, `x`, `y`, `z`, `pickupid`, `mapiconid`) VALUES
(1, 1123.74, -2036.99, 69.8862, 1274, 52),
(2, 2773.81, -2455.57, 13.6371, 1274, 52),
(3, 2269.59, -75.5542, 26.7724, 1274, 52),
(4, 207.149, -97.0534, 1.55725, 1274, 52),
(5, 915.312, -1235.07, 17.2109, 1274, 52),
(6, 666.679, -1880.26, 5.46, 1274, 52),
(7, -2198.71, -2387.39, 30.625, 1274, 52);

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
  `team` int(11) NOT NULL,
  `foglalhato` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=latin1;

--
-- A tábla adatainak kiíratása `zones`
--

INSERT INTO `zones` (`id`, `minX`, `minY`, `maxX`, `maxY`, `team`, `foglalhato`) VALUES
(1, 1089.01, -2115.57, 1253.68, -1965.17, 1, 0),
(2, 2213.78, -109.388, 2577.69, 196.379, 2, 0),
(3, 78.4756, -205.719, 340.162, 82.6449, 3, 0),
(4, 803.671, -1389.9, 1054.25, -1145.49, 4, 0),
(5, 2374.27, -2696.6, 2809.63, -2330.67, 5, 0),
(6, 154.397, -1967.24, 1011.01, -1818.95, 6, 0),
(7, 1169.74, -931.797, 1226.03, -866.02, 1, 1),
(8, 977.948, -943.812, 1022.61, -894.966, 1, 1),
(9, 675.56, -1308.61, 785.695, -1218.87, 4, 1),
(10, 308.028, -1382.58, 356.633, -1304.78, 6, 1),
(11, 1177.51, -1845.57, 1291.55, -1718.26, 1, 1),
(12, 1419.3, -1738.42, 1534.93, -1584.66, 5, 1),
(13, 1683.51, -1952.86, 1812.23, -1847.34, 5, 1),
(14, 1395.83, -2642.4, 2131.28, -2450.43, 1, 1),
(15, 2655.59, -1818.16, 2827.05, -1686.22, 5, 1),
(16, 764.56, -1665.85, 823.46, -1591.54, 6, 1),
(17, 349.851, -2088.61, 414.287, -2022.25, 6, 1),
(18, 457.155, -1576.58, 527.781, -1427.95, 6, 1),
(19, 1043.18, -1566.5, 1196.33, -1413.4, 4, 1),
(20, 1861.42, -1251.42, 2061.13, -1143.13, 5, 1),
(21, 2294.97, -1731.02, 2445.09, -1632.43, 1, 1),
(22, 1363.5, -1155.06, 1481.75, -1033.87, 4, 1),
(23, 596.605, -640.859, 808.529, -413.576, 3, 1),
(24, -171.842, -106.132, -0.749102, 107.722, 3, 1),
(25, -604.213, -200.862, -422.992, -36.3615, 3, 1),
(26, -1127.01, -759.555, -968.651, -596.413, 3, 1),
(27, -624.157, -563.994, -464.711, -467.151, 3, 1),
(28, 2421.98, -1040.16, 2609.26, -927.151, 2, 1),
(29, 1854.84, 132.682, 1994.51, 188.638, 2, 1),
(30, 1138.19, 172.825, 1490.8, 399.51, 2, 1),
(31, 1517.91, -45.2817, 1583.18, 74.0494, 2, 1),
(32, 1006.84, -368.534, 1122.14, -287.016, 2, 1),
(33, 2423.41, -2145.41, 2540.55, -2066.78, 5, 1),
(34, -2272.31, -2564.22, -2001.94, -2194.99, 7, 0),
(35, -1947.6, -1795.89, -1795.63, -1578.28, 7, 1),
(36, -2345.14, -1686.27, -2277.56, -1534.23, 7, 1),
(37, -1659.45, -2312.24, -1370.95, -2096.3, 7, 1),
(38, -1658.6, -2747.45, -1494.88, -2658.75, 7, 1);

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
-- Indexes for table `dobjects`
--
ALTER TABLE `dobjects`
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
-- Indexes for table `shops`
--
ALTER TABLE `shops`
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
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `dobjects`
--
ALTER TABLE `dobjects`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
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
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `zones`
--
ALTER TABLE `zones`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=39;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
