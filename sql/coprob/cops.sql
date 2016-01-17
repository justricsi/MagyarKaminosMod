-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Hoszt: 127.0.0.1
-- Létrehozás ideje: 2016. Jan 17. 10:57
-- Szerver verzió: 5.6.21
-- PHP verzió: 5.5.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Adatbázis: `cops`
--

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
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- A tábla adatainak kiíratása `cars`
--

INSERT INTO `cars` (`id`, `rendszam`, `modelid`, `x`, `y`, `z`, `angle`, `tulaj`, `col1`, `col2`) VALUES
(1, 'CR-0001', 596, 1585.39, -1667.41, 5.612, 270, 0, 0, 1),
(2, 'CR-0002', 596, 1585.93, -1671.71, 5.6152, 270, 0, 0, 1),
(3, 'CT-0003', 596, 1601.96, -1683.92, 5.61214, 90.5621, 0, 0, 1),
(4, 'CT-0004', 596, 1601.91, -1688.07, 5.61222, 89.4088, 0, 0, 1),
(5, 'CT-0005', 596, 1601.86, -1692.07, 5.61182, 89.4421, 0, 0, 1),
(6, 'CT-0006', 596, 1601.82, -1696.16, 5.61175, 89.0693, 0, 0, 1),
(7, 'CT-0007', 596, 1601.76, -1700.29, 5.61185, 89.4803, 0, 0, 1),
(8, 'CT-0008', 596, 1601.71, -1704.29, 5.61171, 89.4136, 0, 0, 1),
(9, 'CR-0009', 523, 1595.42, -1710.73, 5.45888, 356.118, 0, 0, 1),
(10, 'CR-0010', 523, 1591.08, -1710.74, 5.46117, 357.869, 0, 0, 1),
(11, 'CR-0011', 523, 1587.26, -1710.91, 5.46079, 0.207492, 0, 0, 1),
(12, 'CR-0012', 523, 1583.42, -1711.02, 5.46105, 1.61757, 0, 0, 1),
(13, 'CR-0013', 427, 1578.64, -1710.69, 6.02247, 358.77, 0, 0, 1),
(14, 'CR-0014', 427, 1574.56, -1710.79, 6.02245, 0.383594, 0, 0, 1),
(15, 'CR-0015', 427, 1570.34, -1710.85, 6.02238, 0.910641, 0, 0, 1),
(16, 'CR-0016', 416, 2039.56, -1429.45, 17.2274, 89.6336, 0, 1, 3),
(17, 'CR-0017', 416, 2039.58, -1425.52, 17.227, 89.7193, 0, 1, 3),
(18, 'CR-0018', 416, 2039.63, -1421.29, 17.2272, 89.9202, 0, 1, 3),
(19, 'CR-0019', 416, 2039.71, -1417.05, 17.2288, 89.577, 0, 1, 3),
(20, 'CR-0020', 416, 1177.43, -1338.86, 14.0601, 270.136, 0, 1, 3),
(21, 'CR-0021', 416, 1177.75, -1308.69, 14.0027, 269.428, 0, 1, 3),
(22, 'CR-0022', 416, 1095.63, -1328.41, 13.4499, 359.564, 0, 1, 3),
(23, 'CR-0023', 416, 1099.87, -1328.51, 13.4395, 0.008464, 0, 1, 3),
(24, 'CR-0024', 416, 1113.18, -1328.65, 13.4273, 0.71856, 0, 1, 3),
(25, 'CR-0025', 416, 1108.92, -1328.65, 13.4304, 0.387095, 0, 1, 3),
(26, 'CR-0026', 416, 1126.51, -1328.74, 13.4222, 0.218826, 0, 1, 3),
(27, 'CR-0027', 416, 1121.96, -1328.45, 13.446, 0.003565, 0, 1, 3),
(28, 'CR-0028', 566, 2445.64, -1345.25, 23.6903, 180.391, 0, 144, 144),
(29, 'CR-0029', 412, 2445.65, -1365.04, 23.7451, 179.7, 0, 144, 144),
(30, 'CR-0030', 517, 2456.39, -1345.7, 23.7654, 358.767, 0, 144, 144),
(31, 'CR-0031', 517, 2456.36, -1365.31, 23.7689, 359.236, 0, 144, 144),
(32, 'CR-0032', 567, 2502.63, -1655.85, 13.3385, 66.2133, 0, 128, 123),
(33, 'CR-0033', 492, 2505.68, -1679.88, 13.2427, 316.638, 0, 128, 0),
(34, 'CR-0034', 600, 2490.04, -1684.33, 13.1325, 269.842, 0, 128, 0),
(35, 'CR-0035', 567, 2484.53, -1653.56, 13.2654, 88.5075, 0, 128, 123),
(36, 'CR-0036', 474, 2103.44, -1059.23, 26.7503, 49.3273, 0, 6, 123),
(37, 'CR-0037', 474, 2122.14, -1074.51, 24.1841, 51.4733, 0, 6, 123),
(38, 'CR-0038', 474, 2115.15, -1082.98, 24.1857, 233.385, 0, 6, 123),
(39, 'CR-0039', 474, 2096.45, -1067.68, 26.7293, 228.346, 0, 6, 123),
(40, 'CR-0040', 474, 1892.88, -1926.8, 13.2258, 90.0308, 0, 2, 123),
(41, 'CR-0041', 474, 1918.71, -1927.03, 13.2254, 90.1854, 0, 2, 123),
(42, 'CR-0042', 575, 1917.5, -1937.77, 13.0617, 269.242, 0, 2, 123),
(43, 'CR-0043', 575, 1893.08, -1937.77, 13.0625, 271.517, 0, 2, 123);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `enter`
--

CREATE TABLE IF NOT EXISTS `enter` (
`id` int(11) NOT NULL,
  `interior` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `hx` float NOT NULL,
  `hy` float NOT NULL,
  `hz` float NOT NULL,
  `kibe` int(11) NOT NULL,
  `leiras` varchar(30) COLLATE utf8_hungarian_ci NOT NULL,
  `mapicon` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- A tábla adatainak kiíratása `enter`
--

INSERT INTO `enter` (`id`, `interior`, `x`, `y`, `z`, `hx`, `hy`, `hz`, `kibe`, `leiras`, `mapicon`) VALUES
(1, 1, 1367.45, -1279.68, 13.5469, 288.703, -39.7767, 1001.52, 0, 'Fegyverbolt', 6),
(2, 6, 1554.72, -1675.46, 16.1953, 246.784, 63.9002, 1003.64, 0, 'Rendőrség', 30),
(3, 0, 285.451, -40.9718, 1001.52, 1364.33, -1279.82, 13.5469, 1, 'Fegyverbolt', 0),
(4, 0, 246.827, 62.7047, 1003.64, 1552.54, -1675.38, 16.1953, 1, 'Rendőrség', 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `objects`
--

CREATE TABLE IF NOT EXISTS `objects` (
`id` int(11) NOT NULL,
  `modelid` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rx` float NOT NULL,
  `ry` float NOT NULL,
  `rz` float NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- A tábla adatainak kiíratása `objects`
--

INSERT INTO `objects` (`id`, `modelid`, `x`, `y`, `z`, `rx`, `ry`, `rz`) VALUES
(1, 8167, 1089.2, -1333.3, 13.9, 0, 0, 0),
(2, 968, 1998.6, -1439.4, 13.6, 0, 91.25, 359.25),
(3, 968, 2008.6, -1449.4, 13.6, 0, 91, 91),
(4, 966, 2008.6, -1449.5, 12.6, 0, 0, 271),
(5, 966, 1998.5, -1439.4, 12.6, 0, 0, 179.25),
(6, 983, 2000.8, -1350.9, 23.7, 0, 0, 89.25),
(7, 983, 2102.7, -1447.8, 23.7, 0, 0, 0),
(8, 966, 1149.8, -1384.8, 12.8, 0, 0, 0),
(9, 968, 1150, -1384.8, 13.7, 0, 268.75, 0),
(10, 8407, 1141.9, -1384.2, 14.3, 0, 0, 271.25),
(11, 983, 1140, -1380.2, 13.5, 0, 0, 196),
(12, 983, 1132.7, -1292.3, 13.2, 0, 0, 270),
(13, 966, 1149.7, -1292.8, 12.7, 0, 0, 0),
(14, 968, 1149.8, -1292.8, 13.6, 0, 268.748, 0),
(15, 8407, 1141.7, -1293.1, 14.1, 0, 0, 272),
(16, 983, 1137.5, -1292.3, 13.2, 0, 0, 270),
(17, 983, 1138.3, -1366, 13.5, 0, 0, 193.995),
(18, 983, 1139.1, -1373.9, 13.5, 0, 0, 179.995),
(19, 983, 1139.1, -1372.3, 13.5, 0, 0, 179.995),
(20, 968, 1544.7, -1630.8, 13.3, 0, 269.25, 270),
(21, 970, 1544.7, -1620.9, 13.1, 0, 0, 90),
(22, 970, 1545.6, -1635.7, 13.1, 0, 0, 180.5),
(23, 970, 1547.7, -1637.8, 13.1, 0, 0, 90),
(24, 970, 1543.5, -1633.7, 13.1, 0, 0, 90),
(25, 2942, 1172.1, -1327.9, 15, 0, 0, 90),
(26, 2942, 2022.3, -1401.7, 16.8, 0, 0, 0),
(27, 2942, 1462.4, -1010.2, 26.5, 0, 0, 0),
(28, 2942, 823.1, -1356.5, 13.2, 0, 0, 180.75),
(29, 2942, 825.5, -1760, 13.2, 0, 0, 0),
(30, 2942, 492.8, -1506.7, 20.3, 0, 0, 268.5),
(31, 2942, 1010.7, -929.2, 42, 0, 0, 7.25);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `users`
--

CREATE TABLE IF NOT EXISTS `users` (
`id` int(11) NOT NULL,
  `name` varchar(40) COLLATE utf8_hungarian_ci NOT NULL,
  `pass` varchar(40) COLLATE utf8_hungarian_ci NOT NULL,
  `score` int(11) NOT NULL DEFAULT '0',
  `money` int(11) NOT NULL DEFAULT '0',
  `alvl` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- A tábla adatainak kiíratása `users`
--

INSERT INTO `users` (`id`, `name`, `pass`, `score`, `money`, `alvl`) VALUES
(1, 'Devidson', '783bafc3c6c8441d4950330a0842469efe14ac60', 9, 553350, 0),
(2, 'Vivigepe', '783bafc3c6c8441d4950330a0842469efe14ac60', 1, 54020, 0),
(3, 'Justricsi', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 70000, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cars`
--
ALTER TABLE `cars`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `enter`
--
ALTER TABLE `enter`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `objects`
--
ALTER TABLE `objects`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `name` (`name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=44;
--
-- AUTO_INCREMENT for table `enter`
--
ALTER TABLE `enter`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `objects`
--
ALTER TABLE `objects`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=32;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
